# lang API

> at /lang/lang.lua

## Functions

- [reset_state](#reset_state)
- [init](#init)
- [set_logger](#set_logger)
- [set_lang](#set_lang)
- [load_langs](#load_langs)
- [set_next_lang](#set_next_lang)
- [get_next_lang](#get_next_lang)
- [get_lang](#get_lang)
- [get_default_lang](#get_default_lang)
- [txt](#txt)
- [txr](#txr)
- [txp](#txp)
- [is_exist](#is_exist)
- [get_langs](#get_langs)
- [get_lang_table](#get_lang_table)
- [is_lang_available](#is_lang_available)
## Fields

- [state](#state)



### reset_state

---
```lua
lang.reset_state()
```

Reset module lang state

### init

---
```lua
lang.init(available_langs, [lang_on_start])
```

Call this to initialize lang module

- **Parameters:**
	- `available_langs` *(lang.data[])*: List of { id = "en", path = "/locales/en.json" }
	- `[lang_on_start]` *(string?)*: Language code to set on start, override saved language

### set_logger

---
```lua
lang.set_logger([logger_instance])
```

Set logger for lang module. Pass nil to use empty logger

- **Parameters:**
	- `[logger_instance]` *(table|lang.logger|nil)*:

### set_lang

---
```lua
lang.set_lang(lang_id, [on_lang_changed])
```

Set current language

- **Parameters:**
	- `lang_id` *(string)*: current language code (en, jp, ru, etc.)
	- `[on_lang_changed]` *(function?)*:

### load_langs

---
```lua
lang.load_langs(pack_id, langs, [on_lang_changed])
```

Load additional locale pack and refresh current language

- **Parameters:**
	- `pack_id` *(string)*: Pack id for future unload
	- `langs` *(lang.data[])*: List of { id = "en", path = "/locales/en.json" }
	- `[on_lang_changed]` *(function?)*:

### set_next_lang

---
```lua
lang.set_next_lang([on_lang_changed])
```

Set next language from lang list and return it's code

- **Parameters:**
	- `[on_lang_changed]` *(function?)*:

- **Returns:**
	- `lang_code` *(string)*: The language code being switched to

### get_next_lang

---
```lua
lang.get_next_lang()
```

Get next language from lang list and return it's code

- **Returns:**
	- `lang_code` *(string)*: next language code

### get_lang

---
```lua
lang.get_lang()
```

Get current language

- **Returns:**
	- `Current` *(string)*: language code

### get_default_lang

---
```lua
lang.get_default_lang()
```

Get default language

- **Returns:**
	- `Default` *(string)*: language code

### txt

---
```lua
lang.txt(text_id)
```

Get translation for text id

- **Parameters:**
	- `text_id` *(string)*: text id from your localization

- **Returns:**
	- `text` *(string)*: ("ui_hello_world") -> "Hello, World!"

### txr

---
```lua
lang.txr(text_id)
```

Get random translation for text id, split by \n symbol

- **Parameters:**
	- `text_id` *(string)*: text id from your localization

- **Returns:**
	- `text` *(string)*: ("ui_hint") -> "Hint 1" or "Hint 2" or ...

### txp

---
```lua
lang.txp(text_id, ...)
```

Get translation for text id with params

- **Parameters:**
	- `text_id` *(string)*: Text id from your localization
	- `...` *(...)*: vararg

- **Returns:**
	- `text` *(string)*: ("ui_hello_name", "John") -> "Hello, John!"

### is_exist

---
```lua
lang.is_exist(text_id)
```

Check is translation with text_id exist

- **Parameters:**
	- `text_id` *(string)*: text id from your localization

- **Returns:**
	- `is_exist` *(boolean)*: Is translation exist for text_id

### get_langs

---
```lua
lang.get_langs()
```

Return list of available languages

- **Returns:**
	- `langs` *(string[])*: List of available languages

### get_lang_table

---
```lua
lang.get_lang_table()
```

Get current lang table { key = "value" }

- **Returns:**
	- `lang_table` *(table<string, string>)*:

### is_lang_available

---
```lua
lang.is_lang_available(lang_id)
```

Check if language is available

- **Parameters:**
	- `lang_id` *(string)*: Language code to check

- **Returns:**
	- `is_available` *(boolean)*: True if language is available


## Fields
<a name="state"></a>
- **state** (_nil_):  Persistent storage

