return function()
	local lang = {} --[[@as lang]]

	describe("Defold Lang Logger", function()
		before(function()
			lang = require("lang.lang")
		end)

		it("Should be able to set custom logger", function()
			local is_warn = false
			local logger = {
				trace = function() end,
				debug = function() end,
				info = function() end,
				warn = function() is_warn = true end,
				error = function() end,
			}
			lang.set_logger(logger)

			lang.state.lang = "non-exists"
			lang.init()

			assert(is_warn)
		end)
	end)
end
