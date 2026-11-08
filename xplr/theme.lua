xplr.config.node_types.directory = { meta = { icon = "" }, style = { fg = { Indexed = 67 } } }

xplr.config.node_types.file = { meta = { icon = "" }, style = { fg = { Indexed = 67 } } }

xplr.config.node_types.symlink = { meta = { icon = "" }, style = { fg = { Indexed = 67 } } }

xplr.config.node_types.mime_essence = {
	application = {
		-- application/*
		["*"] = { meta = { icon = "a" } },

		-- application/pdf
		pdf = { meta = { icon = "" }, style = { fg = "Blue" } },

		-- application/zip
		zip = { meta = { icon = "" } },
	},
}
