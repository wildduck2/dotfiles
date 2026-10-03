-- Same calculation yazi's spotter does on Tab, run as a fetcher so every folder row gets its size
local function fetch(_, job)
	local trails = {}
	for _, file in ipairs(job.files) do
		local it, size = fs.calc_size(file.url), 0
		while it do
			local next = it:recv()
			if not next then
				local t = file.url.trail
				trails[t] = trails[t] or {}
				trails[t][file.url.key] = size
				break
			end
			size = size + next
		end
	end

	for trail, sizes in pairs(trails) do
		ya.emit("update_files", { op = fs.op("size", { url = trail, sizes = sizes }) })
	end
	return require("noop"):fetch(job)
end

return { fetch = fetch }
