# Custom snippets

By default we use mini.snippets + friendly-snippets,  
but you can add any extra snippets you want here.  
File name = `filetype.lua` or `filetype.json`  
`global.json` is for all filetypes.

## Example:

```json
{
  "any text here": {
    "prefix": ["anytext", "multiple", "is", "ok"],
    "body": [
      "for (${1:size_t} ${2:i} = ${3:1}; $2 <= ${4:last}; $2${5:++}) {$0",
      "}"
    ],
    "description": "description of the snippet."
  }
}
```

Check this for more examples: https://github.com/rafamadriz/friendly-snippets/tree/main/snippets
