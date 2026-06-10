{ config, lib, ... }: {
    config =
        let
            biryani_ai = config.biryani.programs.ai;
        in
        lib.mkIf biryani_ai.enable {
            programs.mcp = {
                enable = true;
                servers = biryani_ai.mcpServers;
            };
        };
}
