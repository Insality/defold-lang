local lang_internal = require("lang.internal.lang_internal")
local logger = require("lang.internal.lang_logger")

---@class lang.registry
local M = {}

---@type table<string, string>
local LANG_DICT = {}

---@type string[]
local LANGS_ORDER = {}

---@type table<string, { data: lang.data, pack_id: string|nil }[]>
local LANG_SOURCES = {}

---@type string[] Pack ids in insertion order, last loaded pack wins on key conflicts
local LANG_PACKS_ORDER = {}


function M.reset()
	LANG_DICT = {}
	LANGS_ORDER = {}
	LANG_SOURCES = {}
	LANG_PACKS_ORDER = {}
end


---@return table<string, string>
function M.get_dict()
	return LANG_DICT
end


---@return string[]
function M.get_langs_order()
	return LANGS_ORDER
end


---@param lang_id string
---@return boolean
function M.is_lang_available(lang_id)
	return LANG_SOURCES[lang_id] ~= nil
end


---@param available_langs lang.data[]
function M.setup_langs(available_langs)
	M.reset()

	for _, lang_data in ipairs(available_langs) do
		table.insert(LANGS_ORDER, lang_data.id)
		LANG_SOURCES[lang_data.id] = { { data = lang_data, pack_id = nil } }
	end
end


---@param pack_id string
---@param langs lang.data[]
function M.add_pack(pack_id, langs)
	for _, entries in pairs(LANG_SOURCES) do
		for index = #entries, 1, -1 do
			if entries[index].pack_id == pack_id then
				table.remove(entries, index)
			end
		end
	end

	for index, id in ipairs(LANG_PACKS_ORDER) do
		if id == pack_id then
			table.remove(LANG_PACKS_ORDER, index)
			break
		end
	end
	table.insert(LANG_PACKS_ORDER, pack_id)

	for _, lang_data in ipairs(langs) do
		if not LANG_SOURCES[lang_data.id] then
			LANG_SOURCES[lang_data.id] = {}
			table.insert(LANGS_ORDER, lang_data.id)
		end
		table.insert(LANG_SOURCES[lang_data.id], { data = lang_data, pack_id = pack_id })
	end
end


---@param lang_id string
---@param on_loaded function?
function M.load_lang(lang_id, on_loaded)
	local entries = LANG_SOURCES[lang_id]
	if not entries or #entries == 0 then
		logger:error("Lang not found", lang_id)
		return
	end

	local sources = {}
	for _, entry in ipairs(entries) do
		if entry.data.path then
			sources[#sources + 1] = entry.data
		end
	end

	if #sources == 0 then
		logger:error("Lang not found", lang_id)
		return
	end

	lang_internal.load_lang_sources(sources, lang_id, function(merged)
		if not merged then
			logger:error("Failed to load lang", lang_id)
			return
		end

		LANG_DICT = merged
		if on_loaded then
			on_loaded(lang_id)
		end
	end)
end


return M
