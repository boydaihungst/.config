local TEXT =
	"ÁÀẠÃẢ ÂẤẦẬẪẨ ĂẮẰẶẴẲ\nÉÈẸẼẺ ÊẾỀỆỄỂ ÍÌỊĨỈ\nÓÒỌÕỎ ÔỐỒỘỖỔ ƠỚỜỢỠỞ\nÚÙỤŨỦ ƯỨỪỰỮỬ\nABCDEFGHIJKLM\nNOPQRSTUVWXYZ\náàạãả âấầậẫẩ ăắằặẵẳ\néèẹẽẻ êếềệễể íìịĩỉ\nóòọõỏ ôốồộỗổ ơớờợỡở\núùụũủ ưứừựữ\nabcdefghijklm\nnopqrstUvwxyz\n1234567890\n!@%(){}[]"

local M = {}

function M:peek(job)
	local start, cache = os.clock(), ya.file_cache(job)
	if not cache or not self:preload(job) then
		return
	end

	ya.sleep(math.max(0, (rt.preview.image_delay / 1000 + start - os.clock())))
	ya.image_show(cache, job.area)
	ya.preview_widget(job, {})
end

function M:seek(job) end

function M:preload(job)
	local cache = ya.file_cache(job)
	if not cache or fs.cha(cache) then
		return true
	end

	local child, code = Command("magick"):arg({
		"-size",
		"960x900",
		"-gravity",
		"center",
		"-font",
		tostring(job.file.url),
		"-pointsize",
		"50",
		"xc:none",
		"-fill",
		"#BCC4C9",
		"-annotate",
		"+0+0",
		TEXT,
		"PNG:" .. tostring(cache),
	}):spawn()

	if not child then
		return false
	end

	local status = child:wait()
	return status and status.success and true or false
end
return M
