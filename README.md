# 20-20-Rule

A simple bash script implementing the 20-20-20 rule for eye care: every 20 minutes, take a 20-second break and look at something 20 feet (6 meters) away.

## Features

- **System Tray Icon**: Runs in the background with a system tray icon
- **Pause/Resume**: Right-click menu to pause and resume reminders
- **Audio Alerts**: Plays sound notifications at the start and end of breaks
- **Visual Notifications**: Desktop notifications to remind you to take breaks
- **Auto-start Support**: Desktop file for easy launching from application menu

## Dependencies

Required:
- `notify-send` (libnotify)
- `yad` (Yet Another Dialog - for system tray icon)
- `mpv` (for audio playback)

Installation on Ubuntu/Debian:
```bash
sudo apt install libnotify-bin yad mpv
```

Installation on Arch Linux:
```bash
sudo pacman -S libnotify yad mpv
```

Installation on Fedora:
```bash
sudo dnf install libnotify yad mpv
```

## Installation

### Option 1: System-wide Installation (requires sudo)

```bash
sudo make install
```

This installs to `/usr/local` by default. To install to a different location:

```bash
sudo make install PREFIX=/usr
```

### Option 2: User Installation (no sudo required)

```bash
make user-install
```

This installs to `~/.local`. Make sure `~/.local/bin` is in your PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Option 3: Run from Source

```bash
./20-20-rule.sh
```

## Usage

After installation, you can:

1. **Launch from terminal**: `20-20-rule`
2. **Launch from application menu**: Search for "20-20-20 Rule" or "20-20-20 护眼提醒"
3. **Control via tray icon**: Right-click the tray icon to pause/resume or exit

### Tray Icon Controls

- **Left-click**: (Reserved for future use)
- **Right-click**: Open menu
  - **Pause**: Temporarily stop reminders
  - **Resume**: Restart reminders
  - **Exit**: Close the application

## Uninstallation

### System-wide:
```bash
sudo make uninstall
```

### User installation:
```bash
make user-uninstall
```

## Customization

You can customize the timing by editing the script variables:

- `PERIOD_MINUTES`: Time between reminders (default: 20 minutes)
- `BREAK_SECONDS`: Duration of each break (default: 20 seconds)

## The 20-20-20 Rule

The 20-20-20 rule is a simple technique to reduce eye strain:

- Every **20 minutes**
- Look at something **20 feet** (6 meters) away
- For at least **20 seconds**

This helps reduce eye fatigue when working on computers or screens for extended periods.

## Legacy Script

The original simple script `scriptReminder.sh` is still available for those who prefer a minimal implementation without system tray support.

## Credits
- This project is originally a fork of [ShahzamanRai/20-20-Rule](https://github.com/ShahzamanRai/20-20-Rule).
- It's mainly written by AI (with manually testing and tweaking later).

## License
MIT License
