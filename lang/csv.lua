local M = {}

local COMMA = string.byte(",")
local QUOTE = string.byte('"')


local function parse_field(line, i)
	local len = #line
	if i > len then
		return "", i
	end

	if line:byte(i) == QUOTE then
		local field = {}
		i = i + 1
		while i <= len do
			local c = line:byte(i)
			if c == QUOTE then
				if line:byte(i + 1) == QUOTE then
					field[#field + 1] = '"'
					i = i + 2
				else
					return table.concat(field), i + 1
				end
			else
				field[#field + 1] = string.char(c)
				i = i + 1
			end
		end
		return table.concat(field), i
	end

	local start = i
	while i <= len and line:byte(i) ~= COMMA do
		i = i + 1
	end
	return line:sub(start, i - 1), i
end


---Parse a single CSV row into a list of fields
---@param line string
---@return string[]
function M.parse_row(line)
	local fields = {}
	local i = 1
	local len = #line

	repeat
		local field
		field, i = parse_field(line, i)
		fields[#fields + 1] = field
		if i <= len and line:byte(i) == COMMA then
			i = i + 1
		else
			break
		end
	until false

	return fields
end


---Parse CSV content into a list of rows
---@param csv_content string
---@return string[][]
function M.parse_rows(csv_content)
	local rows = {}
	local content = csv_content:gsub("\r\n", "\n"):gsub("\r", "\n")
	for line in content:gmatch("[^\n]+") do
		rows[#rows + 1] = M.parse_row(line)
	end
	return rows
end


---Parse CSV content into language tables
---First row: key column + language codes. First column: translation keys.
---@param csv_content string
---@return table<string, table<string, string>>
function M.parse_content(csv_content)
	local data = {}
	local headers = nil

	for _, fields in ipairs(M.parse_rows(csv_content)) do
		if not headers then
			headers = fields
			for i = 2, #headers do
				data[headers[i]] = {}
			end
		else
			local key = fields[1]
			if key then
				for i = 2, #headers do
					if fields[i] then
						local value = fields[i]:gsub("\\n", "\n"):gsub("\\t", "\t"):gsub("\\r", "\r")
						data[headers[i]][key] = value
					end
				end
			end
		end
	end

	return data
end


return M
