-- Master snippet file that imports all language-specific snippets
-- Each language file should return a table of snippets

return {
  -- Import Python snippets
  ["python"] = require("custom.snippets.python"),

  -- Import JavaScript snippets
  ["javascript"] = require("custom.snippets.javascript"),
  ["javascriptreact"] = require("custom.snippets.react"),

  -- Import TypeScript snippets
  ["typescript"] = require("custom.snippets.typescript"),
  ["typescriptreact"] = require("custom.snippets.react"),

  -- Import Lua snippets
  ["lua"] = require("custom.snippets.lua"),

  -- Import Markdown snippets
  ["markdown"] = require("custom.snippets.markdown"),

  -- Import JSON snippets
  ["json"] = require("custom.snippets.json"),
  ["jsonc"] = require("custom.snippets.json"), -- JSON with comments

  -- Add more as needed
  -- ['go'] = require('custom.snippets.go'),
  -- ['rust'] = require('custom.snippets.rust'),
  -- ['sql'] = require('custom.snippets.sql'),
  -- ['yaml'] = require('custom.snippets.yaml'),
  -- ['html'] = require('custom.snippets.html'),
  -- ['css'] = require('custom.snippets.css'),
  -- ['scss'] = require('custom.snippets.scss'),
}
