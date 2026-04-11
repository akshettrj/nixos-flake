{
  config,
  lib,
  ...
}: {
  config = let
    pro_ai = config.propheci.programs.ai;
    pro_gemini = pro_ai.gemini;
  in
    lib.mkIf (pro_ai.enable && pro_gemini.enable) {
      programs.gemini-cli = {
        enable = true;
        enableMcpIntegration = true;
        skills = pro_ai.skills;
        settings = {
          theme = "ANSI";
          selectedAuthType = "oauth-personal";
          general = {
            sessionRetention = {
              enabled = true;
              maxAge = "30d";
              warningAcknowledged = true;
            };
            vimMode = true;
            enableAutoUpdate = false;
            enableNotifications = true;
            plan.modelRouting = false;
          };
          security = {
            auth = {
              selectedType = "oauth-personal";
            };
          };
          ui = {
            theme = "GitHub";
            inlineThinkingMode = "full";
          };
          mcpServers = lib.mkIf (pro_gemini.mcpServers != null) pro_gemini.mcpServers;
          mcp.allowed =
            (
              if (pro_ai.mcpServers != null)
              then (lib.attrNames pro_ai.mcpServers)
              else []
            )
            ++ (
              if (pro_gemini.mcpServers != null)
              then (lib.attrNames pro_gemini.mcpServers)
              else []
            );
        };
      };
    };
}
