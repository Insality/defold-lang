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
local lang_debug_page = require("lang.lang_debug_page")

---@class lang
local M = {}


---@class lang.state
---@field lang string current language name (en, jp, ru, etc.)

---@class lang.data
---@field path string|table Lua table, json or csv path, ex: "/resources/lang/en.json", "/resources/lang/en.csv"
---@field id string Language code, ex: "en". If csv file, it's a header name
---@field loader function|nil Optional async loader function with signature: loader(path, on_success, on_error)

---Current language translations
---@type table<string, string> Contains all current language translations. Key - lang id, Value - translation
local LANG_DICT = nil

-- Persistent storage
---@type lang.state
M.state = nil

---Order of available languages
---@type lang.data[] In order
local LANGS_ORDER = nil

---Map of available languages for fast lookup
---@type table<string, lang.data> Key is language id, value is lang.data
local AVAILABLE_LANGS_MAP = nil

---Reset module lang state
function M.reset_state()
	M.state = {
		lang = lang_internal.SYSTEM_LANG,
	}
	LANG_DICT = {}
	LANGS_ORDER = {}
	AVAILABLE_LANGS_MAP = {}
end
M.reset_state()


---Check if language exists in available languages
---@param lang_id string Language code to check
---@return boolean True if language exists
local function is_lang_available(lang_id)
	return AVAILABLE_LANGS_MAP[lang_id] ~= nil
end


---Get language data by id
---@param lang_id string Language code
---@return lang.data|nil Language data or nil if not found
local function get_lang_data(lang_id)
	return AVAILABLE_LANGS_MAP[lang_id]
end


---Call this to initialize lang module
---@param available_langs lang.data[] List of { id = "en", path = "/locales/en.json" }
---@param lang_on_start string? Language code to set on start, override saved language
function M.init(available_langs, lang_on_start)
	if not available_langs or #available_langs == 0 then
		lang_internal.logger:error("No available languages provided to init")
		return
	end

	-- Clear previous language data
	LANGS_ORDER = {}
	AVAILABLE_LANGS_MAP = {}
	LANG_DICT = {}

	-- Build available languages list and map
	local default_lang = nil
	for index, lang_data in ipairs(available_langs) do
		table.insert(LANGS_ORDER, lang_data.id)
		AVAILABLE_LANGS_MAP[lang_data.id] = lang_data
		default_lang = default_lang or lang_data.id
	end

	-- Get system language if no specific language is requested
	local system_lang_raw = lang_internal.SYSTEM_LANG
	local system_lang = is_lang_available(system_lang_raw) and system_lang_raw or nil

	-- Determine target language with validation
	local target_lang = lang_on_start or M.state.lang or system_lang or default_lang

	-- Validate the target language exists, fallback to default if not
	if not is_lang_available(target_lang) then
		lang_internal.logger:warn("Target language not available, falling back to default", {
			target_lang = target_lang,
			default_lang = default_lang
		})
		target_lang = default_lang
	end

	M.set_lang(target_lang)
end


---Set logger for lang module. Pass nil to use empty logger
---@param logger_instance lang.logger|table|nil
function M.set_logger(logger_instance)
	lang_internal.logger = logger_instance or lang_internal.empty_logger
end


---Parse and apply language content
---@private
---@param content string File content
---@param lang_id string Language code
---@param is_csv boolean Is CSV format
---@param is_json boolean Is JSON format
---@return boolean success True if successfully applied
local function parse_and_apply_lang(content, lang_id, is_csv, is_json)
	if is_csv then
		local parsed = lang_internal.parse_csv_content(content)
		if not parsed or not parsed[lang_id] then
			return false
		end
		M.set_lang_table(parsed[lang_id])
	elseif is_json then
		local success, result = pcall(json.decode, content)
		if not success then
			return false
		end
		M.set_lang_table(result)
	else
		return false
	end

	M.state.lang = lang_id
	return true
end


