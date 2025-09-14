## Windows Terminal settings

<br>

### 1. Install `JetBrainsMonoNL Nerd Font`:
Download latest jetbrains font from [here](https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip)


### 2. Config `settings.json`
In **windows terminal** go to the settings and select `Open JSON file`.

#### Add color scheme : 
```json
"schemes": [
		{
			"name": "xcad",
			"background": "#070707",
			"black": "#121212",
			"blue": "#2B4FFF",
			"brightBlack": "#666666",
			"brightBlue": "#5C78FF",
			"brightCyan": "#5AC8FF",
			"brightGreen": "#905AFF",
			"brightPurple": "#5EA2FF",
			"brightRed": "#BA5AFF",
			"brightWhite": "#FFFFFF",
			"brightYellow": "#685AFF",
			"cursorColor": "#FFFFFF",
			"cyan": "#28B9FF",
			"foreground": "#F1F1F1",
			"green": "#D335FF",
			"purple": "#2883FF",
			"red": "#A52AFF",
			"selectionBackground": "#FFFFFF",
			"white": "#F1F1F1",
			"yellow": "#3D2AFF"
		}

	],
```
<br>

#### Add custom config : 
```jsonc
{
	"actions": [
   		// ...
	],
	"copyFormatting": "none",
	"copyOnSelect": true,
}
```
```jsonc
"profiles": {
	// ...

    	"defaults": {
			"colorScheme": "xcad",
			"bellStyle": "none",
			"font": {
				"cellHeight": "1.5",
				"face": "JetBrainsMono Nerd Font Mono",
				"size": 12,
				"weight": "light",
				"features": {
					"calt": 1,
					"liga": 1,
					"zero": 1,
					"ss03": 1,
					"ss04": 1,
					"ss05": 1,
					"ss19": 1,
					"ss20": 1,
					"kern": 1,
					"dlig": 1,
					"tnum": 1,
					"pnum": 1,
					"case": 1,
					"salt": 1
				}
			},
			"historySize": 12000,
			"intenseTextStyle": "all",
			"opacity": 100,
			"padding": "10",
			"scrollbarState": "hidden",
			"useAcrylic": true
		},
		"rendering": {
			"forceFullRepaint": true,
			"textAntialiasing": "cleartype"
		},

	// ...
}
```


