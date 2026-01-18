# CC Ore Automation

Automated ore processing system for Minecraft using CC: Tweaked (ComputerCraft). Supports both vanilla Minecraft ores and Create mod ores.

## Features

- **Vanilla Ore Processing**: Automates smelting and processing of all vanilla ores (iron, gold, copper, etc.)
- **Create Mod Integration**: Full support for Create mod ore processing (crushing wheels, washing, etc.)
- **Configurable**: Easy-to-edit configuration files for ore definitions and processing recipes
- **Modular Design**: Separate modules for different processing methods
- **Inventory Management**: Smart inventory handling with overflow protection
- **Redstone Control**: Start/stop automation via redstone signals

## Requirements

- Minecraft 1.18+ (or your target version)
- CC: Tweaked mod
- Create mod (optional, for Create ore processing)

## Project Structure

```
cc-ore-automation/
├── src/
│   ├── vanilla/        # Vanilla ore processing programs
│   ├── create/         # Create mod ore processing programs
│   └── lib/            # Shared libraries and utilities
├── config/             # Configuration files
└── docs/               # Documentation
```

## Installation

1. Copy the contents of `src/` to your ComputerCraft computer
2. Edit config files in `config/` to match your setup
3. Run the main program: `main`

## Usage

```lua
-- Start the ore automation system
main

-- Process specific ore type
process vanilla iron
process create zinc
```

## Configuration

Edit `config/ores.lua` to define your ore types and processing methods.

## Supported Ores

### Vanilla
- Iron Ore
- Gold Ore
- Copper Ore
- Coal Ore
- Diamond Ore
- Emerald Ore
- Lapis Lazuli Ore
- Redstone Ore
- Nether Gold Ore
- Nether Quartz Ore
- Ancient Debris

### Create Mod
- Zinc Ore
- Create Crushing (all ores)
- Create Washing (gravel, sand)

## License

MIT License

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
