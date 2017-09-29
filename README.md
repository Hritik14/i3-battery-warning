# i3-battery-warning

This is a simple battery warning script. It uses i3's nagbar to display warnings.

Open your i3 conifg (~/.config/i3/config) and add this line

`exec --no-startup-id /PATH/TO/SCRIPT_DIR/i3batwarn.sh`

NOTE: `chmod +x SCRIPT`
Keep the script name `i3batwarn.sh`

## If you quit i3 often, add this in your i3 config as a precaution.
`bindsym $mod+Shift+e exec "killall i3batwarn.sh"; exit`

### Depends:
notify-send
