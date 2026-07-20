<!-- markdownlint-disable MD004 MD033 -->

<div align="center">

**English** | [Русский](README_RU.md)

# SchoolChecker

![Lua 5.1](https://img.shields.io/badge/Lua-5.1-2C2D72?style=flat-square&logo=lua&logoColor=white)
![WoW 3.3.5a](https://img.shields.io/badge/WoW-3.3.5a-C79C6E?style=flat-square)
[![License](https://img.shields.io/github/license/darhanger/SchoolChecker?style=flat-square)](https://github.com/darhanger/SchoolChecker/blob/main/LICENSE)
[![Last Release](https://img.shields.io/github/v/release/darhanger/SchoolChecker?style=flat-square)](https://github.com/darhanger/SchoolChecker/releases/latest)
[![Release Downloads](https://img.shields.io/github/downloads/darhanger/SchoolChecker/1.2/total?style=flat-square)](https://github.com/darhanger/SchoolChecker/releases)
[![All Downloads](https://img.shields.io/github/downloads/darhanger/SchoolChecker/total?style=flat-square)](https://github.com/darhanger/SchoolChecker/releases)
[![Discord Server](https://img.shields.io/badge/Discord-7289DA?style=flat-square&logo=discord&logoColor=white)](https://discord.gg/ZKFkvrzaU4)

**SchoolChecker** is a lightweight World of Warcraft addon that displays technical information about incoming spell damage in a separate movable frame.

Designed for **World of Warcraft 3.3.5a**.

</div>

## Features

SchoolChecker monitors combat log events related to damage received by the player and displays useful information about the spell responsible for each hit.

The addon can show:

- **Spell icon** — the icon associated with the incoming spell.
- **Spell name** — displayed as a clickable in-game spell link.
- **Spell ID** — the numeric identifier of the spell.
- **Damage school** — the school or combined school used by the spell.
- **Color coding** — each damage school is displayed using a distinct color.
- **Direct and periodic damage** — supports both regular spell hits and damage-over-time effects.

## Supported damage schools

SchoolChecker recognizes all standard World of Warcraft damage schools:

- Physical
- Holy
- Fire
- Nature
- Frost
- Shadow
- Arcane

Combined school masks are also supported, including schools such as:

- Frostfire
- Shadowfrost
- Shadowflame
- Spellfire
- Spellfrost
- Spellshadow
- Chaos
- other mixed school combinations

The exact displayed name depends on the school mask reported by the game client.

## Floating frame

Incoming spell information is displayed in a scrolling floating frame.

The frame can be:

- moved anywhere on the screen;
- resized using the handles in its lower corners;
- locked or unlocked with a right-click;
- kept inside the visible screen area;
- automatically restored after restarting the game.

The addon saves the frame position, size and lock state between sessions.

## Display example

SchoolChecker may display a message similar to:

```text
Damage from: [Shield Slam] (ID: 70964) - SCHOOL: Physical
```

The spell name is clickable and can be used to open the standard in-game spell tooltip.

<div align="center">

![SchoolChecker preview](https://github.com/user-attachments/assets/2fe0e143-31a9-4cf2-b98e-001e25138b20)

</div>

## Installation

1. Download the latest version from the [Releases](https://github.com/darhanger/SchoolChecker/releases) page.
2. Extract the downloaded archive.
3. Copy the `SchoolChecker` addon folder into:

```text
World of Warcraft\Interface\AddOns\
```

4. Make sure the resulting folder structure looks similar to:

```text
World of Warcraft
└── Interface
    └── AddOns
        └── SchoolChecker
            ├── SchoolChecker.toc
            ├── Core.lua
            ├── Core.xml
            ├── fonts
            └── textures
```

5. Restart the game client.
6. Enable **SchoolChecker** in the character selection addon list.

## Usage

The addon works automatically and does not require configuration.

- Receive spell damage to display information in the frame.
- Drag the frame with the left mouse button while it is unlocked.
- Resize it using the handles in the lower-left or lower-right corner.
- Right-click the frame to lock or unlock it.
- Left-click a spell link to open its tooltip.

## Localization

SchoolChecker includes built-in localization for:

- English
- Russian

English is used as the fallback language for other game client locales.

## Compatibility

- World of Warcraft **3.3.5a**
- Interface version **30300**
- Lua **5.1**
- Standard Blizzard combat log
- Standard Blizzard UI

Behavior on heavily modified custom clients may vary if their combat log events or spell school masks differ from the original client.

## Why use SchoolChecker?

SchoolChecker provides combat information directly inside the game client without requiring external databases or combat log analysis tools.

It can be useful for:

- identifying unknown boss and creature abilities;
- finding spell IDs for addon or server development;
- checking the damage school of incoming attacks;
- testing encounter mechanics;
- configuring defensive abilities and resistances;
- debugging custom server content;
- analyzing direct and periodic spell damage.

## Support

For bug reports, feature requests and suggestions, use:

- [GitHub Issues](https://github.com/darhanger/SchoolChecker/issues)

When reporting a problem, include:

- the game client or server name;
- steps required to reproduce the issue;
- the spell name or ID, when available;
- Lua error text, when available;
- a screenshot of the SchoolChecker frame.

## Contributing

Contributions are welcome.

You can help by:

- reporting bugs;
- improving spell school handling;
- testing compatibility with different 3.3.5a servers;
- submitting pull requests;
- improving translations or documentation.

## License

This project is distributed under the terms described in the [LICENSE](https://github.com/darhanger/SchoolChecker/blob/main/LICENSE) file.

---

<div align="center">

Made for World of Warcraft 3.3.5a

[Download](https://github.com/darhanger/SchoolChecker/releases) ·
[Report an issue](https://github.com/darhanger/SchoolChecker/issues) ·
[Discord](https://discord.gg/ZKFkvrzaU4)

</div>