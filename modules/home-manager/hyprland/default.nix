{

imports = [
  ./custom.nix
  ./cursor.nix
];
wayland.windowManager.hyprland.settings = {
      input = {
        kb_layout = "tr";
      };

      "$mod" = "SUPER";
      "$menu" = "wofi --show drun ";
      "$fileman" = "pcmanfm";
      "$active" = "rgb(7E5030)";
      "$secondary" = "rgb(00312C)";
      "$inactive" = "rgb(67131E)";


      env = [
        "XDG_CURRENT_DESKTOP, Hyprland"
	"XDG_SESSION_TYPE, wayland"
	"XDG_SESSION_DESKTOP, Hyprland"
	"QT_QPA_PLATFORM, wayland;xcb"
	"HYPRCURSOR_THEME, catppuccin-frappe-yellow-cursors"
	"HYPRCURSOR_SIZE, 24"
      ];

      decoration = {
      rounding = 12;
      rounding_power = 2.0;
      };

      general = {
      border_size = 2;
      "col.active_border" = "$active $secondary"; 
      "col.inactive_border" = "$inactive";
      gaps_in = 5;
      gaps_out = 5;
      };

      exec = [
        "pkill waybar & sleep 0.5 && waybar"
	"swaync"
	"systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
	"dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      ];
      exec-once = [
        "systemctl --user start hyprpolkitagent"
	"wl-paste --type text --watch cliphist store"
	"wl-paste --type image --watch cliphist store"
      ];

      bindm =
      [
      	"$mod, mouse:272, movewindow"
      	"$mod, mouse:273, resizewindow"
      ];

      bind =
      [
        "$mod, T, exec, kitty"
	"$mod, D, exec, $menu"
	"$mod, E, exec, $fileman"
	"$mod, Q, killactive"
	"$mod, C, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"
	"$mod, F, fullscreen"
	"$mod, L, exec, swaylock"

	## Move Focus With Mod and Arrow Keys
	"$mod, left, movefocus, l"
	"$mod, right, movefocus, r"
	"$mod, up, movefocus, u"
	"$mod, down, movefocus, d"

	## Move Active Window to Different Workspace
	"$mod SHIFT, 1, movetoworkspace, 1"
	"$mod SHIFT, 2, movetoworkspace, 2"
	"$mod SHIFT, 3, movetoworkspace, 3"
	"$mod SHIFT, 4, movetoworkspace, 4"
	"$mod SHIFT, 5, movetoworkspace, 5"

	## Scroll Through Existing Workspaces
	"$mod, mouse_down, workspace, e-1"
	"$mod, mouse_up, workspace, e+1"

	## Sound Binds
	",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
	",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
	",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"

        ## Media Binds
	",XF86AudioNext, exec, playerctl next"
        ",XF86AudioPause, exec, playerctl play-pause"
        ",XF86AudioPlay, exec, playerctl play-pause"
        ",XF86AudioPrev, exec, playerctl previous"

	## Screenshot Binds
	"$mod SHIFT, S, exec, grim -g \"$(slurp -d)\" - | wl-copy"
      ]
      ++ (
        builtins.concatLists (builtins.genList (i:
	 let ws = i + 1;
	 in [
	 "$mod, code:1${toString i}, workspace, ${toString ws}"

	 ]
	)
	9)
      );
    };

    services.hyprpaper.settings = {
      
      preload = ["/home/valentinus/Nextcloud/Photos/Wallpapers/Nature/flowers.jpg"];

    };
}
