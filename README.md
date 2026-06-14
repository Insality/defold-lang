![](media/logo.png)

[![GitHub release (latest by date)](https://img.shields.io/github/v/tag/insality/defold-lang?style=for-the-badge&label=Release)](https://github.com/Insality/defold-lang/tags)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/insality/defold-lang/ci_workflow.yml?style=for-the-badge)](https://github.com/Insality/defold-lang/actions)
[![codecov](https://img.shields.io/codecov/c/github/Insality/defold-lang?style=for-the-badge)](https://codecov.io/gh/Insality/defold-lang)

[![Github-sponsors](https://img.shields.io/badge/sponsor-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#EA4AAA)](https://github.com/sponsors/insality) [![Ko-Fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/insality) [![BuyMeACoffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/insality)


# Defold Lang

**Defold Lang** is a simple localization module for **Defold**. It loads language files and manages translations in your project.

## Features

- **Handy API** - Simple and easy to use API
- **Multiple File Formats** - Support for JSON, Lua, and CSV language files
- **Runtime Locale Packs** - Load additional translations at runtime with `lang.load_langs()`
- **Async Loading** - Custom loader functions for bundle resources, HTTP, and other I/O
- **Saver Support** - Save current selected language in [Defold-Saver](https://github.com/Insality/defold-saver)
- **Druid Support** - Easy [Druid](https://github.com/Insality/druid) integration

## Setup

### [Dependency](https://www.defold.com/manuals/libraries/)

Open your `game.project` file and add the following line to the dependencies field under the project section:

**[Lang](https://github.com/Insality/defold-lang/archive/refs/tags/5.zip)**

```
https://github.com/Insality/defold-lang/archive/refs/tags/5.zip
```

After that, select `Project ▸ Fetch Libraries` to update [library dependencies]((https://defold.com/manuals/libraries/#setting-up-library-dependencies)). This happens automatically whenever you open a project so you will only need to do this if the dependencies change without re-opening the project.

### Library Size

> **Note:** The library size is calculated based on the build report per platform

| Platform         | Library Size |
| ---------------- | ------------ |
| HTML5            | **7.87 KB**  |
| Desktop / Mobile | **12.68 KB**  |


### Initialization

Initialize the **Lang** module by calling `lang.init()` with your language configuration:

```lua
local lang = require("lang.lang")

-- Basic initialization with language files
lang.init({
	{ id = "en", path = "/resources/lang/en.json" },
	{ id = "ru", path = "/resources/lang/ru.json" },
	{ id = "es", path = "/resources/lang/es.json" },
})
```

#### Force Language on Start

You can force a specific language on initialization:

```lua
-- Force Spanish language on start
lang.init({
	{ id = "en", path = "/resources/lang/en.json" },
	{ id = "ru", path = "/resources/lang/ru.json" },
	{ id = "es", path = "/resources/lang/es.json" },
}, "es")
```

#### Language Selection Priority

**Defold Lang** selects the language to use in the following priority order:

1. **Force parameter** - If provided as second parameter to `lang.init()`
2. **Saved language** - From `lang.state.lang` (restored from save system or manually set)
3. **System language** - Device language from `sys.get_sys_info().language`
4. **Default language** - First language in the configuration array

The first language in the configuration array serves as the ultimate fallback. Defold uses the two-character [ISO-639 format](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes) for language codes ("en", "ru", "es", etc).

> **Note:** Place your language files inside your [custom resources folder](https://defold.com/manuals/project-settings/#custom-resources) to ensure they are included in the build.


### Localization Files

**Defold Lang** supports three file formats: **JSON**, **Lua**, and **CSV**.

#### JSON Files
```json
{
	"ui_hello_world": "Hello, World!",
	"ui_hello_name": "Hello, %s!",
	"ui_settings": "Settings",
	"ui_exit": "Exit"
}
```

#### Lua Files
```lua
-- en.lua
return {
	ui_hello_world = "Hello, World!",
	ui_hello_name = "Hello, %s!",
	ui_settings = "Settings",
	ui_exit = "Exit"
}
```

#### CSV Files
```csv
key,en,ru,es
ui_hello_world,"Hello, World!","Привет, мир!","¡Hola, mundo!"
ui_hello_name,"Hello, %s!","Привет, %s!","¡Hola, %s!"
ui_settings,Settings,Настройки,Configuración
ui_exit,Exit,Выход,Salir
```

#### Mixed Format Example
You can mix different file formats in a single configuration:

```lua
lang.init({
	{ id = "en", path = "/resources/lang/en.json" },
	{ id = "ru", path = require("resources.lang.ru") },
	{ id = "es", path = "/resources/lang/translations.csv" },
})
```

### Load from Bundle Resources

#### Async Loading with Custom Loaders

For loading from bundle resources (file I/O or HTTP), you can provide a custom loader function:

```lua
-- Custom async loader for bundle resources, HTTP loading, etc.
lang.init({
	{
		id = "en",
		path = "/bundle/lang/en.json",
		loader = function(path, on_success, on_error)
			-- Your custom loading logic here
			-- Call on_success(content) with file content string
			-- Or on_error(error_message) on failure

			-- Example: Bundle resource loading
			local app_path = sys.get_application_path()
			local full_path = app_path .. path
			local f = io.open(full_path, "rb")
			if f then
				local content = f:read("*a")
				f:close()
				on_success(content)
			else
				on_error("File not found: " .. full_path)
			end
		end
	},
})

-- Language switching with callback
lang.set_lang("en", function()
	print("Language loaded!")
	print(lang.txt("ui_hello"))
	druid.on_language_change()
end)
```

**Use cases for custom loaders:**
- Bundle resources loading (file I/O or HTTP)
- Platform-specific resource access

### Runtime Locale Packs

Load additional locale files at runtime with `lang.load_langs()`. Translations from a pack are merged into the current language. If the same key exists in multiple packs, the last loaded pack wins. Calling `lang.init()` clears all previously loaded packs.

```lua
-- Base languages at startup
lang.init({
	{ id = "en", path = "/resources/lang/en.json" },
})

-- Load DLC or platform-specific translations
lang.load_langs("dlc_1", {
	{ id = "en", path = "/bundle/lang/dlc_en.json" },
	{ id = "ru", path = "/bundle/lang/dlc_ru.json" },
}, function()
	druid.on_language_change()
end)

-- Add a new language from a pack
lang.load_langs("content_ru", {
	{ id = "ru", path = "/resources/lang/ru.json" },
})
lang.set_lang("ru")
```

## API Reference

### Quick API Reference

```lua
lang.init(available_langs, [lang_on_start])
lang.load_langs(pack_id, langs, [on_lang_changed])
lang.set_lang(lang_id, [on_lang_changed])
lang.get_lang()
lang.get_langs()
lang.set_next_lang([on_lang_changed])
lang.get_next_lang()
lang.txt(text_id)
lang.txp(text_id, ...)
lang.txr(text_id)
lang.is_exist(text_id)
lang.set_logger([logger])
lang.reset_state()
```

#### Basic Usage Example

```lua
local lang = require("lang.lang")

-- Initialize with language files
lang.init({
	{ id = "en", path = "/resources/lang/en.json" },
	{ id = "ru", path = "/resources/lang/ru.json" },
	{ id = "es", path = "/resources/lang/es.json" },
})

-- Use translations
print(lang.txt("ui_hello_world"))     -- "Hello, World!"
print(lang.txp("ui_hello_name", "John")) -- "Hello, John!"

-- Change language
lang.set_lang("es")
print(lang.txt("ui_hello_world"))     -- "¡Hola, mundo!"
```

### API Reference

Read the [API Reference](API_REFERENCE.md) file to see the full API documentation for the module.


## Use Cases

Read the [Use Cases](USE_CASES.md) file to see several examples of how to use the this module in your Defold game development projects.


## FAQ

Read the [FAQ](FAQ.md) file to see the answers to frequently asked questions about the module.


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## Issues and Suggestions

For any issues, questions, or suggestions, please [create an issue](https://github.com/Insality/defold-lang/issues).


## 👏 Contributors

<a href="https://github.com/Insality/defold-lang/graphs/contributors">
  <img src="https://contributors-img.web.app/image?repo=insality/defold-lang"/>
</a>

## Changelog

<details>

### **V1**
	- Initial release

### **V2**
	- Add Defold Editor Script to collect unique characters from selected JSON files

### **V3**
	- Add `lang.get_next_lang()` function
	- Better error messages

### **V4**
	- [Breaking] Lang now use `lang.init()` function to initialize module instead of `game.project` configuration
	- Add Lua file support
	- Add CSV file support
	- Updated editor script to collect unique characters from selected JSON and CSV files
	- Add Lang debug properties page for Druid properties panel

### **V5**
	- [Breaking] Removed `lang.set_lang_table()` function
	- [Breaking] Removed `lang.render_properties_panel()` function
	- [Breaking] `lang.set_lang()` no longer returns boolean, now accepts optional `on_lang_changed` callback
	- Add `lang.load_langs()` for loading additional locale packs at runtime
	- Add async loading support via custom `loader` function in language config
	- Internal refactor: moved internal modules to `lang/internal/` subfolder
	- Updated logger

</details>


## ❤️ Support project ❤️

Your donation helps me stay engaged in creating valuable projects for **Defold**. If you appreciate what I'm doing, please consider supporting me!

[![Github-sponsors](https://img.shields.io/badge/sponsor-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=#EA4AAA)](https://github.com/sponsors/insality) [![Ko-Fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/insality) [![BuyMeACoffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://www.buymeacoffee.com/insality)
