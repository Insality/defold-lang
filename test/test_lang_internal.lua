return function()
	local lang_internal = {}

	describe("Defold Lang", function()
		before(function()
			lang_internal = require("lang.lang_internal")
		end)

		it("Test index_of", function()
			local index = lang_internal.index_of({ "en", "ru", "es" }, "ru")
			assert(index == 2)

			index = lang_internal.index_of({ "en", "ru", "es" }, "es")
			assert(index == 3)

			index = lang_internal.index_of({ "en", "ru", "es" }, "fr")
			assert(index == nil)
		end)
	end)
end
