# 🐸 Hopper

A small 2D platformer built in Godot where you guide a nimble frog through tricky terrain. Leap, dash, and try to get as many points as you can without losing all 3 lives!

## 🎮 Play the Game

👉 [Play Hopper in your browser](https://andy916.github.io/Hopper)  
*(No install required — runs directly in Chrome, Firefox, or Edge)*

## 🕹️ Controls

- **Arrow Keys / A & D** — Move left and right
- **Spacebar** — Jump
- **Left Shift** — Dash
- **Esc** — Pause

## 🧠 Features

- Tight platforming mechanics with responsive controls  
- Simple but polished visuals and animations  
- Built entirely in **Godot Engine** using **GDScript**  
- Exported to **Web** and **Windows** for easy access

## 🗂️ Project Structure

```text
Hopper/
├── docs/                      # Web build (for GitHub Pages)
│   ├── index.html
│   ├── hopper_godot.pck
│   ├── hopper_godot.wasm
│   └── hopper_godot.js
├── builds/                    # Windows executable
│   └── Hopper.exe
├── godot-project/             # Full editable Godot source
│   ├── project.godot
│   ├── export_presets.cfg
│   ├── .godot/                # Godot internal config
│   ├── scenes/                # Game scenes (.tscn)
│   ├── scripts/               # GDScript files (.gd)
│   ├── Audio/                 # Sound effects and music
│   ├── Pixel Adventure 1/     # External asset pack
│   ├── Pixel Adventure 2/     # External asset pack
│   ├── Custom Assets/         # My own art/sprites
│   ├── .gitattributes
│   └── .gitignore
└── README.md
```

## 🧪 Run Locally

To explore or modify the game:

1. Open the `/godot-project` folder in [Godot](https://godotengine.org/download).
2. Press **F5** to run the game.
3. To export your own build, use **Project > Export**.

## 💻 Download for Windows

Prefer to play offline?  
[Download Hopper.exe](./builds/Hopper.exe)

## 🛠️ Tech Stack

- [Godot Engine](https://godotengine.org/) (v4.5)
- GDScript
- Exported to HTML5 and Windows

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
