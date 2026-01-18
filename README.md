# CC Ore Automation

Automated ore processing system for Minecraft using CC: Tweaked (ComputerCraft). Supports both vanilla Minecraft ores and Create mod ores.

## Features

- **Vanilla Ore Processing**: Automates smelting and processing of all vanilla ores (iron, gold, copper, etc.)
- **Create Mod Integration**: Full support for Create mod ore processing (crushing wheels, washing, etc.)
- **Configurable**: Easy-to-edit configuration files for ore definitions and processing recipes
- **Modular Design**: Separate modules for different processing methods
- **Inventory Management**: Smart inventory handling with overflow protection
- **Redstone Control**: Start/stop automation via redstone signals
- **Auto-Update**: Built-in update checker and installer

## Requirements

- Minecraft 1.18+ (or your target version)
- CC: Tweaked mod
- Create mod (optional, for Create ore processing)

## Installation

### First-Time Install

Run this command on your ComputerCraft computer:

```
wget run https://raw.githubusercontent.com/tyler919/cc-ore-automation/main/install.lua
```

This will download and install all necessary files automatically.

### Updating

The program automatically checks for updates on startup. You can also:

- Press `[U]` in the main menu to check for/install updates
- Run `update` directly from the shell

## Usage

After installation, start the program:

```
main
```

### Main Menu Options

- `[1]` Start Auto Processing - Process both vanilla and Create ores
- `[2]` Vanilla Ores Only - Only process vanilla ores
- `[3]` Create Ores Only - Only process Create mod ores
- `[4]` View Status - See connected peripherals and system status
- `[5]` Configure - (Coming soon)
- `[U]` Check for Updates / Update Now
- `[Q]` Quit

### Redstone Control

Apply a redstone signal to the back of the computer to pause processing.

## Project Structure

```
/ (Computer Root)
├── main.lua           # Main program
├── update.lua         # Update manager
├── version.txt        # Current version
├── lib/
│   └── utils.lua      # Shared utilities
├── vanilla/
│   └── processor.lua  # Vanilla ore processor
├── create/
│   └── processor.lua  # Create mod processor
└── config/
    └── ores.lua       # Ore configuration
```

## Configuration

Edit `config/ores.lua` to customize:

- Processing intervals
- Enable/disable vanilla or Create processing
- Redstone control settings
- Peripheral names (or leave as auto-detect)

## Supported Ores

### Vanilla
- Iron Ore (+ Deepslate, Raw)
- Gold Ore (+ Deepslate, Raw, Nether)
- Copper Ore (+ Deepslate, Raw)
- Coal Ore (+ Deepslate)
- Diamond Ore (+ Deepslate)
- Emerald Ore (+ Deepslate)
- Lapis Lazuli Ore (+ Deepslate)
- Redstone Ore (+ Deepslate)
- Nether Quartz Ore
- Ancient Debris

### Create Mod
- Zinc Ore (+ Deepslate, Raw)
- Crushed Raw Iron → Washing
- Crushed Raw Gold → Washing
- Crushed Raw Copper → Washing
- Crushed Raw Zinc → Washing
- Gravel → Washing
- Soul Sand → Washing

## License

MIT License

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
