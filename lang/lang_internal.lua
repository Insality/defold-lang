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
