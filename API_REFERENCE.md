# API Reference

## Table of Contents

- [Lang](#lang)
  - [lang.init()](#langinit)
  - [lang.set_lang()](#langset_lang)
  - [lang.get_lang()](#langget_lang)
  - [lang.get_langs()](#langget_langs)
  - [lang.set_next_lang()](#langset_next_lang)
  - [lang.is_exist()](#langis_exist)
  - [lang.txt()](#langtxt)
  - [lang.txp()](#langtxp)
  - [lang.txr()](#langtxr)
  - [lang.set_logger()](#langset_logger)
  - [lang.reset_state()](#langreset_state)


## Lang

To start using the Lang module in your project, you first need to import it. This can be done with the following line of code:

```lua
local lang = require("lang.lang")
```

## Functions

**lang.init()**
---
```lua
lang.init()
```

This function initializes the lang module and loads the current or default language. It should be called at the beginning of the game.

- **Usage Example:**

```lua
lang.init()
```

**lang.set_lang()**
---
```lua
lang.set_lang(lang_id)
```

This function sets the current language.

- **Parameters:**
  - `lang_id`: The language id to set.

- **Usage Example:**

```lua
lang.set_lang("es")
```

**lang.get_lang()**
---
```lua
lang.get_lang()
```

This function returns the current language code.

- **Return Value:**
  - The current language code. Example: "en"

- **Usage Example:**

```lua
local current_lang = lang.get_lang()
print(current_lang) -- "en"
```

**lang.get_langs()**
---
```lua
lang.get_langs()
```

This function returns the available languages.

- **Return Value:**
  - A table of available languages.

- **Usage Example:**

```lua
local langs = lang.get_langs()
print(table.concat(langs, ", ")) -- "en, ru"
```

**lang.set_next_lang()**
---
```lua
lang.set_next_lang()
```

This function sets the next language in the list of available languages.

- **Usage Example:**

```lua
lang.set_next_lang()
```

**lang.is_exist()**
---
```lua
lang.is_exist(text_id)
```

This function checks if the text id exists in the current language file.

- **Parameters:**
  - `text_id`: The text id to check.

- **Return Value:**
  - `true` if the text id exists, `false` otherwise.

- **Usage Example:**

```lua
print(lang.is_exist("ui_hello_world")) -- true
print(lang.is_exist("ui_hello_world_2")) -- false
```

**lang.txt**
---
```lua
lang.txt(text_id)
```

This function returns the text for the specified text id.

- **Parameters:**
  - `text_id`: The locale id to get the text translation for.

- **Return Value:**
  - The text for the specified text id. If the string is not found, the function returns the `text_id` back.

- **Usage Example:**

```lua
local text = lang.txt("ui_hello_world")
print(text) -- "Hello, World!"

local text = lang.txt("ui_hello_world_2")
print(text) -- "ui_hello_world_2"
```

**lang.txp**
---
```lua
lang.txp(text_id, ...)
```

This function returns the text for the specified text id with the specified parameters.

- **Parameters:**
  - `text_id`: The text id to get the text translation for.
  - `...`: The parameters to replace in the text.

- **Return Value:**
  - The text for the specified text id with the specified parameters. If the string is not found, the function returns the `text_id` back.

- **Usage Example:**

```lua
-- ui_hello_name = "Hello, %s!"
local text = lang.txp("ui_hello_name", "Max")
print(text) -- "Hello, Max!"
```

**lang.txr**
---
```lua
lang.txr(text_id)
```

This function returns the random text for the specified text id. The text split by the `\n` symbol (new line).

- **Parameters:**
  - `text_id`: The text id to get the text translation for.

- **Return Value:**
  - The random text for the specified text id.

- **Usage Example:**

```lua
local data = {
	ui_hello_world = "Hello, World!\nHello, Universe!"
}

local text = lang.txr("ui_hello_world")
print(text) -- "Hello, World!"

local text = lang.txr("ui_hello_world")
print(text) -- "Hello, Universe!"
```

**lang.set_logger()**
---
```lua
lang.set_logger([logger_instance])
```

- **Parameters:**
  - `logger_instance`: A logger object that follows the specified logging interface, including methods for `trace`, `debug`, `info`, `warn`, `error`. Pass `nil` to remove the default logger.

- **Usage Example:**

Using the [Defold Log](https://github.com/Insality/defold-log) module:
```lua
local log = require("log.log")
local lang = require("lang.lang")

lang.set_logger(log.get_logger("lang"))
```

Creating a custom user logger:
```lua
local logger = {
    trace = function(_, message, context) end,
    debug = function(_, message, context) end,
    info = function(_, message, context) end,
    warn = function(_, message, context) end,
    error = function(_, message, context) end
}
lang.set_logger(logger)
```

Remove the default logger:
```lua
lang.set_logger(nil)
```

**lang.reset_state()**
---
```lua
lang.reset_state()
```

This function resets the lang module state.

- **Usage Example:**

```lua
lang.reset_state()
```
