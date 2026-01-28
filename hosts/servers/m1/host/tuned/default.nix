{
  services.tuned = {
    enable = true;
    profiles = {
      k8s-master = {
        main = {
          summary = "Custom profile for k8s Master Node.";
          include = "latency-performance";
        };
        sysctl = {
          "net.ipv4.ip_local_port_range" = "1024 65535";
          "net.ipv4.tcp_tw_reuse" = 1;
          "net.core.somaxconn" = 4096;
          "net.ipv4.tcp_max_syn_backlog" = 4096;
          "net.ipv4.tcp_rmem" = "4096 87380 33554432";
          "net.ipv4.tcp_wmem" = "4096 87380 33554432";
          "fs.file-max" = 2097152;
          "net.ipv4.neigh.default.gc_thresh1" = 1024;
          "net.ipv4.neigh.default.gc_thresh2" = 2048;
          "net.ipv4.neigh.default.gc_thresh3" = 4096;
        };
      };
    };
  };
}
