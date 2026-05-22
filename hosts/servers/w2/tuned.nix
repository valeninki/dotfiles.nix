{
  services = {
    tuned = {
      enable = true;
      profiles = {
        k8s-worker2 = {
          main = {
            summary = "Custom profile for k8s W2 Node.";
            include = "latency-performance";
          };
          sysctl = {
            "net.core.netdev_budget" = 600;
            "net.core.netdev_budget_usecs" = 6666;
            "net.core.netdev_max_backlog" = 16384;
            "net.ipv4.tcp_rmem" = "4096 87380 33554432";
            "net.ipv4.tcp_wmem" = "4096 87380 33554432";
            "net.core.rmem_max" = 16777216;
            "net.core.wmem_max" = 16777216;
          };
        };
      };
    };
  };
}

