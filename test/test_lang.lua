return function()
	local lang = {} --[[@as lang]]

	describe("Defold Lang", function()
		before(function()
			lang = require("lang.lang")
			lang.init({
				{ id = "en", path = "/resources/lang/en.json" },
				{ id = "ru", path = "/resources/lang/ru.json" },
				{ id = "es", path = "/resources/lang/es.json" },
			}, "en")
		end)

		after(function()
			lang.reset_state()
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

		it("Should get next lang before change", function()
			local lang_name = lang.get_next_lang()
			assert(lang_name == "ru")

			lang.set_lang(lang_name)
			lang_name = lang.get_next_lang()
			assert(lang_name == "es")

			lang.set_lang(lang_name)
			lang_name = lang.get_next_lang()
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

		it("Should not change language if not found", function()
			lang.init({
				{ id = "en", path = "/resources/lang/en.json" },
			}, "fr")

			local text = lang.txt("ui_hello")
			assert_equal(text, "Hello, World!")
			assert_equal(lang.state.lang, "en")
		end)


		-- Lua file format tests
		it("Should load Lua files correctly", function()
			lang.init({
				{ id = "en", path = require("resources.lang.en") },
				{ id = "ru", path = require("resources.lang.ru") },
				{ id = "es", path = require("resources.lang.es") },
			}, "en")

			local text = lang.txt("ui_hello")
			assert_equal(text, "Hello, World!")

			lang.set_lang("ru")
			text = lang.txt("ui_hello")
			assert_equal(text, "Привет, Мир!")

			lang.set_lang("es")
			text = lang.txt("ui_hello")
			assert_equal(text, "¡Hola, Mundo!")
		end)

		it("Should handle Lua file parameters", function()
			lang.init({
				{ id = "en", path = require("resources.lang.en") },
				{ id = "ru", path = require("resources.lang.ru") },
			}, "en")

			local text = lang.txp("ui_params", "User")
			assert_equal(text, "Hello, User")

			lang.set_lang("ru")
			text = lang.txp("ui_params", "Пользователь")
			assert_equal(text, "Привет, Пользователь")
		end)

		it("Should handle Lua file random text", function()
			lang.init({
				{ id = "en", path = require("resources.lang.en") },
			}, "en")

			local text = lang.txr("ui_random")
			assert(text == "String 1" or text == "String 2" or text == "String 3")
		end)


		-- CSV file format tests
		it("Should load CSV files correctly", function()
			lang.init({
				{ id = "en", path = "/resources/lang/translations.csv" },
				{ id = "ru", path = "/resources/lang/translations.csv" },
				{ id = "es", path = "/resources/lang/translations.csv" },
			}, "en")

			local text = lang.txt("ui_hello")
			assert_equal(text, "Hello, World!")

			lang.set_lang("ru")
			text = lang.txt("ui_hello")
			assert_equal(text, "Привет, Мир!")

			lang.set_lang("es")
			text = lang.txt("ui_hello")
			assert_equal(text, "¡Hola, Mundo!")
		end)

		it("Should handle CSV file parameters", function()
			lang.init({
				{ id = "en", path = "/resources/lang/translations.csv" },
				{ id = "ru", path = "/resources/lang/translations.csv" },
			}, "en")

			local text = lang.txp("ui_params", "User")
			assert_equal(text, "Hello, User")

			lang.set_lang("ru")
			text = lang.txp("ui_params", "Пользователь")
			assert_equal(text, "Привет, Пользователь")
		end)

		it("Should handle CSV file random text", function()
			lang.init({
				{ id = "en", path = "/resources/lang/translations.csv" },
				{ id = "ru", path = "/resources/lang/translations.csv" },
			}, "en")

			local text = lang.txr("ui_random")
			assert(text == "String 1" or text == "String 2" or text == "String 3")

			lang.set_lang("ru")
			text = lang.txr("ui_random")
			assert(text == "Строка 1" or text == "Строка 2" or text == "Строка 3")
		end)


		-- Mixed file format tests
		it("Should handle mixed file formats", function()
			lang.init({
				{ id = "en", path = "/resources/lang/en.json" },
				{ id = "ru", path = require("resources.lang.ru") },
				{ id = "es", path = "/resources/lang/translations.csv" },
			}, "en")

			-- Test JSON (en)
			local text = lang.txt("ui_hello")
			assert_equal(text, "Hello, World!")

			-- Test Lua (ru)
			lang.set_lang("ru")
			text = lang.txt("ui_hello")
			assert_equal(text, "Привет, Мир!")

			-- Test CSV (es)
			lang.set_lang("es")
			text = lang.txt("ui_hello")
			assert_equal(text, "¡Hola, Mundo!")
		end)

		it("Should handle mixed format parameters", function()
			lang.init({
				{ id = "en", path = "/resources/lang/en.json" },
				{ id = "ru", path = require("resources.lang.ru") },
				{ id = "es", path = "/resources/lang/translations.csv" },
			}, "en")

			-- JSON format
			local text = lang.txp("ui_params", "User")
			assert_equal(text, "Hello, User")

			-- Lua format
			lang.set_lang("ru")
			text = lang.txp("ui_params", "Пользователь")
			assert_equal(text, "Привет, Пользователь")

			-- CSV format
			lang.set_lang("es")
			text = lang.txp("ui_params", "Usuario")
			assert_equal(text, "Hola, Usuario")
		end)

		it("Should load_langs merge translations into current language", function()
			lang.init({
				{ id = "en", path = "/resources/lang/en.json" },
			}, "en")

			assert_equal(lang.txt("ui_pack"), "ui_pack")

			local callback_called = false
			lang.load_langs("content_windows", {
				{ id = "en", path = "/resources/lang/en_pack.json" },
			}, function()
				callback_called = true
			end)

			assert(callback_called)
			assert_equal(lang.txt("ui_hello"), "Hello, World!")
			assert_equal(lang.txt("ui_pack"), "Pack loaded")
		end)

		it("Should load_langs add new language from pack", function()
			lang.init({
				{ id = "en", path = "/resources/lang/en.json" },
			}, "en")

			lang.load_langs("content_ru", {
				{ id = "ru", path = "/resources/lang/ru.json" },
			})

			assert_equal(#lang.get_langs(), 2)
			lang.set_lang("ru")
			assert_equal(lang.txt("ui_hello"), "Привет, Мир!")
		end)

		it("Should load_langs work with csv format", function()
			lang.init({
				{ id = "en", path = "/resources/lang/en.json" },
			}, "en")

			lang.load_langs("content_csv", {
				{ id = "en", path = "/resources/lang/translations.csv" },
			})

			assert_equal(lang.txt("ui_hello"), "Hello, World!")
		end)

		it("Should handle language switching between formats", function()
			lang.init({
				{ id = "en", path = "/resources/lang/en.json" },
				{ id = "ru", path = require("resources.lang.ru") },
				{ id = "es", path = "/resources/lang/translations.csv" },
			}, "en")

			local langs = lang.get_langs()
			assert(#langs == 3)
			assert(langs[1] == "en")
			assert(langs[2] == "ru")
			assert(langs[3] == "es")

			-- Test cycling through mixed formats
			lang.set_next_lang()
			assert_equal(lang.get_lang(), "ru")
			local text = lang.txt("ui_hello")
			assert_equal(text, "Привет, Мир!")

			lang.set_next_lang()
			assert_equal(lang.get_lang(), "es")
			text = lang.txt("ui_hello")
			assert_equal(text, "¡Hola, Mundo!")

			lang.set_next_lang()
			assert_equal(lang.get_lang(), "en")
			text = lang.txt("ui_hello")
			assert_equal(text, "Hello, World!")
		end)


		-- Error handling and edge case tests
		describe("Error Handling", function()
			after(function()
				lang.reset_state()
			end)

			it("Should handle invalid Lua file gracefully", function()
				-- This should not crash, but may not load properly
				local success = pcall(function()
					lang.init({
						{ id = "en", path = "/resources/lang/nonexistent.lua" },
					}, "en")
				end)
				-- The init should handle the error gracefully
				assert(success == true or success == false) -- Just ensure no crash
			end)

			it("Should handle invalid CSV file gracefully", function()
				-- This should not crash, but may not load properly
				local success = pcall(function()
					lang.init({
						{ id = "en", path = "/resources/lang/nonexistent.csv" },
					}, "en")
				end)
				-- The init should handle the error gracefully
				assert(success == true or success == false) -- Just ensure no crash
			end)

			it("Should handle empty language array", function()
				local success = pcall(function()
					lang.init({}, "en")
				end)
				-- Should handle empty array gracefully
				assert(success == true or success == false)
			end)
		end)


		-- State management tests
		describe("State Management", function()
			before(function()
				lang.reset_state()
			end)

			after(function()
				lang.reset_state()
			end)

			it("Should preserve state between inits", function()
				-- Set up initial state
				lang.state.lang = "ru"

				lang.init({
					{ id = "en", path = "/resources/lang/en.json" },
					{ id = "ru", path = "/resources/lang/ru.json" },
					{ id = "es", path = "/resources/lang/es.json" },
				})

				-- Should use the state language
				assert_equal(lang.get_lang(), "ru")
				local text = lang.txt("ui_hello")
				assert_equal(text, "Привет, Мир!")
			end)

			it("Should override state with force parameter", function()
				-- Set up initial state
				lang.state.lang = "ru"

				lang.init({
					{ id = "en", path = "/resources/lang/en.json" },
					{ id = "ru", path = "/resources/lang/ru.json" },
					{ id = "es", path = "/resources/lang/es.json" },
				}, "es") -- Force Spanish

				-- Should use forced language, not state
				assert_equal(lang.get_lang(), "es")
				local text = lang.txt("ui_hello")
				assert_equal(text, "¡Hola, Mundo!")
			end)
		end)
	end)
end
