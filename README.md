# FS25 Shop Engine Sound Preview Mod

This repository contains a Farming Simulator 25 mod that lets players preview a vehicle's engine sound directly in the vehicle shop before purchasing.

## Features
- Adds a new input action in the shop configuration screen.
- Press the assigned key/button to start or stop the currently previewed vehicle's engine.
- Automatically stops engine preview when switching to another vehicle or closing the shop.
- Multiplayer-safe and dedicated-server compatible (client GUI feature, no server-side state changes).

## Default Controls
- **Keyboard/Mouse:** `K`
- **Gamepad:** `X`

(Controls can be changed in the in-game input bindings menu.)

## Mod File Structure
- `modDesc.xml`
- `inputBinding.xml`
- `scripts/ShopEnginePreview.lua`
- `l10n/texts_en.xml`
- `l10n/texts_de.xml`

## Packaging
Zip the repository contents so that `modDesc.xml` is at the root of the zip, then place the zip in your FS25 mods folder.
