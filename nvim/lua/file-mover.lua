local uv = vim.uv or vim.loop

local M = {}

-- Get device ID of a path
function M.get_device_id(path)
  local stat = uv.fs_stat(path)
  if stat then return stat.dev end
  -- For directory paths that might not exist
  local dir = path:match "(.*)/" or "."
  local dir_stat = uv.fs_stat(dir)
  return dir_stat and dir_stat.dev or nil
end

-- Check if move would be cross-device
function M.is_cross_device(src, dest)
  local src_dev = M.get_device_id(src)
  local dest_dev = M.get_device_id(dest)

  if src_dev and dest_dev then return src_dev ~= dest_dev end
  return false -- Assume same device if can't determine
end

-- Copy file with progress (for large files)
function M.copy_file_with_progress(src, dest, callback)
  local chunk_size = 1024 * 1024 -- 1MB chunks
  local total_copied = 0

  uv.fs_open(src, "r", 438, function(open_err, src_fd)
    if open_err then
      if callback then callback(open_err, nil) end
      return
    end

    uv.fs_fstat(src_fd, function(stat_err, stat)
      if stat_err or not stat then
        uv.fs_close(src_fd)
        if callback then callback(stat_err, nil) end
        return
      end

      local total_size = stat.size

      uv.fs_open(dest, "w", 438, function(open_err2, dest_fd)
        if open_err2 then
          uv.fs_close(src_fd)
          if callback then callback(open_err2, nil) end
          return
        end

        local function copy_chunk(offset)
          local size = math.min(chunk_size, total_size - offset)
          if size <= 0 then
            uv.fs_close(src_fd)
            uv.fs_close(dest_fd)
            if callback then callback(nil, total_copied) end
            return
          end

          uv.fs_read(src_fd, size, offset, function(read_err, data)
            if read_err then
              uv.fs_close(src_fd)
              uv.fs_close(dest_fd)
              if callback then callback(read_err, nil) end
              return
            end

            uv.fs_write(dest_fd, data, -1, function(write_err, written)
              if write_err then
                uv.fs_close(src_fd)
                uv.fs_close(dest_fd)
                if callback then callback(write_err, nil) end
                return
              end

              total_copied = total_copied + written
              if callback then callback("progress", total_copied, total_size) end
              copy_chunk(offset + size)
            end)
          end)
        end

        copy_chunk(0)
      end)
    end)
  end)
end

-- Main move function
function M.move(src, dest, options)
  options = options or {}
  local force = options.force or false
  local on_progress = options.on_progress or nil
  local async = options.async or false

  -- Validation
  local src_stat = uv.fs_stat(src)
  if not src_stat then
    vim.notify("Source does not exist: " .. src, vim.log.levels.ERROR)
    return false
  end

  if not src_stat.type == "file" and not src_stat.type == "link" then
    vim.notify("Source is not a regular file: " .. src, vim.log.levels.ERROR)
    return false
  end

  -- Check destination
  local dest_stat = uv.fs_stat(dest)
  if dest_stat and not force then
    vim.notify("Destination exists. Use force=true to overwrite", vim.log.levels.WARN)
    return false
  else
    -- If force and destination exists, delete it first
    if dest_stat and force then uv.fs_unlink(dest) end
  end

  -- Check for cross-device
  local cross_device = M.is_cross_device(src, dest)

  if cross_device then
    vim.notify("Moving across devices - copying then deleting", vim.log.levels.INFO)

    if async then
      M.copy_file_with_progress(src, dest, function(err, copied, total)
        if err then
          if err == "progress" then
            if on_progress then
              local percent = (copied / total) * 100
              on_progress(copied, total, percent)
            end
          elseif err then
            vim.notify("Copy failed: " .. err, vim.log.levels.ERROR)
          else
            -- Copy complete, delete source
            uv.fs_unlink(src, function(unlink_err)
              if unlink_err then
                vim.notify("Warning: copied but could not delete source: " .. unlink_err, vim.log.levels.WARN)
              else
                vim.notify("File moved successfully across devices", vim.log.levels.INFO)
              end
            end)
          end
        end
      end)
      return true
    else
      -- Synchronous cross-device move
      local data = uv.fs_read(src, src_stat.size, 0)
      if not data then
        vim.notify("Failed to read source", vim.log.levels.ERROR)
        return false
      end

      local dest_fd = uv.fs_open(dest, "w", 438)
      if not dest_fd then
        vim.notify("Failed to open destination", vim.log.levels.ERROR)
        return false
      end

      uv.fs_write(dest_fd, data, -1)
      uv.fs_close(dest_fd)
      uv.fs_unlink(src)
      vim.notify("File moved across devices", vim.log.levels.INFO)
      return true
    end
  else
    -- Same device - use rename
    local result, err = uv.fs_rename(src, dest)
    if result then
      vim.notify("File moved successfully", vim.log.levels.INFO)
      return true
    else
      vim.notify("Move failed: " .. err, vim.log.levels.ERROR)
      return false
    end
  end
end

-- Convenience wrapper
function M.move_sync(src, dest, force) return M.move(src, dest, { force = force, async = false }) end

function M.move_async(src, dest, force, progress_callback)
  return M.move(src, dest, {
    force = force,
    async = true,
    on_progress = progress_callback,
  })
end
return M
