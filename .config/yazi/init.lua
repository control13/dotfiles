require("folder-rules"):setup()
require("archivemount"):setup()
require("git"):setup()
require("copy-file-contents"):setup({
	append_char = "\n",
	notification = true,
})
require("yatline"):setup({
	show_background = false,

	header_line = {
		left = {
			section_a = {
        			{type = "line", custom = false, name = "tabs", params = {"left"}},
			},
			section_b = {
			},
			section_c = {
			}
		},
		right = {
			section_a = {
        			-- {type = "string", custom = false, name = "date", params = {"%A, %d %B %Y"}},
			},
			section_b = {
        			-- {type = "string", custom = false, name = "date", params = {"%X"}},
			},
			section_c = {
							{type = "coloreds", custom = false, name = "githead"}
			}
		}
	},

	status_line = {
		left = {
			section_a = {
        			{type = "string", custom = false, name = "tab_mode"},
			},
			section_b = {
        			{type = "string", custom = false, name = "hovered_size"},
			},
			section_c = {
        			{type = "string", custom = false, name = "hovered_path"},
        			{type = "coloreds", custom = false, name = "count"},
			}
		},
		right = {
			section_a = {
        			{type = "string", custom = false, name = "cursor_position"},
			},
			section_b = {
        			{type = "string", custom = false, name = "cursor_percentage"},
			},
			section_c = {
        			{type = "string", custom = false, name = "hovered_file_extension", params = {true}},
        			{type = "coloreds", custom = false, name = "permissions"},
			}
		}
	},
})
require("yatline-githead"):setup()
