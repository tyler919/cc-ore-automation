# CC Ore Automation

Automated deepslate ore processing system for Minecraft using CC: Tweaked and Create mod. Converts dirt and water into iron, copper, zinc, gold, and brass ingots.

## Features

- **Full Automation**: Dirt + Water → Ingots, completely automated
- **Multiple Metals**: Iron, Copper, Zinc, Gold, and Brass
- **Storage Limits**: Automatically stops when storage reaches 640 items (10 stacks)
- **Live Monitoring**: Real-time display of inventory counts and fluid levels
- **Redstone Control**: Control machine sections via redstone outputs
- **Auto-Update**: Built-in update checker and installer

## Requirements

- Minecraft with Create mod
- CC: Tweaked mod
- Advanced Computer (for colors) or standard Computer

## Installation

Run this command on your ComputerCraft computer:

```
wget run https://raw.githubusercontent.com/tyler919/cc-ore-automation/main/install.lua
```

## Processing Chain

```
Step 1: Dirt + 200mB Water → Basin + Mixer → Mud
Step 2: Mud + Wheat → Crafting → Packed Mud
Step 3: Packed Mud → Crushing Wheels → Cobbled Deepslate + Deepslate Chunks
Step 4: Cobbled Deepslate → Furnace → Deepslate
Step 5: 4x Deepslate Chunks → Basin + Press → Cobbled Deepslate
Step 6: Deepslate → Crushing Wheels → Raw Ore Chunks
        ├── Raw Iron (30%)
        ├── Raw Copper (25%)
        ├── Raw Zinc (20%)
        ├── Raw Gold (15%)
        └── XP Nugget (5%)
Step 7: Raw Ore → Heated Basin + Mixer → 5mB Molten Metal
Step 8: 2mB Copper + 1mB Zinc → 3mB Molten Brass
Step 9: 45mB Molten Metal → Basin + Press → 1 Ingot
```

## Usage

After installation, start the program:

```
main
```

### Main Menu

- `[1]` Start Processing - Begin the automation loop
- `[2]` Stop Processing - Stop all machines
- `[3]` View Status - See peripherals and redstone states
- `[4]` View Inventory - See ingot counts and fluid levels
- `[U]` Check for Updates
- `[Q]` Quit

### Processing Display

While running, the display shows:
- Current status (Running/Paused)
- Ingot counts for each metal
- Automatic pause when any metal reaches 640

## Configuration

Edit `config/ores.lua` to customize:

```lua
config.settings = {
    processInterval = 1,      -- Seconds between checks
    maxItems = 640,           -- Storage limit (10 stacks)
    mbPerIngot = 45,          -- Molten metal per ingot

    redstoneOutput = {
        mudMaker = "left",    -- Controls dirt/water input
        crusher = "right",    -- Controls crushing wheels
        smelter = "back",     -- Controls furnaces
        melter = "top",       -- Controls heated mixer
    },
}
```

## Project Structure

```
/ (Computer Root)
├── main.lua           # Main program
├── update.lua         # Update manager
├── version.txt        # Current version
├── lib/
│   └── utils.lua      # Shared utilities
├── create/
│   └── processor.lua  # Ore processor
└── config/
    └── ores.lua       # Configuration
```

## Output Metals

| Metal | Source | Chance |
|-------|--------|--------|
| Iron | Deepslate crushing | 30% |
| Copper | Deepslate crushing | 25% |
| Zinc | Deepslate crushing | 20% |
| Gold | Deepslate crushing | 15% |
| Brass | Alloying (2 Copper + 1 Zinc) | N/A |
| XP Nuggets | Deepslate crushing | 5% |

## License

MIT License

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
