{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.hardware.nvidia = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable the proprietary NVIDIA driver configuration.";
        };

        package = lib.mkOption {
            type = lib.types.anything;
            example = lib.literalExpression "config.boot.kernelPackages.nvidiaPackages.stable";
            description = "NVIDIA driver package to use for this host.";
        };

        prime = {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable NVIDIA PRIME offload support.";
            };

            intelBusId = lib.mkOption {
                type = lib.types.str;
                description = "PCI bus ID for the integrated Intel GPU used by PRIME.";
            };

            nvidiaBusId = lib.mkOption {
                type = lib.types.str;
                description = "PCI bus ID for the discrete NVIDIA GPU used by PRIME.";
            };
        };
    };

    config =
        let
            biryani_hw = config.biryani.hardware;
            supports32BitGraphics = pkgs.stdenv.hostPlatform.system == "x86_64-linux";
        in
        lib.mkIf biryani_hw.nvidia.enable {
            hardware.graphics = {
                enable = true;
                enable32Bit = supports32BitGraphics;
                extraPackages = [
                    pkgs.mesa
                    pkgs.nvidia-vaapi-driver
                ];
            };

            services.xserver.videoDrivers = [ "nvidia" ];

            hardware.nvidia = {
                package = biryani_hw.nvidia.package;

                modesetting.enable = true;

                powerManagement = {
                    enable = false;
                };

                open = false;

                nvidiaSettings = true;

                prime = lib.mkIf biryani_hw.nvidia.prime.enable {
                    offload = {
                        enable = true;
                        enableOffloadCmd = true;
                    };

                    intelBusId = biryani_hw.nvidia.prime.intelBusId;
                    nvidiaBusId = biryani_hw.nvidia.prime.nvidiaBusId;
                };
            };
        };
}
