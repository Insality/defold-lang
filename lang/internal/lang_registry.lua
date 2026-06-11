local lang_internal = require("lang.internal.lang_internal")
local logger = require("lang.internal.lang_logger")

---@class lang.registry
local M = {}

---@type table<string, string>
local LANG_DICT = nil

---@type string[]
local LANGS_ORDER = nil

---@type table<string, lang.data>
local AVAILABLE_LANGS_MAP = nil

---@type table<string, lang.data[]>
local LANG_PACKS = nil

---@type string[] Pack ids in insertion order, last loaded pack wins on key conflicts
local LANG_PACKS_ORDER = nil


function M.reset()
	LANG_DICT = {}
	LANGS_ORDER = {}
	AVAILABLE_LANGS_MAP = {}
	LANG_PACKS = {}
	LANG_PACKS_ORDER = {}
end


---@return table<string, string>
function M.get_dict()
	return LANG_DICT
end


---@param dict table<string, string>
function M.set_dict(dict)
	LANG_DICT = dict
end


---@return string[]
function M.get_langs_order()
	return LANGS_ORDER
end


---@param lang_id string
---@return boolean
function M.is_lang_available(lang_id)
	return AVAILABLE_LANGS_MAP[lang_id] ~= nil
end


---@param available_langs lang.data[]
function M.setup_langs(available_langs)
	LANGS_ORDER = {}
	AVAILABLE_LANGS_MAP = {}
	LANG_DICT = {}
	LANG_PACKS = {}
	LANG_PACKS_ORDER = {}

	for _, lang_data in ipairs(available_langs) do
		table.insert(LANGS_ORDER, lang_data.id)
		AVAILABLE_LANGS_MAP[lang_data.id] = lang_data
	end
end


---@param pack_id string
---@param langs lang.data[]
function M.add_pack(pack_id, langs)
	LANG_PACKS[pack_id] = langs

	for index, id in ipairs(LANG_PACKS_ORDER) do
		if id == pack_id then
			table.remove(LANG_PACKS_ORDER, index)
			break
		end
	end
	table.insert(LANG_PACKS_ORDER, pack_id)

	for _, lang_data in ipairs(langs) do
		if not AVAILABLE_LANGS_MAP[lang_data.id] then
			AVAILABLE_LANGS_MAP[lang_data.id] = { id = lang_data.id }
			table.insert(LANGS_ORDER, lang_data.id)
		end
	end
end


---@param lang_id string
---@return lang.data[]
local function collect_lang_sources(lang_id)
	local sources = {}
	local base = AVAILABLE_LANGS_MAP[lang_id]

	if base and base.path then
		table.insert(sources, base)
	end

	for _, pack_id in ipairs(LANG_PACKS_ORDER) do
		local pack_langs = LANG_PACKS[pack_id]
		for _, lang_data in ipairs(pack_langs) do
			if lang_data.id == lang_id then
				table.insert(sources, lang_data)
			end
		end
	end

	return sources
end


---@param lang_id string
---@param on_loaded function?
function M.load_lang(lang_id, on_loaded)
	local sources = collect_lang_sources(lang_id)
	if #sources == 0 then
		logger:error("Lang not found", lang_id)
		return
	end

	local merged = {}
	local async_sources = {}

	for _, source in ipairs(sources) do
		local _, path_str = lang_internal.get_path_format(source.path)
		if source.loader and path_str then
			table.insert(async_sources, source)
		else
			local lang_table = lang_internal.load_lang_table_from_source(source, lang_id)
			if lang_table then
				lang_internal.merge_table(merged, lang_table)
			elseif source.path then
				logger:error("Lang format not supported", source.path)
			end
		end
	end

	local function finish()
		if not next(merged) then
			logger:error("Failed to load lang", lang_id)
			return
		end

		LANG_DICT = merged
		if on_loaded then
			on_loaded(lang_id)
		end
	end

	if #async_sources == 0 then
		finish()
		return
	end

	local pending = #async_sources

	local function on_async_done()
		pending = pending - 1
		if pending == 0 then
			finish()
		end
	end

	for _, source in ipairs(async_sources) do
		local path_str = source.path --[[@as string]]
		local loader_ok, loader_err = pcall(source.loader, path_str, function(content)
			local lang_table = lang_internal.parse_lang_content(content, lang_id, path_str)
			if lang_table then
				lang_internal.merge_table(merged, lang_table)
			else
				logger:error("Failed to parse lang content", path_str)
			end
			on_async_done()
		end, function(err)
			logger:error("Failed to load lang file", err)
			on_async_done()
		end)

		if not loader_ok then
			logger:error("Failed to load lang file", loader_err)
			on_async_done()
		end
	end
end


return M
