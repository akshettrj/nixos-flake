{
  config,
  lib,
  ...
}: {
  config = let
    pro_ai = config.propheci.programs.ai;
    pro_codex = pro_ai.codex;
  in
    lib.mkIf (pro_ai.enable && pro_codex.enable) {
      programs.codex = {
        enable = true;
        enableMcpIntegration = true;
        skills = pro_ai.skills;
        settings = {
          mcpServers = lib.mkIf (pro_codex.mcpServers != null) pro_codex.mcpServers;
        };
      };

      home.sessionVariables = {
        CODEX_HOME = "${config.xdg.configHome}/codex";
      };
    };
}

