-- Thin wrapper: render the image cache with libvips (fast, low-memory, native
-- heic/avif/jxl + camera RAW), then delegate everything else to the unmodified
-- `mediainfo` plugin so its metadata overlay is preserved. Keeping this separate
-- means `mediainfo.yazi` stays a pristine, upgradeable vendored dependency.
--
-- Flow: vips fills the thumbnail cache first, so mediainfo's own preload finds a
-- populated cache and skips its (ImageMagick/builtin) image generation entirely,
-- while still generating and showing the metadata.

local mediainfo = require("mediainfo")

local M = {}

function M:preload(job)
	require("vips"):preload(job)
	return mediainfo.preload(mediainfo, job)
end

function M:peek(job)
	-- Guarantee the vips cache exists in the peek path too (no race with the
	-- background preloader), then let mediainfo show image + metadata.
	require("vips"):preload(job)
	return mediainfo.peek(mediainfo, job)
end

function M:entry(job)
	return mediainfo.entry(mediainfo, job)
end

return M
