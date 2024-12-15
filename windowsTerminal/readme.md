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
			"name": "Aura Dark",
			"cursorColor": "#a277ff",
			"selectionBackground": "#a394f0",
			"background": "#15141b",
			"foreground": "#edecee",
			"black": "#110f18",
			"blue": "#61ffca",
			"cyan": "#edecee",
			"green": "#61ffca",
			"purple": "#a277ff",
			"red": "#ff6767",
			"white": "#edecee",
			"yellow": "#ffca85",
			"brightBlack": "#4d4d4d",
			"brightBlue": "#a277ff",
			"brightCyan": "#61ffca",
			"brightGreen": "#a277ff",
			"brightPurple": "#a277ff",
			"brightRed": "#ffca85",
			"brightWhite": "#edecee",
			"brightYellow": "#ffca85"
		},
		{
			"name": "Aura Dark (Soft Text)",
			"cursorColor": "#8464c6",
			"selectionBackground": "#a394f0",
			"background": "#15141b",
			"foreground": "#bdbdbd",
			"black": "#110f18",
			"blue": "#54c59f",
			"cyan": "#bdbdbd",
			"green": "#54c59f",
			"purple": "#8464c6",
			"red": "#c55858",
			"white": "#bdbdbd",
			"yellow": "#c7a06f",
			"brightBlack": "#4d4d4d",
			"brightBlue": "#8464c6",
			"brightCyan": "#54c59f",
			"brightGreen": "#8464c6",
			"brightPurple": "#8464c6",
			"brightRed": "#c7a06f",
			"brightWhite": "#bdbdbd",
			"brightYellow": "#c7a06f"
		},
		{
			"name": "Aura Soft Dark",
			"cursorColor": "#a277ff",
			"selectionBackground": "#a394f0",
			"background": "#21202e",
			"foreground": "#edecee",
			"black": "#1c1b22",
			"blue": "#61ffca",
			"cyan": "#edecee",
			"green": "#61ffca",
			"purple": "#a277ff",
			"red": "#ff6767",
			"white": "#edecee",
			"yellow": "#ffca85",
			"brightBlack": "#4d4d4d",
			"brightBlue": "#a277ff",
			"brightCyan": "#61ffca",
			"brightGreen": "#a277ff",
			"brightPurple": "#a277ff",
			"brightRed": "#ffca85",
			"brightWhite": "#edecee",
			"brightYellow": "#ffca85"
		},
		{
			"name": "Aura Soft Dark (Soft Text)",
			"cursorColor": "#8464c6",
			"selectionBackground": "#a394f0",
			"background": "#21202e",
			"foreground": "#bdbdbd",
			"black": "#1c1b22",
			"blue": "#54c59f",
			"cyan": "#bdbdbd",
			"green": "#54c59f",
			"purple": "#8464c6",
			"red": "#c55858",
			"white": "#bdbdbd",
			"yellow": "#c7a06f",
			"brightBlack": "#4d4d4d",
			"brightBlue": "#8464c6",
			"brightCyan": "#54c59f",
			"brightGreen": "#8464c6",
			"brightPurple": "#8464c6",
			"brightRed": "#c7a06f",
			"brightWhite": "#bdbdbd",
			"brightYellow": "#c7a06f"
		},
		{
			"name": "Catppuccin Frappe",

			"cursorColor": "#F2D5CF",
			"selectionBackground": "#626880",

			"background": "#303446",
			"foreground": "#C6D0F5",

			"black": "#51576D",
			"red": "#E78284",
			"green": "#A6D189",
			"yellow": "#E5C890",
			"blue": "#8CAAEE",
			"purple": "#F4B8E4",
			"cyan": "#81C8BE",
			"white": "#B5BFE2",

			"brightBlack": "#626880",
			"brightRed": "#E78284",
			"brightGreen": "#A6D189",
			"brightYellow": "#E5C890",
			"brightBlue": "#8CAAEE",
			"brightPurple": "#F4B8E4",
			"brightCyan": "#81C8BE",
			"brightWhite": "#A5ADCE"
		},
		{
			"name": "Catppuccin Latte",

			"cursorColor": "#DC8A78",
			"selectionBackground": "#ACB0BE",

			"background": "#EFF1F5",
			"foreground": "#4C4F69",

			"black": "#5C5F77",
			"red": "#D20F39",
			"green": "#40A02B",
			"yellow": "#DF8E1D",
			"blue": "#1E66F5",
			"purple": "#EA76CB",
			"cyan": "#179299",
			"white": "#ACB0BE",

			"brightBlack": "#ACB0BE",
			"brightRed": "#D20F39",
			"brightGreen": "#40A02B",
			"brightYellow": "#DF8E1D",
			"brightBlue": "#1E66F5",
			"brightPurple": "#EA76CB",
			"brightCyan": "#179299",
			"brightWhite": "#BCC0CC"
		},
		{
			"name": "Catppuccin Macchiato",

			"cursorColor": "#F4DBD6",
			"selectionBackground": "#5B6078",

			"background": "#24273A",
			"foreground": "#CAD3F5",

			"black": "#494D64",
			"red": "#ED8796",
			"green": "#A6DA95",
			"yellow": "#EED49F",
			"blue": "#8AADF4",
			"purple": "#F5BDE6",
			"cyan": "#8BD5CA",
			"white": "#B8C0E0",

			"brightBlack": "#5B6078",
			"brightRed": "#ED8796",
			"brightGreen": "#A6DA95",
			"brightYellow": "#EED49F",
			"brightBlue": "#8AADF4",
			"brightPurple": "#F5BDE6",
			"brightCyan": "#8BD5CA",
			"brightWhite": "#A5ADCB"
		},
		{
			"name": "Catppuccin Mocha",

			"cursorColor": "#F5E0DC",
			"selectionBackground": "#585B70",

			"background": "#1E1E2E",
			"foreground": "#CDD6F4",

			"black": "#45475A",
			"red": "#F38BA8",
			"green": "#A6E3A1",
			"yellow": "#F9E2AF",
			"blue": "#89B4FA",
			"purple": "#F5C2E7",
			"cyan": "#94E2D5",
			"white": "#BAC2DE",

			"brightBlack": "#585B70",
			"brightRed": "#F38BA8",
			"brightGreen": "#A6E3A1",
			"brightYellow": "#F9E2AF",
			"brightBlue": "#89B4FA",
			"brightPurple": "#F5C2E7",
			"brightCyan": "#94E2D5",
			"brightWhite": "#A6ADC8"
		},
		{
			"name": "xcad",
			"background": "#1A1A1A",
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

#### Add Theme :

```json
"themes": [

		{
			"name": "Catppuccin Frappe",
			"tab": {
				"background": "#303446FF",
				"showCloseButton": "always",
				"unfocusedBackground": null
			},
			"tabRow": {
				"background": "#292C3CFF",
				"unfocusedBackground": "#232634FF"
			},
			"window": {
				"applicationTheme": "dark",
				"experimental.rainbowFrame": false,
				"frame": null,
				"unfocusedFrame": null,
				"useMica": false
			}
		},
		{
			"name": "Catppuccin Latte",
			"tab": {
				"background": "#EFF1F5FF",
				"showCloseButton": "always",
				"unfocusedBackground": null
			},
			"tabRow": {
				"background": "#E6E9EFFF",
				"unfocusedBackground": "#DCE0E8FF"
			},
			"window": {
				"applicationTheme": "light",
				"experimental.rainbowFrame": false,
				"frame": null,
				"unfocusedFrame": null,
				"useMica": false
			}
		},
		{
			"name": "Catppuccin Macchiato",
			"tab": {
				"background": "#24273AFF",
				"showCloseButton": "always",
				"unfocusedBackground": null
			},
			"tabRow": {
				"background": "#1E2030FF",
				"unfocusedBackground": "#181926FF"
			},
			"window": {
				"applicationTheme": "dark",
				"experimental.rainbowFrame": false,
				"frame": null,
				"unfocusedFrame": null,
				"useMica": false
			}
		},
		{
			"name": "Catppuccin Mocha",
			"tab": {
				"background": "#1E1E2EFF",
				"showCloseButton": "always",
				"unfocusedBackground": null
			},
			"tabRow": {
				"background": "#181825FF",
				"unfocusedBackground": "#11111BFF"
			},
			"window": {
				"applicationTheme": "dark",
				"experimental.rainbowFrame": false,
				"frame": null,
				"unfocusedFrame": null,
				"useMica": false
			}
		}

	],
```

<br>

#### Add keymap : 
```json
"actions": [

        {
            "command": "find",
            "keys": "ctrl+shift+f"
        },
        {
            "command": 
            {
                "action": "copy",
                "singleLine": false
            },
            "keys": "ctrl+c"
        },
        {
            "command": 
            {
                "action": "splitPane",
                "split": "right"
            },
            "keys": "ctrl+shift+\\"
        },
        {
            "command": "paste"
        },
        {
            "command": 
            {
                "action": "splitPane",
                "split": "auto",
                "splitMode": "duplicate"
            },
            "keys": "alt+shift+d"
        },
        {
            "command": 
            {
                "action": "resizePane",
                "direction": "up"
            },
            "keys": "ctrl+shift+up"
        },
        {
            "command": "closePane",
            "keys": "ctrl+shift+x"
        },
        {
            "command": 
            {
                "action": "resizePane",
                "direction": "right"
            },
            "keys": "ctrl+shift+right"
        },
        {
            "command": "unbound",
            "keys": "ctrl+v"
        },
        {
            "command": "unbound",
            "keys": "ctrl+shift+w"
        },
        {
            "command": "unbound",
            "keys": "alt+shift+down"
        },
        {
            "command": "unbound",
            "keys": "alt+shift+left"
        },
        {
            "command": "unbound",
            "keys": "alt+shift+right"
        },
        {
            "command": "unbound",
            "keys": "alt+shift+up"
        },
        {
            "command": "unbound",
            "keys": "alt+shift+minus"
        },
        {
            "command": "unbound",
            "keys": "alt+shift+plus"
        },
        {
            "command": 
            {
                "action": "splitPane",
                "split": "down"
            },
            "keys": "ctrl+shift+minus"
        },
        {
            "command": 
            {
                "action": "scrollDown"
            },
            "keys": "ctrl+down"
        },
        {
            "command": 
            {
                "action": "scrollUp"
            },
            "keys": "ctrl+up"
        },
        {
            "command": 
            {
                "action": "resizePane",
                "direction": "down"
            },
            "keys": "ctrl+shift+down"
        },
        {
            "command": 
            {
                "action": "resizePane",
                "direction": "left"
            },
            "keys": "ctrl+shift+left"
        }
        
    ],
```

<br>

#### Add custom config : 
```json
    "copyOnSelect": true,
```
```json
"profiles": {
		 "defaults": 
        {
            "colorScheme": "Aura Dark",
            "font": 
            {
                "cellHeight": "1.6",
                "face": "CaskaydiaCove Nerd Font Mono",
                "size": 13,
                "weight": "light"
            },
            "historySize": 12000,
            "intenseTextStyle": "bright",
            "opacity": 70,
            "padding": "15",
            "useAcrylic": true
        },
```


