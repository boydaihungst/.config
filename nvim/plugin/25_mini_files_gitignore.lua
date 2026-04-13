---@module "mini.files"

local uv = vim.uv

---@class MiniFilesEntry
---@field name string Entry name
---@field path string Full path
---@field fs_type string Entry type ('file' or 'directory')

---@class GitignoreCache
---@field ignored table<string, boolean> Map of file paths to ignored status
---@field timestamp number Cache creation timestamp
---@field gitignore_files table<string, number> Map of gitignore file paths to their mtime
---@field expires_at number When this cache entry expires

---@class PerformanceMetrics
---@field cache_hits number Number of cache hits
---@field cache_misses number Number of cache misses
---@field sync_operations number Number of synchronous operations
---@field async_operations number Number of asynchronous operations
---@field total_processing_time number Total time spent processing

---@class MiniFilesGitignoreConfig
---@field max_cache_size number Maximum number of directories to cache (default: 1000)
---@field cache_ttl number Cache time-to-live in seconds (default: 300)
---@field sync_threshold number Max files for sync processing (default: 100)
---@field prefetch_depth number Depth for prefetching subdirectories (default: 2)
---@field enable_metrics boolean Enable performance metrics (default: false)
---@field log_level number Logging level (default: vim.log.levels.WARN)
---@field enable_logging boolean Enable/disable logging (default: false)

---Gitignore integration for mini.files
---@class MiniFilesGitignore
---@field config MiniFilesGitignoreConfig Configuration options
---@field cache table<string, GitignoreCache> Directory path to cache mapping
---@field state boolean Current filtering state (true = show all, false = respect gitignore)
---@field initial_sort function Original sort function from options
---@field initial_filter function Original filter function from options
---@field current_sort function Current active sort function
---@field current_filter function Current active filter function
---@field git_roots table<string, string> Map of directory paths to their git root
---@field fs_watchers table<string, uv_handle_t> Map of paths to filesystem watchers
---@field job_pool table<number, table> Pool of active jobs
---@field metrics PerformanceMetrics Performance tracking
---@field logger table Logger instance
local MiniFilesGitignore = {}

---Default configuration
---@type MiniFilesGitignoreConfig
local DEFAULT_CONFIG = {
  max_cache_size = 200,
  max_concurrent_jobs = 10,
  cache_ttl = 300,
  sync_threshold = 50,
  prefetch_depth = 1,
  enable_metrics = false,
  enable_logging = false,
  log_level = vim.log.levels.WARN,
}

---Create a new logger instance
---@param level number Log level
---@param enabled boolean Whether logging is enabled
---@return table logger Logger instance
local function create_logger(level, enabled)
  if not enabled then
    return {
      level = nil,
      debug = function() end,
      info = function() end,
      warn = function() end,
      error = function() end,
    }
  end
  return {
    level = level,
    debug = function(self, msg, ...)
      if self.level <= vim.log.levels.DEBUG then vim.notify(string.format('debug: ' .. msg, ...), vim.log.levels.DEBUG) end
    end,
    info = function(self, msg, ...)
      if self.level <= vim.log.levels.INFO then vim.notify(string.format('info: ' .. msg, ...), vim.log.levels.INFO) end
    end,
    warn = function(self, msg, ...)
      if self.level <= vim.log.levels.WARN then vim.notify(string.format('warn: ' .. msg, ...), vim.log.levels.WARN) end
    end,
    error = function(self, msg, ...)
      if self.level <= vim.log.levels.ERROR then vim.notify(string.format('error: ' .. msg, ...), vim.log.levels.ERROR) end
    end,
  }
end

