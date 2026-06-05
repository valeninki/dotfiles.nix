# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  pkgs,
  lib,
  ...
}:

{

  boot = {
    kernelPackages = pkgs.linuxPackages_6_18;
    loader = {
      timeout = 1;
      grub = {
        enable = false;
      };
      generic-extlinux-compatible = {
        enable = true;
      };
    };
  };

  networking = {
    hostName = "pi";
    networkmanager = {
      enable = true;
    };
  };

  time = {
    timeZone = "Europe/Istanbul";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  console = {
    packages = [ pkgs.terminus_font ];
    font = "ter-v16b";
    keyMap = lib.mkForce "trq";
    useXkbConfig = true;
    earlySetup = true;
  };

  users = {
    users = {
      berry = {
        isNormalUser = true;
        home = "/home/berry";
        shell = pkgs.fish;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
      };
    };
  };

  security = {
    doas = {
      enable = true;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      git
      wget
      ethtool
      networkd-dispatcher
      wakeonlan
      (fastfetch.override {
        openglSupport = false;
        vulkanSupport = false;
        waylandSupport = false;
        x11Support = false;
        xfceSupport = false;
        gnomeSupport = false;
        enlightenmentSupport = false;
        openclSupport = false;
        imageSupport = false;
        dbusSupport = false;
      })
    ];
  };

  programs = {
    nix-ld = {
      enable = true;
    };
    fish = {
      enable = true;
    };
  };

  services = {
    xserver = {
      videoDrivers = lib.mkForce [ ];
    };
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        KbdInteractiveAuthentication = false;
      };
    };
    s3 = {
      enable = true;
    };
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  system = {
    stateVersion = "25.11";
  };

}
