# CC Ore Automation (SFM Edition)

Automated deepslate ore processing system for Minecraft using **Super Factory Manager (SFM)** and Create mod. Converts dirt and water into iron, copper, zinc, gold, and brass ingots.

## Requirements

- Minecraft 1.19.2+ (or your modpack version)
- **Super Factory Manager (SFM)** mod
- **Create** mod
- Inventory cables and labels

## SFM Setup

You need:
1. **Factory Manager** block
2. **Label Gun**
3. **Disk** (to save programs)
4. **Inventory Cables** to connect machines

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

## SFM Programs

### 01-mud.sfm - Mud Maker

**Labels needed:**
| Label | Block | Description |
|-------|-------|-------------|
| `storage` | Chest/Drawer | Main item storage |
| `water` | Fluid Tank | Water source |
| `basin` | Create Basin | With mixer above |

**What it does:**
1. Takes dirt from storage → puts in basin
2. Takes 200mB water from tank → puts in basin
3. Mixer combines them into mud
4. Takes mud from basin → puts in storage

## Installation

1. Download the `.sfm` files from the `sfm/` folder
2. In Minecraft, put a disk in the Factory Manager
3. Open the manager and paste/type the program
4. Use the Label Gun to label your blocks
5. Connect everything with inventory cables
6. Click "Run" in the Factory Manager

## Project Structure

```
sfm/
├── 01-mud.sfm          # Mud automation
├── 02-packed-mud.sfm   # (coming soon)
├── 03-crushing.sfm     # (coming soon)
└── ...
```

## Output Metals

| Metal | Source | Chance |
|-------|--------|--------|
| Iron | Deepslate crushing | 30% |
| Copper | Deepslate crushing | 25% |
| Zinc | Deepslate crushing | 20% |
| Gold | Deepslate crushing | 15% |
| Brass | Alloying (2 Copper + 1 Zinc) | N/A |

## Resources

- [SFM GitHub](https://github.com/TeamDman/SuperFactoryManager)
- [SFM CurseForge](https://www.curseforge.com/minecraft/mc-mods/super-factory-manager)
- [SFM Examples](https://github.com/TeamDman/SuperFactoryManager/tree/1.18/examples)

## License

MIT License
