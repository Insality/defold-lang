--- Lang localization helper module
--- Call lang.init() to init module to load last used or default language
--- With saver module use saver.bind_save_state("lang", lang.state) to load lang state to save
--- To load in other way - replace state table before lang.init()
--- Use lang.set_lang("en") to change language
--- Use lang.set_next_lang() to change language to next in list
--- Use lang.txt("key") to get translation
--- Use lang.txr("key") to get random translation, split by \n symbol
--- Use lang.txp("key", "param1", "param2") to get translation with params (Use %s in translation)
--- Use lang.is_exist("key") to check is translation exist
--- Use lang.get_langs() to get list of available languages
--- Use lang.load_langs("pack_id", langs, on_lang_changed) to add locale paths at runtime

local lang_internal = require("lang.internal.lang_internal")
local lang_registry = require("lang.internal.lang_registry")
local logger = require("lang.internal.lang_logger")

---@class lang
local M = {}


---@class lang.state
---@field lang string current language name (en, jp, ru, etc.)

---@class lang.data
---@field path string|table|nil Lua table, json or csv path, ex: "/resources/lang/en.json", "/resources/lang/en.csv"
---@field id string Language code, ex: "en". If csv file, it's a header name
---@field loader function|nil Optional async loader function with signature: loader(path, on_success, on_error)

-- Persistent storage
---@type lang.state
M.state = nil


---Call this to initialize lang module
---@param available_langs lang.data[] List of { id = "en", path = "/locales/en.json" }
---@param lang_on_start string? Language code to set on start, override saved language
function M.init(available_langs, lang_on_start)
	if not available_langs or #available_langs == 0 then
		logger:error("No available languages provided to init")
		return
	end

	lang_registry.setup_langs(available_langs)

	local default_lang = available_langs[1].id
	local system_lang_raw = lang_internal.SYSTEM_LANG
	local system_lang = lang_registry.is_lang_available(system_lang_raw) and system_lang_raw or nil
	local target_lang = lang_on_start or M.state.lang or system_lang or default_lang

	if not lang_registry.is_lang_available(target_lang) then
		logger:warn("Target language not available, falling back to default", {
			target_lang = target_lang,
			default_lang = default_lang
		})
		target_lang = default_lang
	end

	M.set_lang(target_lang)
end


---Load additional locale pack and refresh current language
---@param pack_id string Pack id for future unload
---@param langs lang.data[] List of { id = "en", path = "/locales/en.json" }
---@param on_lang_changed function?
function M.load_langs(pack_id, langs, on_lang_changed)
	if not pack_id then
		logger:error("Pack id cannot be nil")
		return
	end

	if not langs or #langs == 0 then
		logger:error("No languages provided to load_langs")
		return
	end

	lang_registry.add_pack(pack_id, langs)
	M.set_lang(M.state.lang, on_lang_changed)
end


---Set current language
---@param lang_id string current language code (en, jp, ru, etc.)
---@param on_lang_changed function?
function M.set_lang(lang_id, on_lang_changed)
	if not lang_id then
		logger:error("Language id cannot be nil")
		return
	end

	if not lang_registry.is_lang_available(lang_id) then
		logger:error("Lang not found", lang_id)
		return
	end

	local previous_lang = M.state.lang
	lang_registry.load_lang(lang_id, function(loaded_lang_id)
		M.state.lang = loaded_lang_id
		logger:info("Lang changed", { previous_lang = previous_lang, lang = loaded_lang_id })
		if on_lang_changed then
			on_lang_changed()
		end
	end)
end


---Set next language from lang list and return it's code
---@param on_lang_changed function?
---@return string lang_code The language code being switched to
function M.set_next_lang(on_lang_changed)
	local next_lang = M.get_next_lang()
	M.set_lang(next_lang, on_lang_changed)
	return next_lang
end


---Get next language from lang list and return it's code
---@return string lang_code next language code
function M.get_next_lang()
	local current_lang = M.get_lang()
	local all_langs = M.get_langs()
	local current_index = lang_internal.index_of(all_langs, current_lang) or 1

	local next_index = current_index + 1
	if next_index > #all_langs then
		next_index = 1
	end

	return all_langs[next_index]
end


---Get current language
---@return string Current language code
function M.get_lang()
	return M.state.lang
end


---Return list of available languages
---@return string[] langs List of available languages
function M.get_langs()
	return lang_registry.get_langs_order()
end


---Get translation for text id
---@param text_id string text id from your localization
---@return string text ("ui_hello_world") -> "Hello, World!"
function M.txt(text_id)
	local dict = lang_registry.get_dict()
	return dict[text_id] or text_id or ""
end


---Get translation for text id with params
---@param text_id string Text id from your localization
---@vararg string|number Params for translation
---@return string text ("ui_hello_name", "John") -> "Hello, John!"
function M.txp(text_id, ...)
	return string.format(M.txt(text_id), ...)
end


---Get random translation for text id, split by \n symbol
---@param text_id string text id from your localization
---@return string text ("ui_hint") -> "Hint 1" or "Hint 2" or ...
function M.txr(text_id)
	local dict = lang_registry.get_dict()
	if not dict[text_id] then
		return text_id
	end

	local texts = lang_internal.split(dict[text_id], "\n")
	return texts[math.random(1, #texts)]
end


---Check is translation with text_id exist
---@param text_id string text id from your localization
---@return boolean is_exist Is translation exist for text_id
function M.is_exist(text_id)
	return (not not lang_registry.get_dict()[text_id])
end


---Set logger for lang module. Pass nil to use empty logger
---@param logger_instance lang.logger|table|nil
function M.set_logger(logger_instance)
	logger.set_logger(logger_instance)
end


---Reset module lang state
function M.reset_state()
	M.state = {
		lang = lang_internal.SYSTEM_LANG,
	}
	lang_registry.reset()
end


---Get lang module state
---@return lang.state state
function M.get_state()
	return M.state
end


---Set lang module state
---@param state lang.state
function M.set_state(state)
	M.state = state
end


---Get default language
---@return string Default language code
function M.get_default_lang()
	return lang_internal.SYSTEM_LANG
end


---Get current lang table { key = "value" }
---@return table<string, string> lang_table
function M.get_lang_table()
	return lang_registry.get_dict()
end


---Check if language is available
---@param lang_id string Language code to check
---@return boolean is_available True if language is available
function M.is_lang_available(lang_id)
	return lang_registry.is_lang_available(lang_id)
end


M.reset_state()

return M
