{
    "osx": {"path": "/usr/local/bin:$PATH"},
    "windows": {"shell": "true"},
    "variants": [
        {
            "name": "Jade",
            "cmd": ["jade", "$file", "--out", "$folder/main/templates/", "--pretty"],
            "selector": "source.jade"
        },
        {
            "name": "Coffee",
            "cmd": ["coffee", "-o", "$folder/main/static/javascript", "$file"],
            "selector": "source.coffee"
        },
        {
            "name": "Stylus",
            "cmd": ["stylus", "--compress", "$file", "-o", "$folder/main/static/css/"],
            "selector": "source.styl"
        }
    ]
}