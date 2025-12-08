#!/bin/bash

# 20-20-20 Rule Eye Care Reminder
# A simple script to remind you to take eye breaks every 20 minutes

# Configuration
PERIOD_MINUTES=20
BREAK_SECONDS=20

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine data directory
if [ -f "$SCRIPT_DIR/ding.mp3" ]; then
    # Running from source directory
    DATA_DIR="$SCRIPT_DIR"
elif [ -f "/usr/local/share/20-20-rule/ding.mp3" ]; then
    # Installed system-wide
    DATA_DIR="/usr/local/share/20-20-rule"
elif [ -f "$HOME/.local/share/20-20-rule/ding.mp3" ]; then
    # Installed in user directory
    DATA_DIR="$HOME/.local/share/20-20-rule"
else
    # Fallback to script directory
    DATA_DIR="$SCRIPT_DIR"
fi

SOUND_FILE="$DATA_DIR/ding.mp3"
PID_FILE="/tmp/20-20-rule-$USER.pid"
FIFO_FILE="/tmp/20-20-rule-$USER.fifo"
PAUSE_FLAG_FILE="/tmp/20-20-rule-$USER.paused"

# Determine icon path
if [ -f "$SCRIPT_DIR/20-20-rule.svg" ]; then
    ICON_PATH="$SCRIPT_DIR/20-20-rule.svg"
elif [ -f "/usr/local/share/icons/hicolor/128x128/apps/20-20-rule.svg" ]; then
    ICON_PATH="/usr/local/share/icons/hicolor/128x128/apps/20-20-rule.svg"
elif [ -f "$HOME/.local/share/icons/hicolor/128x128/apps/20-20-rule.svg" ]; then
    ICON_PATH="$HOME/.local/share/icons/hicolor/128x128/apps/20-20-rule.svg"
else
    ICON_PATH="dialog-information"  # Fallback to system icon
fi

# Cleanup function
cleanup() {
    rm -f "$PID_FILE" "$FIFO_FILE" "$PAUSE_FLAG_FILE"
    pkill -P $$ 2>/dev/null
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM EXIT

# Check if already running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "20-20 Rule is already running (PID: $OLD_PID)"
        notify-send --urgency=normal --app-name="20-20-20 Rule" "Already Running" "20-20 Rule is already running."
        exit 1
    fi
fi

# Save PID
echo $$ > "$PID_FILE"

# Create FIFO for communication
rm -f "$FIFO_FILE"
mkfifo "$FIFO_FILE"

# Function to show break notification
show_break_notification() {
    notify-send --urgency=critical --expire-time=$((BREAK_SECONDS*1000)) --icon="$ICON_PATH" --app-name="20-20-20 Rule" "Take a break" "Look at an object 20 feet (6 meters) away for ${BREAK_SECONDS} seconds."
    
    # Play sound if available
    if [ -f "$SOUND_FILE" ] && command -v mpv &> /dev/null; then
        mpv --really-quiet "$SOUND_FILE" &
    fi
    
    sleep ${BREAK_SECONDS}
    
    # Play sound again if available
    if [ -f "$SOUND_FILE" ] && command -v mpv &> /dev/null; then
        mpv --really-quiet "$SOUND_FILE" &
    fi
}

# Timer function (runs in background)
timer_loop() {
    while true; do
        sleep $((PERIOD_MINUTES * 60))
        
        # Check if paused (by checking if pause flag file exists)
        if [ ! -f "$PAUSE_FLAG_FILE" ]; then
            show_break_notification
        fi
    done
}

# Start timer in background
timer_loop &
TIMER_PID=$!

# Show startup notification
notify-send --urgency=normal --expire-time=3000 --icon="$ICON_PATH" --app-name="20-20-20 Rule" "Started" "20-20 Rule reminder started. You will be reminded every ${PERIOD_MINUTES} minutes."

# Start yad notification icon
(
    yad --notification \
        --image="$ICON_PATH" \
        --text="20-20-20 Rule: Running" \
        --command="bash -c 'echo toggle > $FIFO_FILE'" \
        --menu="Pause!bash -c 'echo pause > $FIFO_FILE'!gtk-media-pause|Exit!bash -c 'echo quit > $FIFO_FILE'!gtk-quit" \
        --listen <&3 &
    YAD_PID=$!
    
    # Monitor FIFO for commands
    while true; do
        if read -r cmd < "$FIFO_FILE"; then
            case "$cmd" in
                pause)
                    if [ ! -f "$PAUSE_FLAG_FILE" ]; then
                        touch "$PAUSE_FLAG_FILE"
                        echo "tooltip:20-20-20 Rule: Paused" >&3
                        echo "menu:Resume!bash -c 'echo resume > $FIFO_FILE'!gtk-media-play|Exit!bash -c 'echo quit > $FIFO_FILE'!gtk-quit" >&3
                        notify-send --urgency=normal --icon="$ICON_PATH" --app-name="20-20-20 Rule" "Paused" "Eye care reminders paused."
                    fi
                    ;;
                resume)
                    if [ -f "$PAUSE_FLAG_FILE" ]; then
                        rm -f "$PAUSE_FLAG_FILE"
                        echo "tooltip:20-20-20 Rule: Running" >&3
                        echo "menu:Pause!bash -c 'echo pause > $FIFO_FILE'!gtk-media-pause|Exit!bash -c 'echo quit > $FIFO_FILE'!gtk-quit" >&3
                        notify-send --urgency=normal --icon="$ICON_PATH" --app-name="20-20-20 Rule" "Resumed" "Eye care reminders resumed."
                    fi
                    ;;
                toggle)
                    if [ -f "$PAUSE_FLAG_FILE" ]; then
                        rm -f "$PAUSE_FLAG_FILE"
                        echo "tooltip:20-20-20 Rule: Running" >&3
                        echo "menu:Pause!bash -c 'echo pause > $FIFO_FILE'!gtk-media-pause|Exit!bash -c 'echo quit > $FIFO_FILE'!gtk-quit" >&3
                        notify-send --urgency=normal --icon="$ICON_PATH" --app-name="20-20-20 Rule" "Resumed" "Eye care reminders resumed."
                    else
                        touch "$PAUSE_FLAG_FILE"
                        echo "tooltip:20-20-20 Rule: Paused" >&3
                        echo "menu:Resume!bash -c 'echo resume > $FIFO_FILE'!gtk-media-play|Exit!bash -c 'echo quit > $FIFO_FILE'!gtk-quit" >&3
                        notify-send --urgency=normal --icon="$ICON_PATH" --app-name="20-20-20 Rule" "Paused" "Eye care reminders paused."
                    fi
                    ;;
                quit)
                    kill $YAD_PID 2>/dev/null
                    cleanup
                    ;;
            esac
        fi
    done
) 3>&1 &

# Wait for signals
wait
