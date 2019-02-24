JADE
Required: 'npm' and 'node'(--global jade)
Go to "Tools/Build-System/New-Build-System" and add:
{
	"cmd": ["jade", "$file", "--out", "$folder/main/templates/", "--pretty"],
	"selector": "source.jade",
	"osx": {"path": "/usr/local/bin:$PATH"},
	"windows": {"shell": "true"}
}
Save "Custom-Jade.sublime-build" and choose in list "Tools/Build-System/Custom-Jade". 
CTRL+B compile jade file.


CoffeeScript
Required: 'npm' and 'node'(--global coffescript)
Go to "Tools/Build-System/New-Build-System" and add:
{
	"cmd": ["coffee", "--compile", "$file", "--output", "$folder/main/static/javascript/"],
	"selector": "source.coffee",
	"osx": {"path": "/usr/local/bin:$PATH"},
	"windows": {"shell": "true"}
}
Save "Custom-Coffee.sublime-build" and choose in list "Tools/Build-System/Custom-Coffee". 
CTRL+B compile coffee file.