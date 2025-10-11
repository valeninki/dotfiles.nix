{
  lib,
  config,
  pkgs,
  unixpkgs,
  inputs,
  ...
}:

{
  home = {
    stateVersion = "25.05";
  };

  home.packages = with pkgs; [

    ## Fonts
    nerd-fonts.fira-code
    nerd-fonts.iosevka
    nerd-fonts.droid-sans-mono

    ## Must have packages
    xdg-user-dirs
    sl
    usbutils
    tmate
    dmidecode
    libva-utils
    rpi-imager
    scrcpy
    openssl

    ## Monitoring Packages
    fastfetch
    htop
    btop
    nvtopPackages.amd
    inxi
    gping
    gdu

    ## Window Manager and rice needded packages
    kitty
    wofi
    wl-clipboard
    cliphist
    grim
    slurp
    qt6ct

    ## Editing Things
    obsidian
    gimp
    obs-studio
    pavucontrol
    pulsemixer
    alsa-utils
    easyeffects
    pcmanfm
    unzip
    picard
    easytag
    yt-dlp
    ffmpeg
    binutils
    handbrake
    mpv
    vlc

    ## Coding Things
    git
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
    wireguard-tools
    #   openvpn3

    ## Kubernetes Packages
    k0sctl
    k3s
    kubernetes-helm

    ## User packages
    ungoogled-chromium
    equibop
    telegram-desktop
    gcr
    playerctl
    nextcloud-client
    gnome-keyring
    r2modman
    protonup-qt
    amberol
    chessx
    rustdesk
    prismlauncher
    libreoffice
  ];

  services = {
    hyprpolkitagent.enable = true;
    hyprpaper.enable = true;
    gnome-keyring.enable = true;
    cliphist.enable = true;
  };

  programs = {
    home-manager.enable = true;
  };

  fonts.fontconfig.enable = true;
  wayland.windowManager.hyprland.enable = true;

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
      configPackages = [ pkgs.xdg-desktop-portal-hyprland ];
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
      associations.added = {
        "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
        "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
      };
    };
  };

  home.file = {

  };

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland;xcb";
  };

  home.activation = { };
  imports =
    lib.map (p: ./. + "/${p}") (lib.remove "default.nix" (lib.attrNames (builtins.readDir ./.)))
    ++ [ inputs.self.homeManagerModules.valentinus ];
}
