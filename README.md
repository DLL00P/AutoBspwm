# AutoBspwm
> This is a Bash script that automates the setup of a professional hacking environment for Kali Linux using the tiled window manager [bspwm](https://github.com/baskerville/bspwm).

## Installation
1. Install available updates.

```shell
sudo apt update
sudo apt upgrade -y
```

2. Clone the repository and navigate to it.

```shell
git clone https://github.com/DLL00P/AutoBspwm.git
cd AutoBspwm
```

3. Grant execution permissions to the script.

```shell
chmod +x setup.sh
```

4. Execute the script.

```shell
./setup.sh
```

5. After the script has finished, you will be prompted to restart the system. Once you have rebooted, select `bspwm` as the window manager and then log in.
   
![Bspwm](/assets/Bspwm.png "Bspwm")

## Top bar
Separate rounded islands that take their colours from the wallpaper:

| Left | Centre | Right |
|---|---|---|
| Kali dragon launcher (click: apps, right-click: wallpaper picker) · date and time · LAN IP · VPN IP (`tun*`) | Workspaces: a bug marks the active one, dots the rest (filled = has windows) | Target (`settarget <IP> [NAME]`, `cleartarget`) · wallpaper (click: random, middle: picker, right: pin) · volume · power menu |

## Wallpapers and adaptive colours
On every login a random wallpaper is picked from `~/Wallpapers`, and the colours of **polybar, rofi, kitty, the Powerlevel10k prompt and the bspwm borders** are generated from it (open terminals pick up the new prompt colours on the next prompt) with [pywal](https://github.com/eylles/pywal16).

- `config/bspwm/scripts/wallpaper.sh` sets the wallpaper and recolours everything (`--random`, `--next`, `--prev`, `--pick`, `--set FILE`, `--cycle MIN`, `--pin`).
  
- `config/bspwm/scripts/theme-colors.py` turns the pywal palette into the bar colours: it picks the two most vivid, clearly different colours of the image, builds the bar shades as a gradient between them, and forces each shade to a luminance where white text keeps at least 4.5:1 contrast.
  
- `config/bspwm/scripts/get-wallpapers.sh` downloads the anime collection from [dharmx/walls](https://github.com/dharmx/walls) (~300 images, about 600 MB). Add more categories with `get-wallpapers.sh evangelion manga`, list them with `--list`, or choose them at install time with `WALLPAPER_CATEGORIES="anime evangelion" ./setup.sh`.
  
- Your own images: drop them anywhere under `~/Wallpapers` (or in this repo's `wallpapers/` folder before installing).
  
- Automatic rotation: uncomment the `wallpaper.sh --cycle 30` line in `bspwmrc`.

- Popular anime (Naruto, One Piece, Demon Slayer, Chainsaw Man, Jujutsu Kaisen, Attack on Titan, Dragon Ball, Solo Leveling, Frieren…): `get-wallpapers.sh --popular` downloads the most favourited safe-for-work wallpapers of each from [Wallhaven](https://wallhaven.cc), one folder per series. Any other anime: `get-wallpapers.sh --series "blue lock" "vinland saga"`. Change how many per series with `COUNT=40`.

## Overview of the environment
![overview1](/assets/Wallpaper1.png "overview1")

![overview2](/assets/Wallpaper2.png "overview2")

---

![overview3](/assets/Wallpaper3.png "overview3")

---

![overview4](/assets/Wallpaper4.png "overview4")

---

![overview5](/assets/Wallpaper5.png "overview5")

---

![overview6](/assets/Wallpaper6.png "overview6")

---

![overview7](/assets/Wallpaper7.png "overview7")

---

![overview8](/assets/Wallpaper8.png "overview8")

### Wallpaper
| Shortcut | Action |
|---|---|
| <kbd>Alt</kbd> + <kbd>F9</kbd> | Change to a random wallpaper. Bar, rofi, kitty, prompt and borders take its colours. |
| <kbd>Alt</kbd> + <kbd>F10</kbd> | Pin / unpin the current wallpaper and its colours. While pinned it survives logins and reboots, and the change shortcuts are disabled. |

> On a laptop you may need <kbd>Fn</kbd> as well (<kbd>Alt</kbd> + <kbd>Fn</kbd> + <kbd>F9</kbd>). The same actions are available by clicking the wallpaper icon in the top bar: left click for a random wallpaper, right click to pin.

## Keyboard shortcuts
- <kbd>Windows</kbd> + <kbd>Enter</kbd>: Open a terminal emulator window (kitty).
- <kbd>Windows</kbd> + <kbd>W</kbd>: Close the current window.
- <kbd>Windows</kbd> + <kbd>Alt</kbd> + <kbd>R</kbd>: Restart the bspwm configuration.
- <kbd>Windows</kbd> + <kbd>Alt</kbd> + <kbd>W</kbd> or <kbd>Alt</kbd> + <kbd>F9</kbd>: Random wallpaper (colours follow it).
- <kbd>Windows</kbd> + <kbd>Alt</kbd> + <kbd>,</kbd> / <kbd>.</kbd>: Previous / next wallpaper.
- <kbd>Windows</kbd> + <kbd>Alt</kbd> + <kbd>P</kbd>: Pick a wallpaper from a thumbnail grid (also right-click on the launcher icon).
- <kbd>Windows</kbd> + <kbd>Alt</kbd> + <kbd>F</kbd> or <kbd>Alt</kbd> + <kbd>F10</kbd>: Pin / unpin the current wallpaper and its colours. While pinned it survives logins and reboots, and the change shortcuts are disabled.
- <kbd>Windows</kbd> + <kbd>Alt</kbd> + <kbd>Q</kbd>: Log out.
- <kbd>Windows</kbd> + <kbd>(⬆⬅⬇➡)</kbd>: Navigate through windows in the current workspace.
- <kbd>Windows</kbd> + <kbd>D</kbd>: Open Rofi. Press <kbd>Esc</kbd> to exit.
- <kbd>Windows</kbd> + <kbd>(1,2,3,4,5,6,7,8,9,0)</kbd>: Switch to the respective workspace.
- <kbd>Windows</kbd> + <kbd>T</kbd>: Change the current window to tile mode.
- <kbd>Windows</kbd> + <kbd>M</kbd>: Toggle the current window to "full" mode (doesn't occupy the polybar). Press the same keys to return to tile mode.
- <kbd>Windows</kbd> + <kbd>F</kbd>: Change the current window to fullscreen mode (occupies the entire screen, including the polybar).
- <kbd>Windows</kbd> + <kbd>S</kbd>: Change the current window to floating mode.
- <kbd>Windows</kbd> + <kbd>Shift</kbd> + <kbd>(1,2,3,4,5,6,7,8,9,0)</kbd>: Move the current window to another workspace.
- <kbd>Windows</kbd> + <kbd>Alt</kbd> + <kbd>(⬆⬅⬇➡)</kbd>: Resize the current window (only works if it's in floating mode).
- <kbd>Windows</kbd> + <kbd>Ctrl</kbd> + <kbd>(⬆⬅⬆➡)</kbd>: Change the position of the current window (only works if it's in floating mode).
- <kbd>Windows</kbd> + <kbd>Shift</kbd> + <kbd>F</kbd>: Open Firefox.
- <kbd>Windows</kbd> + <kbd>Shift</kbd> + <kbd>B</kbd>: Open Burpsuite.
- <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>L</kbd>: Lock the screen.
- <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>⬆⬇</kbd>: Increase/decrease volume.
- <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>M</kbd>: Mute/unmute volume.
- <kbd>Windows</kbd> + <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>(⬆⬅⬇➡)</kbd>: Show a preselection and then open a window (kitty, Firefox, File manager, etc.). 
   - <kbd>Windows</kbd> + <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Space</kbd>: Undo the preselection.
- <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Enter</kbd>: Open a sub-window in the current window.
- <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Z</kbd>: Zoom in on the current sub-window.
- <kbd>Ctrl</kbd> + <kbd>(⬆⬅⬇➡)</kbd>: Navigate between sub-windows in the current window.
- <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd>: Resize the current sub-window. Afterward, use:
   - <kbd>W</kbd> for 'Wider'
   - <kbd>N</kbd> for 'Narrower'
   - <kbd>T</kbd> for 'Taller'
   - <kbd>S</kbd> for 'Shorter'
   - <kbd>R</kbd> for 'Reset'
   - <kbd>Esc</kbd> to quit resize mode.
- <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>L</kbd>: Toggle the arrangement of sub-windows.
- <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>W</kbd>: Close the current sub-window or tab.
- <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>T</kbd>: Open a tab in the current window.
- <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Alt</kbd> + <kbd>T</kbd>: Rename the title of the current tab.
- <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>(⬅➡)</kbd>: Navigate between current tabs.
- <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>C</kbd>: Copy to the clipboard.
- <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd>: Paste from the clipboard.
- <kbd>F1</kbd>: Copy to buffer A.
- <kbd>F2</kbd>: Paste from buffer A.
- <kbd>F3</kbd>: Copy to buffer B.
- <kbd>F4</kbd>: Paste from buffer B.

## Software
This configuration uses the following software:
- **WM**: [bspwm](https://github.com/baskerville/bspwm)
- **Hotkey**: [sxhkd](https://github.com/baskerville/sxhkd)
- **Locker**: [i3lock-fancy](https://github.com/meskarune/i3lock-fancy)
- **Shell**: [zsh](https://www.zsh.org/)
- **Shell Theme**: [powerlevel10k](https://github.com/romkatv/powerlevel10k)
- **Shell configuration manager**: [ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)
- **Bars**: [polybar](https://github.com/polybar/polybar)
- **Bars Theme**: [polybar-themes](https://github.com/adi1090x/polybar-themes)
- **Compositor**: [picom](https://github.com/yshui/picom)
- **File Manager**: [thunar](https://docs.xfce.org/xfce/thunar/start)
- **Fonts**: [iosevka](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Iosevka) and [hack](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Hack)
- **Application Launcher**: [rofi](https://github.com/davatorium/rofi)
- **Browsers**: [firefox](https://www.mozilla.org/en-US/firefox/new/)
- **Terminals**: [kitty](https://sw.kovidgoyal.net/kitty/) and [qterminal](https://github.com/lxqt/qterminal)
- **Wallpaper**: [feh](https://github.com/derf/feh)
- **Colour scheme from wallpaper**: [pywal16](https://github.com/eylles/pywal16)
- **Screenshot**: [flameshot](https://flameshot.org/)

## Credits
- This environment has been inspired by the functionalities of [S4vitar's](https://github.com/s4vitar) environment.
- Based on [auto-bspwm](https://github.com/r1vs3c/auto-bspwm) by [r1vs3c](https://github.com/r1vs3c).
- Top bar style inspired by [AutoBspwm](https://github.com/ZLCube/AutoBspwm) by [ZLCube](https://github.com/ZLCube).
- Anime wallpapers from [dharmx/walls](https://github.com/dharmx/walls) and [Wallhaven](https://wallhaven.cc); all rights belong to their original artists.
