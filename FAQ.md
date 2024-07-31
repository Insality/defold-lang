# FAQ

## How to use several language files in the project?

This module supports only one language file per language.

## Is there any pluralization support?

No, there is no pluralization support.

## Why I should use this module, it looks like a simple table with text?

It's pretty basic and common module that can be easily implemented by yourself. The advantage of using this module is that it's already implemented and tested. You can use it as is or modify it to fit your needs. I'm sure it's still faster than writing it from scratch.

# How this library works from tech side?

- Module selects language base on the `sys.get_sys_info().system_language` value, if not - it uses the default language.
- The module loading the language file from the folder specified in the `game.project` file.
- The module stores the language file in the table.
- The module provides functions to get the text by key and to change the language.