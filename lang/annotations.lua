---@class lang.state
---@field lang string @current language name (en, jp, ru, etc.)

---@class lang.logger
---@field trace fun(logger: lang.logger, message: string, data: any|nil)
---@field debug fun(logger: lang.logger, message: string, data: any|nil)
---@field info fun(logger: lang.logger, message: string, data: any|nil)
---@field warn fun(logger: lang.logger, message: string, data: any|nil)
---@field error fun(logger: lang.logger, message: string, data: any|nil)
