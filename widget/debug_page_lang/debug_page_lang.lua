local lang = require("lang.lang")

local M = {}


---@param druid table druid instance
---@param properties_panel widget.properties_panel druid properties panel instance
function M.render_properties_panel(druid, properties_panel)
	properties_panel:next_scene()
	properties_panel:set_header("Lang Panel")

	properties_panel:add_text(function(text)
		text:set_text_property("Current Language")
		text:set_text_value(lang.get_lang())
	end)

	properties_panel:add_left_right_selector(function(left_right_selector)
		left_right_selector:set_text("Langs")
		left_right_selector:set_array_type(lang.get_langs(), true)
		left_right_selector:set_value(lang.get_lang())
		left_right_selector.on_change_value:subscribe(function(value)
			lang.set_lang(value)
			properties_panel.is_dirty = true
		end)
	end)

	properties_panel:add_button(function(button)
		button:set_text_property("Lang Data")
		button:set_text_button("Inspect")
		button.button.on_click:subscribe(function()
			properties_panel:next_scene()
			properties_panel:set_header("Lang State")
			properties_panel:render_lua_table(lang.get_lang_table())
		end)
	end)
end


return M