---Initialize new MiniFilesGitignore instance
---@param opts MiniFilesSpec Configuration options
---@param config? MiniFilesGitignoreConfig Gitignore-specific configuration
---@return MiniFilesGitignore
function MiniFilesGitignore.new(opts, config)
  local self = setmetatable({}, { __index = MiniFilesGitignore })

  self.config = vim.tbl_deep_extend('force', DEFAULT_CONFIG, config or {})

  -- Initialize the internal state. Note that `state` being false means the
  -- filter is currently active (i.e., we are hiding ignored files). It feels
  -- backwards, but think of it as "is_unfiltered".
  --
  self.cache = {}
  self.state = false
  self.initial_sort = opts.content.sort
  self.initial_filter = opts.content.filter
  self.current_sort = self.initial_sort
  self.current_filter = self.initial_filter
  self.git_roots = {}
  self.fs_watchers = {}
  self.job_pool = {}
  self.active_jobs_count = 0

  self.metrics = {
    cache_hits = 0,
    cache_misses = 0,
    sync_operations = 0,
    async_operations = 0,
    dropped_jobs = 0,
    total_processing_time = 0,
  }

  self.logger = create_logger(self.config.log_level, self.config.enable_logging)

  return self
end

---Get current sort function
---@return function sort Current sort function
function MiniFilesGitignore:get_sort() return self.current_sort end

---Get current filter function
---@return function filter Current filter function
function MiniFilesGitignore:get_filter() return self.current_filter end

---Get performance metrics
---@return PerformanceMetrics metrics Current performance metrics
function MiniFilesGitignore:get_metrics() return vim.deepcopy(self.metrics) end

---Find git root for a given directory
---@param dir string Directory path
---@return string|nil git_root Git root directory or nil if not in git repo
function MiniFilesGitignore:find_git_root(dir)
  if self.git_roots[dir] then return self.git_roots[dir] end

  -- We need to walk up the directory tree to find the `.git` marker. This
  -- defines the context for any `git check-ignore` calls.
  --
  local current = dir
  while current and #current > 1 do
    local git_dir = current .. '/.git'
    local stat = uv.fs_stat(git_dir)
    -- We accept both directories (standard repos) and files (worktrees,
    -- submodules) as valid markers.
    --
    if stat then
      self.git_roots[dir] = current
      return current
    end
    current = vim.fn.fnamemodify(current, ':h')
  end

  -- If we hit the filesystem root without finding anything, we cache the nil
  -- result to prevent useless re-walking in the future.
  --
  self.git_roots[dir] = nil
  return nil
end

---Get all gitignore files that affect a directory
---@param dir string Directory path
---@return string[] gitignore_files List of gitignore file paths
function MiniFilesGitignore:get_gitignore_files(dir)
  local git_root = self:find_git_root(dir)
  -- If we aren't in a git repository, the concept of gitignore files implies
  -- nothing.
  --
  if not git_root then return {} end

  local gitignore_files = {}
  local current = dir

  -- Git rules cascade. We need to collect every `.gitignore` from the current
  -- directory up to the root of the repository. Order matters here, but we
  -- collect them simply for change detection (watcher setup), not for parsing
  -- rules ourselves (we let `git` do the heavy lifting there).
  --
  while current and #current >= #git_root do
    local gitignore_path = current .. '/.gitignore'
    if uv.fs_stat(gitignore_path) then table.insert(gitignore_files, gitignore_path) end

    if current == git_root then break end
    current = vim.fn.fnamemodify(current, ':h')
  end

  return gitignore_files
end

---Check if cache entry is valid
---@param dir string Directory path
---@return boolean valid Whether cache is valid
function MiniFilesGitignore:is_cache_valid(dir)
  local cache_entry = self.cache[dir]
  if not cache_entry then return false end

  -- First check the explicit expiration (TTL).
  --
  if cache_entry.expires_at < uv.hrtime() / 1e9 then
    self.logger:debug('cache expired for directory: %s', dir)
    return false
  end

  -- Even if the TTL is good, the underlying rules might have changed. We
  -- verify the mtime of every gitignore file that affected this directory when
  -- the cache was created. If any timestamp drifted, the cache is poison.
  --
  for file_path, cached_mtime in pairs(cache_entry.gitignore_files) do
    local stat = uv.fs_stat(file_path)
    local current_mtime = stat and stat.mtime.sec or 0
    if current_mtime ~= cached_mtime then
      self.logger:debug('gitignore file changed: %s (cached: %d, current: %d)', file_path, cached_mtime, current_mtime)
      return false
    end
  end

  return true
end

