local M = {}

-- Fast, low-memory thumbnailer using libvips. Used by the mediainfo plugin as the
-- image backend for avif/heic/jxl (replacing ImageMagick). No `peek` needed:
-- mediainfo stays the previewer and renders this cache with its metadata overlay.
function M:preload(job)
	local cache = ya.file_cache(job)
	if not cache or fs.cha(cache) then
		return true
	end

	local output, err = Command("vips")
		:arg({
			"thumbnail",
			tostring(job.file.url),
			-- Leading dot = write JPEG to stdout. libvips auto-flattens alpha on jpegsave.
			-- No `strip` so ICC/color profile survives (matters for wide-gamut heic).
			".jpg[Q=" .. tostring(rt.preview.image_quality) .. "]",
			-- Fit within max_width x max_height, keep aspect ratio.
			tostring(rt.preview.max_width) .. "x" .. tostring(rt.preview.max_height),
		})
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:output()

	if not output then
		return false, Err("Failed to start `vips`: %s", err)
	elseif not output.status.success then
		return false, Err("`vips` exited with error: %s", output.stderr)
	end

	return fs.write(cache, output.stdout) and true or false
end

return M
