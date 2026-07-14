-- Text previewer that renders a few extra file types through CLI tools, chosen by the
-- plugin argument (see yazi.toml): `html` (html2text), `ipynb` (jq), `sqlite` (sqlite3).
-- Output is paginated with job.skip and scrolled via M:seek. On any failure it falls back
-- to yazi's built-in `code` previewer (raw text), i.e. a controlled fallback.

local M = {}

local IPYNB_FILTER =
	[[.cells[] | if .cell_type=="markdown" then (.source|join("")) else "```\n"+(.source|join(""))+"```" end]]

local function build(action, path)
	if action == "html" then
		return "html2text", { path }
	elseif action == "ipynb" then
		return "jq", { "-r", IPYNB_FILTER, path }
	elseif action == "sqlite" then
		return "sqlite3", { path, ".schema" }
	end
end

function M:peek(job)
	local exe, args = build(job.args[1], tostring(job.file.url))
	if not exe then
		return require("code"):peek(job)
	end

	local output = Command(exe):arg(args):stdout(Command.PIPED):stderr(Command.PIPED):output()
	if not output or not output.status.success or tostring(output.stdout) == "" then
		return require("code"):peek(job) -- controlled fallback to raw text
	end

	local limit = job.area.h
	local rows = {}
	local n = 0
	for line in (tostring(output.stdout) .. "\n"):gmatch("(.-)\n") do
		n = n + 1
		if n > job.skip then
			rows[#rows + 1] = line
			if #rows >= limit then
				break
			end
		end
	end

	-- Scrolled past the end: clamp back so the last page stays visible.
	if job.skip > 0 and #rows == 0 then
		return ya.emit("peek", { math.max(0, job.skip - limit), only_if = job.file.url, upper_bound = true })
	end

	local text = table.concat(rows, "\n"):gsub("\t", string.rep(" ", rt.preview.tab_size))
	ya.preview_widget(job, { ui.Text.parse(text):area(job.area) })
end

function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		ya.emit("peek", {
			math.max(0, cx.active.preview.skip + job.units),
			only_if = job.file.url,
		})
	end
end

return M