---Cleanup expired cache entries
function MiniFilesGitignore:cleanup_cache()
  local current_time = uv.hrtime() / 1e9
  local removed_count = 0
  local cache_count = 0

  -- Sweep for expired entries.
  --
  for dir, cache_entry in pairs(self.cache) do
    if cache_entry.expires_at < current_time then
      self.cache[dir] = nil
      removed_count = removed_count + 1
    else
      cache_count = cache_count + 1
    end
  end

  -- Enforce the hard limit on cache size. We use a simple strategy: sort by
  -- timestamp and evict the oldest entries until we are back under the limit.
  --
  if cache_count > self.config.max_cache_size then
    local entries = {}
    for dir, cache_entry in pairs(self.cache) do
      table.insert(entries, { dir = dir, timestamp = cache_entry.timestamp })
    end

    -- Remove oldest 20% to avoid constant thrashing. If we just removed 1 we
    -- would likely be back here in a few milliseconds.
    --
    table.sort(entries, function(a, b) return a.timestamp < b.timestamp end)

    local to_remove = math.max(1, math.floor(self.config.max_cache_size * 0.2))
    to_remove = math.min(to_remove, #entries)

    for i = 1, to_remove do
      self.cache[entries[i].dir] = nil
      removed_count = removed_count + 1
    end

    -- Lua does not always release memory back to the OS immediately. If we
    -- dumped a significant chunk of data we force a collection step.
    --
    if removed_count > 50 then
      self.logger:debug('cleaned up %d expired cache entries', removed_count)
      collectgarbage('step', 1000)
    end
  end
end

---Check if file is ignored by gitignore rules
---@param dir string Directory path
---@param file_path string File path to check
---@return boolean ignored Whether file is ignored
function MiniFilesGitignore:is_file_ignored(dir, file_path)
  -- If we don't have a valid cache, we treat it as a miss and default to "not
  -- ignored". This avoids blocking the UI to check a single file if the batch
  -- process hasn't finished yet.
  --
  if not self:is_cache_valid(dir) then
    self.metrics.cache_misses = self.metrics.cache_misses + 1
    return false
  end

  self.metrics.cache_hits = self.metrics.cache_hits + 1
  return self.cache[dir].ignored[file_path] or false
end

---Process files synchronously using git check-ignore
---@param dir string Directory path
---@param file_paths string[] List of file paths to check
---@return table<string, boolean> ignored_map Map of file paths to ignored status
function MiniFilesGitignore:process_files_sync(dir, file_paths)
  local start_time = uv.hrtime()
  self.metrics.sync_operations = self.metrics.sync_operations + 1

  local git_root = self:find_git_root(dir)
  if not git_root then return {} end

  -- We use a temporary file to feed paths to `git check-ignore --stdin`. Piping
  -- directly to stdin via `io.popen` in Lua is tricky to get right, and
  -- creating a temp file is a robust, if slightly slower, alternative.
  --
  local temp_file = vim.fn.tempname()
  local file_handle = io.open(temp_file, 'w')
  if not file_handle then
    self.logger:error('failed to create temporary file: %s', temp_file)
    return {}
  end

  for _, file_path in ipairs(file_paths) do
    file_handle:write(file_path .. '\n')
  end
  file_handle:close()

  -- Execute git. We must change directory to the git root first because
  -- check-ignore behaves most predictably when run from the root.
  --
  local cmd = string.format('cd %s && git check-ignore --stdin < %s', vim.fn.shellescape(git_root), vim.fn.shellescape(temp_file))

  local result = vim.fn.system(cmd)
  vim.fn.delete(temp_file)

  -- The output contains only the paths that match an ignore rule. We map
  -- them to true for constant-time lookup.
  --
  local ignored_map = {}

  -- Check shell_error. git check-ignore returns 1 if *any* file is ignored so
  -- strictly speaking 0 and 1 are both "success" in terms of execution but we
  -- only care about parsing the stdout.
  --
  if vim.v.shell_error == 0 or vim.v.shell_error == 1 then
    for ignored_file in result:gmatch '[^\n]+' do
      ignored_map[ignored_file] = true
    end
  end

  local elapsed = (uv.hrtime() - start_time) / 1e6 -- Convert to milliseconds
  self.metrics.total_processing_time = self.metrics.total_processing_time + elapsed
  self.logger:debug('processed %d files synchronously in %.2fms', #file_paths, elapsed)

  return ignored_map
end

-- Process files asynchronously using git check-ignore.
--
function MiniFilesGitignore:process_files_async(dir, file_paths, callback, is_prefetch)
  -- If we are at capacity and this is a prefetch job we drop it to prevents
  -- recursive fan-out from eating 30GB RAM. That is, we can live without the
  -- prefetch data as we will just trigger a sync load if we actually visit
  -- that directory.
  --
  if is_prefetch and self.active_jobs_count >= self.config.max_concurrent_jobs then
    self.metrics.dropped_jobs = self.metrics.dropped_jobs + 1
    return
  end

  -- Even for main jobs (current directory) if we are dangerously
  -- overloaded we bail out to protect the editor process.
  --
  if self.active_jobs_count >= (self.config.max_concurrent_jobs * 2) then
    self.metrics.dropped_jobs = self.metrics.dropped_jobs + 1
    callback {}
    return
  end

  local start_time = uv.hrtime()
  local git_root = self:find_git_root(dir)
  if not git_root then
    callback {}
    return
  end

  self.active_jobs_count = self.active_jobs_count + 1
  self.metrics.async_operations = self.metrics.async_operations + 1

  local ignored_files = {}
  -- For the async path, we use `vim.fn.jobstart` to accumulate stdout without
  -- blocking the editor.
  --
  local job_config = {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= '' then ignored_files[line] = true end
        end
      end
    end,
    on_exit = function(job_id, _)
      -- Cleanup the job pool tracking.
      --
      self.active_jobs_count = self.active_jobs_count - 1
      if self.job_pool[job_id] then self.job_pool[job_id] = nil end

      local elapsed = (uv.hrtime() - start_time) / 1e6
      self.metrics.total_processing_time = self.metrics.total_processing_time + elapsed
      self.logger:debug('processed %d files asynchronously in %.2fms (exit: %d)', #file_paths, elapsed, exit_code)
      callback(ignored_files)
    end,
  }

  local job_id = vim.fn.jobstart({ 'git', '-C', git_root, 'check-ignore', '--stdin' }, job_config)

  if job_id > 0 then
    self.job_pool[job_id] = { dir = dir, start_time = start_time }

    -- Pump the data into stdin.
    --
    vim.fn.chansend(job_id, table.concat(file_paths, '\n'))
    vim.fn.chanclose(job_id, 'stdin')
  else
    self.active_jobs_count = self.active_jobs_count - 1
    callback {}
  end
end

---Cache gitignore results for directory
---@param dir string Directory path
---@param ignored_map table<string, boolean> Map of file paths to ignored status
function MiniFilesGitignore:cache_results(dir, ignored_map)
  local gitignore_files = self:get_gitignore_files(dir)
  local gitignore_mtimes = {}

  -- We capture the mtime of every gitignore file involved in this decision to
  -- detect if the rules change later.
  --
  for _, file_path in ipairs(gitignore_files) do
    local stat = uv.fs_stat(file_path)
    gitignore_mtimes[file_path] = stat and stat.mtime.sec or 0
  end

  local current_time = uv.hrtime() / 1e9
  self.cache[dir] = {
    ignored = ignored_map,
    timestamp = current_time,
    gitignore_files = gitignore_mtimes,
    expires_at = current_time + self.config.cache_ttl,
  }

  self.logger:debug(
    'cached results for directory: %s (%d files, %d ignored)',
    dir,
    vim.tbl_count(ignored_map),
    vim.tbl_count(vim.tbl_filter(function(v) return v end, ignored_map))
  )

  self:cleanup_cache()
end

---Setup filesystem watcher for directory
---@param dir string Directory path
function MiniFilesGitignore:setup_fs_watcher(dir)
  if self.fs_watchers[dir] then return end

  -- Limit watchers to prevent file handle exhaustion.
  --
  if vim.tbl_count(self.fs_watchers) > 50 then return end
  local gitignore_files = self:get_gitignore_files(dir)
  if #gitignore_files == 0 then return end

  -- We attach listeners to the actual `.gitignore` files. If one changes, we
  -- have to assume the world has changed for any directory "below" or
  -- "adjacent" to it in the hierarchy.
  --
  for _, gitignore_file in ipairs(gitignore_files) do
    if not self.fs_watchers[gitignore_file] then
      local handle = uv.new_fs_event()
      if handle then
        self.fs_watchers[gitignore_file] = handle

        uv.fs_event_start(handle, gitignore_file, {}, function(err, _, events)
          if not err then
            vim.schedule(function() self.logger:debug('gitignore file changed: %s (events: %s)', gitignore_file, vim.inspect(events)) end)

            -- Invalidation strategy: iterate all cached directories. If a cached
            -- directory path sits inside the directory containing the changed
            -- .gitignore, kill the cache.
            --
            local gitignore_dir = vim.fn.fnamemodify(gitignore_file, ':h')
            for cached_dir, _ in pairs(self.cache) do
              if cached_dir:sub(1, #gitignore_dir) == gitignore_dir then
                self.cache[cached_dir] = nil
                vim.schedule(function() self.logger:debug('invalidated cache for directory: %s', cached_dir) end)
              end
            end

            -- Trigger a UI refresh if the explorer isn't busy.
            --
            vim.schedule(function()
              if not MiniFiles.is_busy then
                MiniFiles.refresh {
                  content = {
                    sort = self.current_sort,
                    filter = self.current_filter,
                  },
                }
              end
            end)
          end
        end)
      end
    end
  end
end

---Prefetch gitignore data for subdirectories
---@param parent_dir string Parent directory path
---@param depth number Current depth (for recursion limit)
function MiniFilesGitignore:prefetch_subdirectories(parent_dir, depth)
  if depth <= 0 or depth > self.config.prefetch_depth then return end

  -- Optimization. Do not scan if we are already busy. The user is moving
  -- fast so let's just keep up with the visible items.
  --
  if self.active_jobs_count >= self.config.max_concurrent_jobs then return end

  local handle = uv.fs_scandir(parent_dir)
  if not handle then return end

  local subdirs = {}
  while true do
    local name, type = uv.fs_scandir_next(handle)
    if not name then break end

    if type == 'directory' and not name:match '^%.' then
      local subdir_path = parent_dir .. '/' .. name
      table.insert(subdirs, subdir_path)
    end
  end

  -- We fire off async jobs for the subdirectories. That is, we want to populate
  -- the cache *before* we expands the folder.
  --
  for _, subdir in ipairs(subdirs) do
    if not self:is_cache_valid(subdir) then
      vim.schedule(function()
        local files = {}
        local sub_handle = uv.fs_scandir(subdir)
        if sub_handle then
          while true do
            local sub_name, _ = uv.fs_scandir_next(sub_handle)
            if not sub_name then break end
            table.insert(files, subdir .. '/' .. sub_name)
          end
          if #files > 0 then
            self:process_files_async(subdir, files, function(ignored_map)
              self:cache_results(subdir, ignored_map)
              self:prefetch_subdirectories(subdir, depth - 1)
            end, true)
          end
        end
      end)
    end
  end
end

---Custom sort function that handles gitignore integration
---@param fs_entries MiniFilesEntry[] List of filesystem entries
---@return MiniFilesEntry[] Sorted and filtered entries
function MiniFilesGitignore:sort_entries(fs_entries)
  -- If we are in the "show everything" state (state == true), we bypass all
  -- logic and return the standard sort.
  --
  if self.state then return MiniFiles.default_sort(fs_entries) end

  if #fs_entries == 0 then return fs_entries end

  local start_time = uv.hrtime()

  -- We group entries by directory to batch the `git check-ignore` calls.
  -- Invoking git once per file would be disastrously slow.
  --
  local dirs_to_process = {}
  local dirs_files = {}

  for _, entry in ipairs(fs_entries) do
    local dir = vim.fn.fnamemodify(entry.path, ':h')
    if not dirs_files[dir] then
      dirs_files[dir] = {}
      if not self:is_cache_valid(dir) then table.insert(dirs_to_process, dir) end
    end
    table.insert(dirs_files[dir], entry.path)
  end

  -- Handle cache misses.
  --
  for _, dir in ipairs(dirs_to_process) do
    local files = dirs_files[dir]

    self:setup_fs_watcher(dir)

    -- We use a heuristic here: if the file count is low, we block
    -- synchronously. The context switch overhead of the async loop is often
    -- higher than just running the command for 10 files. For larger sets, we
    -- must go async to keep the UI responsive.
    --
    if #files <= self.config.sync_threshold then
      local ignored_map = self:process_files_sync(dir, files)
      self:cache_results(dir, ignored_map)
    else
      self:process_files_async(dir, files, function(ignored_map)
        self:cache_results(dir, ignored_map)

        -- Once the data comes back, we have to nudge the view to update.
        --
        vim.schedule(function()
          if not MiniFiles.is_busy then
            MiniFiles.refresh {
              content = {
                sort = self.current_sort,
                filter = self.current_filter,
              },
            }
          end
        end)
      end, false)
    end

    -- Kick off prefetching for the next level down.
    --
    self:prefetch_subdirectories(dir, self.config.prefetch_depth)
  end

  -- Now we actually filter. Note that `is_file_ignored` handles cache lookups.
  -- That is, if we missed the cache above (async pending), it returns false
  -- (not ignored) so the files remain visible until the refresh lands.
  --
  local filtered_entries = vim.tbl_filter(function(entry)
    local dir = vim.fn.fnamemodify(entry.path, ':h')
    return not self:is_file_ignored(dir, entry.path)
  end, fs_entries)

  local elapsed = (uv.hrtime() - start_time) / 1e6
  self.logger:debug('processed %d entries in %.2fms (filtered: %d)', #fs_entries, elapsed, #fs_entries - #filtered_entries)

  return MiniFiles.default_sort(filtered_entries)
end

---Toggle between filtered and unfiltered views
---
function MiniFilesGitignore:toggle_filtering()
  self.state = not self.state

  -- We swap the active functions based on state.
  --
  if self.state then
    self.current_sort = MiniFiles.default_sort
    self.current_filter = MiniFiles.default_filter
    self.logger:info 'switched to unfiltered view (showing all files)'
  else
    self.current_sort = self.initial_sort
    self.current_filter = self.initial_filter
    self.logger:info 'switched to filtered view (respecting gitignore)'
  end

  self:force_refresh()
end

---Force refresh file view
function MiniFilesGitignore:force_refresh()
  -- This requires some explanation. `mini.files` doesn't strictly have a
  -- "redraw" method that accepts new context without side effects. If we just
  -- call refresh with the new sort function, it often no-ops if it thinks
  -- nothing changed.
  --
  -- To bypass this, we apply a "dummy" filter (using a closure) which forces
  -- the internal state to recognize a change. We do it twice with different
  -- values to make `self.current_filter` final transition seen as a change.
  -- It's ugly, but it works.
  --
  local function refresh_with_dummy_filter(char)
    MiniFiles.refresh {
      content = {
        filter = function(fs_entry) return not vim.startswith(fs_entry.name, char) end,
      },
    }
  end

  refresh_with_dummy_filter ';'
  refresh_with_dummy_filter '.'

  MiniFiles.refresh {
    content = {
      sort = self.current_sort,
      filter = self.current_filter,
    },
  }
end

---Cleanup resources
function MiniFilesGitignore:cleanup()
  -- We must be diligent about cleaning up libuv handles, otherwise we leak
  -- file watchers and processes.
  --
  for _, handle in pairs(self.fs_watchers) do
    if handle and not handle:is_closing() then handle:close() end
  end
  self.fs_watchers = {}

  for job_id, _ in pairs(self.job_pool) do
    pcall(vim.fn.jobstop, job_id)
  end
  self.job_pool = {}
  self.cache = {}
end
_G.MiniFilesGitignore = MiniFilesGitignore
return MiniFilesGitignore
