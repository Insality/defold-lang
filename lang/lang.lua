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

local lang_internal = require("lang.lang_internal")

---@class lang
local M = {}


---Is lang module inited
---@type boolean
local INITED = false

---Current language translations
---@type table<string, string> @Contains all current language translations. Key - lang id, Value - translation
local LANG_DICT = nil

-- Persistent storage
---@type lang.state
M.state = nil

---Reset module lang state
function M.reset_state()
	M.state = {
		lang = lang_internal.DEFAULT_LANG
	}
	INITED = false
	LANG_DICT = {}
end
M.reset_state()


---Init Lang module. Load lang file and set current language
function M.init()
	local is_inited = M.set_lang(M.state.lang)
	if not is_inited then
		lang_internal.logger:warn("Can't load lang file, set default lang", M.state.lang)
		M.set_lang(lang_internal.DEFAULT_LANG)
	end
end


---Set logger for lang module. Pass nil to use empty logger
---@param logger_instance lang.logger|nil
function M.set_logger(logger_instance)
	lang_internal.logger = logger_instance or lang_internal.empty_logger
end


---Set current language
---@param lang string @current language code (en, jp, ru, etc.)
---@return boolean @is language changed
function M.set_lang(lang)
	local previous_lang = M.state.lang
	local previous_loaded_lang = INITED and previous_lang or nil
	if previous_loaded_lang == lang then
		return false
	end

	local lang_path = lang_internal.LOCALES_PATH .. lang .. ".json"
	local lang_data = lang_internal.load_json(lang_path)

	if not lang_data then
		lang_internal.logger:error("Can't load lang file", { path = lang_path })
		return false
	end

	LANG_DICT = lang_data or {}
	INITED = true
	M.state.lang = lang

	lang_internal.logger:info("Lang changed", { previous_lang = previous_loaded_lang, lang = lang })

	return true
end


---Set next language from list
---@return string @next language code
function M.set_next_lang()
	local current_lang = M.get_lang()
	local all_langs = M.get_langs()
	local current_index = lang_internal.index_of(all_langs, current_lang) or 1

	current_index = current_index + 1
	if current_index > #all_langs then
		current_index = 1
	end

	M.set_lang(all_langs[current_index])

	return all_langs[current_index]
end


---Get current language
---@return string @Current language code
function M.get_lang()
	return M.state.lang
end


---Get default language
---@return string @Default language code
function M.get_default_lang()
	return lang_internal.DEFAULT_LANG
end


---Get translation for text id
---@param text_id string @text id from your localization
---@return string @Translated text
function M.txt(text_id)
	return LANG_DICT[text_id] or text_id or ""
end


---Get random translation for text id, split by \n symbol
---@param text_id string @text id from your localization
---@return string @translated text
function M.txr(text_id)
	local texts = lang_internal.split(LANG_DICT[text_id], "\n")
	return texts[math.random(1, #texts)]
end


---Get translation for text id with params
---@param text_id string Text id from your localization
---@vararg string|number Params for translation
---@return string @Translated text
function M.txp(text_id, ...)
	return string.format(M.txt(text_id), ...)
end


---Check is translation with text_id exist
---@param text_id string text id from your localization
---@return boolean @Is translation exist for text_id
function M.is_exist(text_id)
	return (not not LANG_DICT[text_id])
end


---Return list of available languages
---@return string[] @List of available languages
function M.get_langs()
	return lang_internal.LANGS
end


return M
