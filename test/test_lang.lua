return function()
	local lang = {} --[[@as lang]]

	describe("Defold Lang", function()
		before(function()
			lang = require("lang.lang")
			lang.init()
			lang.set_lang(lang.get_default_lang())
		end)

		it("Should lang.txt return text", function()
			local text = lang.txt("ui_hello")
			assert_equal(text, "Hello, World!")

			lang.set_lang("ru")
			text = lang.txt("ui_hello")
			assert_equal(text, "Привет, Мир!")

			lang.set_lang("es")
			text = lang.txt("ui_hello")
			assert_equal(text, "¡Hola, Mundo!")
		end)

		it("Should lang.txt return key if not found", function()
			local text = lang.txt("ui_hello_not_found")
			assert_equal(text, "ui_hello_not_found")
		end)

		it("Should lang.txp return text with params", function()
			local text = lang.txp("ui_params", "User")
			assert_equal(text, "Hello, User")
		end)

		it("Should lang.txp return key if not found", function()
			local text = lang.txp("ui_params_not_found", "User")
			assert_equal(text, "ui_params_not_found")
		end)

		it("Should lang.set_lang change language", function()
			lang.set_lang("ru")
			local text = lang.txt("ui_hello")
			assert_equal(text, "Привет, Мир!")

			lang.set_lang("en")
			text = lang.txt("ui_hello")
			assert_equal(text, "Hello, World!")
		end)

		it("Should lang.get_lang return current language", function()
			local lang_name = lang.get_lang()
			assert(lang_name == "en")
		end)

		it("Should lang.get_langs return all languages", function()
			local langs = lang.get_langs()
			assert(#langs == 3)
			assert(langs[1] == "en")
			assert(langs[2] == "ru")
			assert(langs[3] == "es")
		end)

		it("Should next_lang change language", function()
			lang.set_next_lang()
			local lang_name = lang.get_lang()
			assert(lang_name == "ru")

			lang.set_next_lang()
			lang_name = lang.get_lang()
			assert(lang_name == "es")

			lang.set_next_lang()
			lang_name = lang.get_lang()
			assert(lang_name == "en")
		end)

		it("Should txr return random text", function()
			local text = lang.txr("ui_random")
			assert_equal(text, "String 1" or text == "String 2" or text == "String 3")
		end)

		it("Should not change language if not found", function()
			lang.set_lang("fr")
			local text = lang.txt("ui_hello")
			print(lang.state)
			print(lang.get_lang())
			assert_equal(text, "Hello, World!")
		end)

		it("Should able to check is text_id exists", function()
			local is_exists = lang.is_exist("ui_hello")
			assert(is_exists)

			is_exists = lang.is_exist("ui_hello_not_found")
			assert(not is_exists)
		end)
	end)
end
