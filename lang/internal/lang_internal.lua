local csv = require("lang.csv")
local logger = require("lang.internal.lang_logger")

local M = {}

M.SYSTEM_LANG = sys.get_sys_info().language


---Split string by separator
---@param s string
---@param sep string
---@return table
function M.split(s, sep)
	sep = sep or "%s"
	local t = {}
	local i = 1
	for str in string.gmatch(s, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end


---Load JSON file from game resources folder (by relative path to game.project)
---Return nil if file not found or error
---@param json_path string
---@return table|nil
function M.load_json(json_path)
	local resource, is_error = sys.load_resource(json_path)
	if is_error or not resource then
		return nil
	end

	local success, result = pcall(json.decode, resource)
	return success and result or nil
end


---Parse CSV content string into language tables
---@param csv_content string CSV content as string
---@return table|nil data Table with language data or nil if error
function M.parse_csv_content(csv_content)
	return csv.parse_content(csv_content)
end


---Load CSV file from game resources folder (by relative path to game.project)
---Return nil if file not found or error
---@param csv_path string
---@return table|nil
function M.load_csv(csv_path)
	local resource, is_error = sys.load_resource(csv_path)
	if is_error or not resource then
		return nil
	end

	return M.parse_csv_content(resource)
end


---Merge translations into target table
---@param target table<string, string>
---@param source table<string, string>
function M.merge_table(target, source)
	for key, value in pairs(source) do
		target[key] = value
	end
end


---Get path format flags
---@param path string|table|nil
---@return boolean is_lua
---@return string|nil path_str
---@return boolean is_csv
---@return boolean is_json
function M.get_path_format(path)
	local is_lua = type(path) == "table"
	local path_str = type(path) == "string" and path --[[@as string]] or nil
	local is_csv = not is_lua and path_str and string.find(path_str, ".csv") ~= nil
	local is_json = not is_lua and path_str and string.find(path_str, ".json") ~= nil
	return is_lua, path_str, is_csv, is_json
end


---Parse language content string into translation table
---@param content string File content
---@param lang_id string Language code
---@param path_str string File path
---@return table<string, string>|nil
function M.parse_lang_content(content, lang_id, path_str)
	local _, _, is_csv, is_json = M.get_path_format(path_str)

	if is_csv then
		local parsed = M.parse_csv_content(content)
		return parsed and parsed[lang_id]
	elseif is_json then
		local success, result = pcall(json.decode, content)
		return success and result or nil
	end

	return nil
end


---Load translation table from lang source
---@param lang_data lang.data
---@param lang_id string Language code
---@param csv_cache table<string, table<string, table<string, string>>>|nil
---@return table<string, string>|nil
function M.load_lang_table_from_source(lang_data, lang_id, csv_cache)
	local is_lua, path_str, is_csv, is_json = M.get_path_format(lang_data.path)

	if is_lua then
		return lang_data.path --[[@as table<string, string>]]
	elseif is_csv and path_str then
		local langs_data = csv_cache and csv_cache[path_str]
		if not langs_data then
			langs_data = M.load_csv(path_str)
			if langs_data and csv_cache then
				csv_cache[path_str] = langs_data
			end
		end
		return langs_data and langs_data[lang_id]
	elseif is_json and path_str then
		return M.load_json(path_str)
	end

	return nil
end


---Load and merge translation tables from lang sources
---@param sources lang.data[]
---@param lang_id string Language code
---@param on_loaded fun(merged: table<string, string>|nil)
function M.load_lang_sources(sources, lang_id, on_loaded)
	local merged = {}
	local async_sources = {}
	local csv_cache = {}

	for _, source in ipairs(sources) do
		local is_lua, path_str, is_csv, is_json = M.get_path_format(source.path)
		if source.loader and path_str then
			async_sources[#async_sources + 1] = source
		else
			local lang_table = M.load_lang_table_from_source(source, lang_id, csv_cache)
			if lang_table then
				M.merge_table(merged, lang_table)
			elseif source.path then
				if is_lua or is_csv or is_json then
					logger:error("Failed to load lang file", path_str or source.path)
				else
					logger:error("Lang format not supported", source.path)
				end
			end
		end
	end

	local function finish()
		if not next(merged) then
			on_loaded(nil)
			return
		end
		on_loaded(merged)
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
			local lang_table = M.parse_lang_content(content, lang_id, path_str)
			if lang_table then
				M.merge_table(merged, lang_table)
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


---Check if a table contains a value
---@param t table
---@param value any
---@return number|nil
function M.index_of(t, value)
	for i, v in ipairs(t) do
		if v == value then
			return i
		end
	end
	return nil
end


return M
