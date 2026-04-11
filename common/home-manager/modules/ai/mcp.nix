{
  config,
  lib,
  ...
}: {
  config = let
    pro_ai = config.propheci.programs.ai;
  in
    lib.mkIf pro_ai.enable {
      programs.mcp = {
        enable = true;
        servers = pro_ai.mcpServers;
      };
    };
}

