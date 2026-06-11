local csv = require("lang.csv")

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

	return json.decode(resource)
end


---Parse CSV content string into language tables
---@param csv_content string CSV content as string
---@return table|nil data Table with language data or nil if error
function M.parse_csv_content(csv_content)
	local data = {}
	local f = csv.openstring(csv_content)
	local headers = nil

	-- Parse headers, first id is a lang_id to table <lang<locale_id, translate>>
	for fields in f:lines() do
		if not headers then
			-- First row contains language codes
			headers = fields
			-- Initialize language tables
			for i = 2, #headers do
				data[headers[i]] = {}
			end
		else
			-- Process data rows
			local key = fields[1] -- First column is the translation key
			if key then
				-- Add translations for each language
				for i = 2, #headers do
					if fields[i] then
						-- Process escape sequences in the field value
						local value = fields[i]:gsub("\\n", "\n"):gsub("\\t", "\t"):gsub("\\r", "\r")
						data[headers[i]][key] = value
					end
				end
			end
		end
	end

	return data
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
---@return table<string, string>|nil
function M.load_lang_table_from_source(lang_data, lang_id)
	local is_lua, path_str, is_csv, is_json = M.get_path_format(lang_data.path)

	if is_lua then
		return lang_data.path --[[@as table<string, string>]]
	elseif is_csv and path_str then
		local langs_data = M.load_csv(path_str)
		return langs_data and langs_data[lang_id]
	elseif is_json and path_str then
		return M.load_json(path_str)
	end

	return nil
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
