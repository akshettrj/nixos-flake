{ ... }:
{
    specialisation = {
        less_cores.configuration = {
            boot.kernelParams = [ "maxcpus=5" ];
        };
    };
}