---Set current language
---@param lang_id string current language code (en, jp, ru, etc.)
---@param on_lang_changed function?
function M.set_lang(lang_id, on_lang_changed)
	if not lang_id then
		lang_internal.logger:error("Language id cannot be nil")
		return
	end

	local previous_lang = M.state.lang
	local lang_data = get_lang_data(lang_id)

	if not lang_data then
		lang_internal.logger:error("Lang not found", lang_id)
		return
	end

	local is_lua = type(lang_data.path) == "table"
	local path_str = type(lang_data.path) == "string" and lang_data.path --[[@as string]] or nil
	local is_csv = not is_lua and path_str and string.find(path_str, ".csv") ~= nil
	local is_json = not is_lua and path_str and string.find(path_str, ".json") ~= nil

	-- Async loading with loader
	if lang_data.loader and path_str then
		lang_data.loader(path_str, function(content)
			if parse_and_apply_lang(content, lang_id, is_csv, is_json) then
				if on_lang_changed then
					on_lang_changed()
				end
				lang_internal.logger:info("Lang changed", { previous_lang = previous_lang, lang = lang_id })
			else
				lang_internal.logger:error("Failed to parse lang content", path_str)
			end
		end, function(err)
			lang_internal.logger:error("Failed to load lang file", err)
		end)
		return
	end

	-- Synchronous loading (backward compatibility)
	if is_lua then
		M.set_lang_table(lang_data.path)
		M.state.lang = lang_id
	elseif is_csv and path_str then
		M.load_from_csv(path_str, lang_id)
	elseif is_json and path_str then
		M.load_from_json(path_str, lang_id)
	else
		lang_internal.logger:error("Lang format not supported", lang_data.path or "unknown")
		return
	end

	lang_internal.logger:info("Lang changed", { previous_lang = previous_lang, lang = lang_id })
	if on_lang_changed then
		on_lang_changed()
	end
end


---Load lang from json file
---@private
---@param lang_path string path to lang file
---@param locale_id string? locale id
---@return table<string, string>? result lang data or false if error
function M.load_from_json(lang_path, locale_id)
	locale_id = locale_id or M.state.lang or lang_internal.SYSTEM_LANG

	local is_parsed, lang_data = pcall(lang_internal.load_json, lang_path)
	if not is_parsed then
		lang_internal.logger:error("Can't load or parse lang file. Check the JSON file is valid", lang_path)
		return nil
	end
	if not lang_data then
		lang_internal.logger:error("Lang file not found", lang_path)
		return nil
	end

	M.set_lang_table(lang_data)
	M.state.lang = locale_id

	return lang_data
end


---Load lang from csv file
---@private
---@param csv_path string path to csv file
---@param locale_id string? lang code, default is last used lang
---@return table<string, string>? result lang data or false if error
function M.load_from_csv(csv_path, locale_id)
	locale_id = locale_id or M.state.lang or lang_internal.SYSTEM_LANG

	local langs_data = lang_internal.load_csv(csv_path)
	if not langs_data then
		lang_internal.logger:error("Can't load or parse lang file. Check the CSV file is valid", csv_path)
		return nil
	end

	if not langs_data[locale_id] then
		lang_internal.logger:error("Lang code not found", locale_id)
		return nil
	end

	M.set_lang_table(langs_data[locale_id])
	M.state.lang = locale_id

	return langs_data[locale_id]
end


function M.set_lang_table(lang_table)
	LANG_DICT = lang_table
end


---Set next language from lang list and return it's code
---@return string lang_code The new language code after change
function M.set_next_lang()
	M.set_lang(M.get_next_lang())

	return M.get_lang()
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


---Get default language
---@return string Default language code
function M.get_default_lang()
	return lang_internal.SYSTEM_LANG
end


---Get translation for text id
---@param text_id string text id from your localization
---@return string text ("ui_hello_world") -> "Hello, World!"
function M.txt(text_id)
	return LANG_DICT[text_id] or text_id or ""
end


---Get random translation for text id, split by \n symbol
---@param text_id string text id from your localization
---@return string text ("ui_hint") -> "Hint 1" or "Hint 2" or ...
function M.txr(text_id)
	local texts = lang_internal.split(LANG_DICT[text_id], "\n")
	return texts[math.random(1, #texts)]
end


---Get translation for text id with params
---@param text_id string Text id from your localization
---@vararg string|number Params for translation
---@return string text ("ui_hello_name", "John") -> "Hello, John!"
function M.txp(text_id, ...)
	return string.format(M.txt(text_id), ...)
end


---Check is translation with text_id exist
---@param text_id string text id from your localization
---@return boolean is_exist Is translation exist for text_id
function M.is_exist(text_id)
	return (not not LANG_DICT[text_id])
end


---Return list of available languages
---@return string[] langs List of available languages
function M.get_langs()
	return LANGS_ORDER
end


---Get current lang table { key = "value" }
---@return table<string, string> lang_table
function M.get_lang_table()
	return LANG_DICT
end


---Check if language is available
---@param lang_id string Language code to check
---@return boolean is_available True if language is available
function M.is_lang_available(lang_id)
	return is_lang_available(lang_id)
end


---Render properties panel for lang module
---@param druid table druid instance
---@param properties_panel table druid properties panel instance
function M.render_properties_panel(druid, properties_panel)
	lang_debug_page.render_properties_panel(M, druid, properties_panel)
end


return M
