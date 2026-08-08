local M = {}

function M:peek(job)
	ya.preview_widget(job, {})
end

function M:seek() end

function M:fetch(job)
	return true
end

function M:preload(job)
	return true
end

function M:spot(job) end

return M
