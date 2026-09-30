{
  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 1;
      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "active";
      # TLP's built-in defaults set EPP and platform_profile on AC/BAT changes.
      # Override all three modes with empty values so manual selections persist.
      CPU_ENERGY_PERF_POLICY_ON_AC = "";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "";
      CPU_ENERGY_PERF_POLICY_ON_SAV = "";
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      PLATFORM_PROFILE_ON_AC = "";
      PLATFORM_PROFILE_ON_BAT = "";
      PLATFORM_PROFILE_ON_SAV = "";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 85;
    };
  };

  # platform_profile is a stable sysfs node; grant the interactive users group
  # access without making the Quickshell service root or installing PPD.
  systemd.tmpfiles.rules = [
    "z /sys/firmware/acpi/platform_profile 0664 root users - -"
  ];
}
