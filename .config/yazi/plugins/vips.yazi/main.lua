local M = {}

local TILE = 32
local CHECKER = (os.getenv("HOME") or "") .. "/.config/yazi/plugins/vips.yazi/checker.png"

-- Thumbnailer using libvips. Backend for the mediainfo plugin (avif/heic/jxl, svg,
-- camera RAW). No `peek`: mediainfo stays the previewer and renders this cache with its
-- metadata overlay. Transparent images are composited over a gray checkerboard so both
-- light and dark content stays visible on a dark terminal; opaque images take the fast
-- single-command path.

local function run(args)
	local output = Command("vips"):arg(args):stdout(Command.PIPED):stderr(Command.PIPED):output()
	if output and output.status.success then
		return output
	end
	return nil, output and tostring(output.stderr) or "failed to start `vips`"
end

local function header(field, path)
	local o = Command("vipsheader"):arg({ "-f", field, path }):stdout(Command.PIPED):stderr(Command.PIPED):output()
	if o and o.status.success then
		return tonumber((tostring(o.stdout):gsub("%s+", "")))
	end
	return nil
end

-- Single command: thumbnail straight to a JPEG on stdout. `bg` (optional) flattens any
-- transparency onto that gray level; nil keeps the libvips default (fine for opaque).
local function fast_path(url, box, q, bg, cache)
	local output, err = run({
		"thumbnail",
		url,
		".jpg[Q=" .. q .. (bg and (",background=" .. bg) or "") .. "]",
		box,
	})
	if not output then
		return false, Err("`vips thumbnail` failed: %s", err)
	end
	return fs.write(cache, output.stdout) and true or false
end

function M:preload(job)
	local cache = ya.file_cache(job)
	if not cache or fs.cha(cache) then
		return true
	end

	local url = tostring(job.file.url)
	local q = tostring(rt.preview.image_quality)
	local box = tostring(rt.preview.max_width) .. "x" .. tostring(rt.preview.max_height)

	-- Cheap alpha probe from the source header (no full decode).
	local bands = header("bands", url)
	if not (bands == 2 or bands == 4) then
		return fast_path(url, box, q, nil, cache) -- opaque: fast path
	end

	-- Checkerboard path needs the shipped tile; otherwise flatten onto light gray so
	-- both light and dark content stays visible.
	if not fs.cha(Url(CHECKER)) then
		return fast_path(url, box, q, 200, cache)
	end

	local base = tostring(cache)
	local tmp = Url(base .. ".tmp.png")
	local bgfull = Url(base .. ".bgf.png")
	local bg = Url(base .. ".bg.png")
	local function cleanup()
		fs.remove("file", tmp)
		fs.remove("file", bgfull)
		fs.remove("file", bg)
	end

	-- 1) Alpha-preserving thumbnail to a temp PNG.
	if not run({ "thumbnail", url, tostring(tmp), box }) then
		cleanup()
		return fast_path(url, box, q, 200, cache)
	end
	local w, h = header("width", tostring(tmp)), header("height", tostring(tmp))
	if not w or not h then
		cleanup()
		return fast_path(url, box, q, 200, cache)
	end

	-- 2) Tile the checker to cover, crop to the thumbnail size.
	local nx, ny = math.ceil(w / TILE), math.ceil(h / TILE)
	if
		not run({ "replicate", CHECKER, tostring(bgfull), tostring(nx), tostring(ny) })
		or not run({ "crop", tostring(bgfull), tostring(bg), "0", "0", tostring(w), tostring(h) })
	then
		cleanup()
		return fast_path(url, box, q, 200, cache)
	end

	-- 3) Composite the image over the checker, write JPEG to the cache.
	local output = run({ "composite2", tostring(bg), tostring(tmp), ".jpg[Q=" .. q .. "]", "over" })
	cleanup()
	if not output then
		return fast_path(url, box, q, 200, cache)
	end
	return fs.write(cache, output.stdout) and true or false
end

return M
