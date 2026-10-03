-- Terminator (VTE) can't show yazi's images, so outside kitty draw them as text with chafa.
-- Inside kitty this hands off to the built-in previewer named in the args (image or video).
local M = {}

local in_kitty = os.getenv("KITTY_WINDOW_ID") ~= nil

local function builtin(job)
	return require(job.args[1] or "image")
end

function M:peek(job)
	if in_kitty then
		return builtin(job):peek(job)
	end

	local src = tostring(job.file.path or job.file.url)
	if job.args[1] == "video" then
		local ok, err = builtin(job):preload(job)
		if not ok or err then
			return ya.preview_widget(job, err)
		end
		src = tostring(ya.file_cache(job))
	end

	local out, err = Command("chafa")
		:arg({ "-f", "symbols", "--animate=off", "--polite=on", "-s", job.area.w .. "x" .. job.area.h, src })
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:output()
	if not out then
		return ya.preview_widget(job, Err("Failed to start `chafa`, error: %s", err))
	elseif not out.status.success then
		return ya.preview_widget(job, Err("`chafa` failed: %s", out.stderr))
	end
	ya.preview_widget(job, ui.Text.parse(out.stdout):area(job.area))
end

function M:seek(job)
	builtin(job):seek(job)
end

function M:preload(job)
	if in_kitty then
		return builtin(job):preload(job)
	end
	return true
end

return M
