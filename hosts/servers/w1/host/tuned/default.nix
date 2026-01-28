{
  services.tuned = {
    enable = true;
    profiles = {
      k8s-master = {
        main = {
          summary = "Custom profile for k8s Worker 1 Node.";
          include = "latency-performance";
        };
        sysctl = {
          "net.ipv4.tcp_rmem" = "4096 87380 33554432";
          "net.ipv4.tcp_wmem" = "4096 87380 16777216";
          "net.ipv4.tcp_notsent_lowat" = 16384;
          "net.ipv4.tcp_slow_start_after_idle" = 0;
        };
      };
    };
  };
}
