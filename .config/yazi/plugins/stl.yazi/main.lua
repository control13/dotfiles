local M = {}

function M:peek(job)
	local cache = ya.file_cache(job)
	if not cache then
		return
	end

	if not self:preload(job) then
		return
	end

--	local t = io.open(tostring(cache), "rb")
--	if t == nil then return 0 end
--	local thumb = t:read("*all")
--	t:close()

	ya.image_show(cache, job.area)
	ya.preview_widgets(job, {})
end

function M:seek() end

function M:preload(job)
	local cache = ya.file_cache(job)
	if not cache or fs.cha(cache) then
		return true
	end
    local prev_size = math.min(rt.preview.max_width, rt.preview.max_height)
	local output = Command("stl-thumb")
		:arg({"-s", tostring(prev_size), tostring(job.file.url), "-" })
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:output()

	-- yazi 0.2.5
	local function check_output_v025()
		if output.status:success() then
			return true
		end
		return false
	end

	-- yazi 0.3
	local function check_output_v03()
		if output.status.success then
			return true
		end
		return false
	end

	if pcall(check_output_v03) then
	elseif pcall(check_output_v025) then
	else
		return false, Err(
			"Could not obtain thumbnail for " .. tostring(job.file.url)
			.. ". stl-thumb output: " .. tostring(output.stderr)
		)
	end

    --local thumb = string.gsub(tostring(output.stdout), "\n", "")
	-- local thumb = tostring(output.stdout)
	return fs.write(cache, output.stdout) and true or false
end

return M

