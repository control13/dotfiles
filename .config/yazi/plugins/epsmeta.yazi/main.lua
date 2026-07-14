-- Thin wrapper: render EPS/PostScript to a PNG in yazi's cache via Ghostscript, then
-- delegate to the unmodified `mediainfo` plugin so the image is shown together with the
-- original file's metadata overlay. mediainfo (adobe module) skips its own ImageMagick
-- generation because the cache is already populated, and still produces the metadata.
--
-- `job.mime` is forced to application/postscript before delegating so .eps/.epsf/.epsi
-- take mediainfo's adobe path regardless of the mime yazi detected.
--
-- On any Ghostscript failure the cache stays empty, so mediainfo falls back to its own
-- rendering (or metadata-only), i.e. a controlled fallback to the standard preview.

local mediainfo = require("mediainfo")

local M = {}

local function render(job)
	local cache = ya.file_cache(job)
	if not cache or fs.cha(cache) then
		return true
	end

	-- Render to a temp file first, rename on success, so a failed/partial run never
	-- poisons the cache (an empty cache lets mediainfo regenerate; a partial one wouldn't).
	local tmp = tostring(cache) .. ".eps.png"
	local output, err = Command("gs")
		:arg({
			"-q",
			"-dSAFER",
			"-dBATCH",
			"-dNOPAUSE",
			"-dEPSCrop",
			"-sDEVICE=pngalpha",
			"-r200",
			"-sOutputFile=" .. tmp,
			tostring(job.file.url),
		})
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:output()

	if not output then
		return false, Err("Failed to start `gs`: %s", err)
	elseif not output.status.success then
		fs.remove("file", Url(tmp))
		return false, Err("`gs` exited with error: %s", output.stderr)
	end

	os.rename(tmp, tostring(cache))
	return true
end

function M:preload(job)
	render(job)
	job.mime = "application/postscript"
	return mediainfo.preload(mediainfo, job)
end

function M:peek(job)
	render(job)
	job.mime = "application/postscript"
	return mediainfo.peek(mediainfo, job)
end

function M:seek(job)
	return mediainfo.seek(mediainfo, job)
end

function M:entry(job)
	return mediainfo.entry(mediainfo, job)
end

return M
