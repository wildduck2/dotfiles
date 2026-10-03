require("full-border"):setup { type = ui.Border.ROUNDED }
local git = require("git")
git:setup { order = 1500 }

-- Dim gitignored names like nvim does; 7 and 99 are git.yazi's ignored and excluded codes
local entity_style = Entity.style
function Entity:style()
	local s = entity_style(self)
	if self._file.is_hovered or not git.dirs then
		return s
	end
	local url = self._file.url
	local repo = git.dirs[tostring(url.base or url.parent)]
	if repo == 99 or (repo and git.repos[repo] and git.repos[repo][tostring(url):sub(#repo + 2)] == 7) then
		return s:patch(ui.Style():fg("#565f89"))
	end
	return s
end

-- Size plus modified time on every row; folders show their size once yazi has counted them
function Linemode:size_and_mtime()
	local time = math.floor(self._file.cha.mtime or 0)
	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == os.date("%Y") then
		time = os.date("%b %d %H:%M", time)
	else
		time = os.date("%b %d  %Y", time)
	end

	local size = self._file:size()
	return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end

Status:children_add(function()
	local h = cx.active.current.hovered
	if not h or ya.target_family() ~= "unix" then
		return ""
	end
	return ui.Line {
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("magenta"),
		":",
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("magenta"),
		" ",
	}
end, 500, Status.RIGHT)
