{
  lib,
  inputs,
  pkgs,
  ...
}:

let
  unstable = import inputs.unixpkgs {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in

{
  home = {
    stateVersion = "25.11";
    username = "valentinus";
    homeDirectory = "/home/valentinus";

    sessionVariables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      QT_QPA_PLATFORM = "wayland;xcb";
    };

    file = { };

    activation = { };

    packages = with pkgs; [

      ## Fonts
      nerd-fonts.fira-code
      nerd-fonts.iosevka
      nerd-fonts.droid-sans-mono

      ## Must have packages
	  sops
	  ssh-to-age
      xdg-user-dirs
      usbutils
      tmate
      dmidecode
      libva-utils
      scrcpy
      openssl
	  sl

      ## ADB
      android-tools
      heimdall

      ## Monitoring Packages
      fastfetch
      htop
      btop
      nvtopPackages.amd
      inxi
      gping
      gdu
      dua
      iotop

      ## Window Manager and rice needded packages
      kitty
      wofi
      wl-clipboard
      cliphist
      grim
      slurp
      qt6Packages.qt6ct

      ## Optional
      tesseract4

      ## Editing Things
      obsidian
      gimp
      inkscape
      upscayl
      obs-studio
      pavucontrol
      pulsemixer
      alsa-utils
      easyeffects
      pcmanfm
      unzip
      picard
      easytag
      ffmpeg
      binutils
      handbrake
      mpv
      vlc

      ## Coding Things
      android-tools
      distrobox
      vscode
      bun

      ## Network Things
      ethtool
      nmap
      whois
      traceroute
      bind
      tcpdump
      mtr
      tshark
      termshark
      geoipWithDatabase

      ## VPN
      amneziawg-tools
      #openvpn3

      ## Kubernetes Packages
      k0sctl
      k3s
      kubernetes-helm

      ## User packages
      ungoogled-chromium
      jellyfin-tui
      unstable.equibop
      unstable.telegram-desktop
      gcr
      playerctl
      nextcloud-client
      r2modman
      protonup-qt
      moonlight-qt
      gtkhash
      remmina
      amberol
      chessx
      rustdesk
      prismlauncher
      libreoffice
      zathura
      freecad
    ];
  };

  fonts = {
    fontconfig = {
      enable = true;
    };
  };

  wayland = {
    windowManager = {
      hyprland = {
        enable = true;
      };
    };
  };

  programs = {
    home-manager = {
      enable = true;
    };
  };

  services = {
    hyprpolkitagent = {
      enable = true;
    };
    hyprpaper = {
      enable = true;
    };
    gnome-keyring = {
      enable = true;
    };
    cliphist = {
      enable = true;
    };
  };

  dconf = {
    settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      configPackages = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = [ "pcmanfm.desktop" ];
        "x-scheme-handler/https" = [ "google-chrome.desktop" ];
        "x-scheme-handler/discord" = [ "equibop.desktop" ];
        "x-scheme-handler/ror2mm" = [ "r2modman.desktop" ];
        "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
        "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
      };
      associations = {
        added = {
          "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
          "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
        };
      };
    };
  };

  imports =
    lib.map (p: ./. + "/${p}") (lib.remove "default.nix" (lib.attrNames (builtins.readDir ./.)))
    ++ [
      inputs.self.homeModules.cli
      inputs.self.homeModules.apps
      inputs.self.homeModules.desktop
    ];
}
