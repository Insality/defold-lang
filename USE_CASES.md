# Use Cases

This section provides examples of how to use the `lang` module.

## Druid Lang Text Integration

To use lang module with [Druid](https://github.com/Insality/druid), you can use next integration:

```lua
local lang = require("lang.lang")
local druid = require("druid.druid")

local function init_druid(self)
	druid.set_text_function(lang.txp)
end
```

Don't forget to call `druid.on_language_change()` when the language changes.

```lua
local function next_language(self)
	lang.set_next_lang()
	druid.on_language_change()
end
```

## Save current language

### Using Defold Saver

If you want to save the current language, you can use the [Defold-Saver](https://github.com/Insality/defold-saver/) module.

```lua
local lang = require("lang.lang")
local saver = require("saver.saver")

local function init_saver(self)
	---Add save states to annotation
	---@class saver.game_state
	---@field lang lang.state

	saver.init()
	-- After saver.init add lang state to the saver
	saver.bind_game_state("lang", lang.state)
end

local function init_lang(self)
	-- Init lang after loaded save
	lang.init()
end

function init(self)
	--...
	init_saver(self)
	init_lang(self)
	--...
end
```


### Using other save system

If you use another save system, you can save the current language somewhere. Set the current language before calling `lang.init()`.

```lua
-- Save current somewhere lang id via `lang.get_lang()` and update it on language change in your game
local current_lang = get_current_language_from_save()
lang.state.lang = current_lang
lang.init()
```


## Using GUI text as a text_id

In some cases, it can be useful or convenient to use the GUI node text as a text_id. The idea is to set the localization ID in your GUI layout and in the initialization step, use it to set the actual text.

```lua
local lang = require("lang.lang")

local function init(self)
	--...
	local text_node = gui.get_node("text_node")
	local text_id = gui.get_text(text_node)
	gui.set_text(text_node, lang.txt(text_id))
	--...
end
```

In the Druid's Lang Text, this happens automatically if you don't specify the text ID in the constructor.

```lua
local druid = require("druid.druid")

function init(self)
	--...
	self.druid = druid.new(self)
	-- If text_node has a text "ui_text_id", it will be used as a text_id
	self.druid:new_lang_text("text_node")
	--...
end
```