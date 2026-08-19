{
  inputs,
  pkgs,
  unixpkgs,
  ...
}:

{
  home = {
    stateVersion = "25.11";
    username = "valentinus";
    homeDirectory = "/home/valentinus";

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

      ## Editing Things
      unixpkgs.obsidian
      gimp
      inkscape
      upscayl
      obs-studio
      pulsemixer
      alsa-utils
      easyeffects
      unzip
      unixpkgs.picard
      easytag
      ffmpeg
      binutils
      handbrake
      mpv
      vlc

      ## Coding Things
      distrobox
      unixpkgs.vscode
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
      unixpkgs.flux9s

      ## User packages
      ungoogled-chromium
      jellyfin-tui
      unixpkgs.equibop
      unixpkgs.telegram-desktop
      gcr
      unixpkgs.protonup-qt
      moonlight-qt
      gtkhash
      remmina
      amberol
      chessx
      rustdesk
      prismlauncher
      libreoffice
      darktable
      zathura
      freecad
    ];
  };

  fonts = {
    fontconfig = {
      enable = true;
    };
  };

  programs = {
    home-manager = {
      enable = true;
    };
  };

  services = {
    polkit-gnome.enable = true;
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
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = [ "pcmanfm.desktop" ];
        "x-scheme-handler/https" = [ "chromium-browser.desktop" ];
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

  imports = [ inputs.self.homeModules.full-desktop ];

}
