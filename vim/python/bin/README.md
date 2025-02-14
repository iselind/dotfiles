# ~ will not be expanded!
command
In order for these scripts to be found by the Coc diagnostics language server we have to produce the absolute path

```json
"custom-json": {
    "command": "python3",
    "args":
[
        "/home/patrik/.vim/python/bin/format_json.py",
        "-"
    ]
},
```

The command python3 will be sought through $PATH but the script path, here for format_json.py has to be the absolute path it seems.
The ~ character will not be expanded to represent the home directory.
