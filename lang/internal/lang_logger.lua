---@class lang.logger
---@field trace fun(_, msg: string, data: any)
---@field debug fun(_, msg: string, data: any)
---@field info fun(_, msg: string, data: any)
---@field warn fun(_, msg: string, data: any)
---@field error fun(_, msg: string, data: any)
local M = {}

local EMPTY_FUNCTION = function(_, message, context) end

---@type lang.logger
local empty_logger = {
	trace = EMPTY_FUNCTION,
	debug = EMPTY_FUNCTION,
	info = EMPTY_FUNCTION,
	warn = EMPTY_FUNCTION,
	error = EMPTY_FUNCTION,
}

---@type lang.logger
local default_logger = {
	trace = function(_, msg, data) print("TRACE: " .. msg, M.table_to_string(data)) end,
	debug = function(_, msg, data) print("DEBUG: " .. msg, M.table_to_string(data)) end,
	info = function(_, msg, data) print("INFO: " .. msg, M.table_to_string(data)) end,
	warn = function(_, msg, data) print("WARN: " .. msg, M.table_to_string(data)) end,
	error = function(_, msg, data) print("ERROR: " .. msg, M.table_to_string(data)) end
}

local METATABLE = { __index = default_logger }

function M.set_logger(logger)
	METATABLE.__index = logger or empty_logger
end


---Converts table to one-line string
---@param t table
---@param depth number?
---@param result string|nil Internal parameter
---@return string, boolean result String representation of table, Is max string length reached
function M.table_to_string(t, depth, result)
	if type(t) ~= "table" then
		return tostring(t) or "", false
	end

	depth = depth or 0
	result = result or "{"

	for key, value in pairs(t) do
		if #result > 1 then
			result = result .. ", "
		end

		if type(value) == "table" then
			if depth == 0 then
				local table_len = 0
				for _ in pairs(value) do
					table_len = table_len + 1
				end
				result = result .. tostring(key) .. ": {... #" .. table_len .. "}"
			else
				local convert_result, is_limit = M.table_to_string(value, depth - 1, "")
				result = result .. tostring(key) .. ": {" .. convert_result
				if is_limit then
					break
				end
			end
		else
			result = result .. tostring(key) .. ": " .. tostring(value)
		end
	end

	return result .. "}", false
end


return setmetatable(M, METATABLE)
