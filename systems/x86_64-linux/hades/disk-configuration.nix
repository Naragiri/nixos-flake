_: {
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-CT2000P5PSSD8_22513D4D5A9F";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "esp";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "uid=0"
                  "gid=0"
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
            };
            swap = {
              name = "swap";
              size = "48G";
              type = "8200";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
            root = {
              name = "root";
              size = "100%";
              type = "8300";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [ "noatime" ];
                extraArgs = [ "-O casefold -E encoding_flags=strict" ];
              };
            };
          };
        };
      };
      # sdb = {
      #   type = "disk";
      #   device = "/dev/disk/by-id/nvme-CT2000P5PSSD8_22513D4D8A1A";
      #   content = {
      #     type = "gpt";
      #     partitions = {
      #       games = {
      #         name = "games";
      #         size = "100%";
      #         type = "8300";
      #         content = {
      #           type = "filesystem";
      #           format = "f2fs";
      #           mountpoint = "/mnt/games";
      #           mountOptions = [ "noatime" ];
      #           extraArgs = [ "-O casefold -C utf8" ];
      #         };
      #       };
      #     };
      #   };
      # };
    };
  };
}
