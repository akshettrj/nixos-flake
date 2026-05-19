{ config, lib, ... }:
{
    config =
        let
            biryani_ai = config.biryani.programs.ai;
            biryani_gemini = biryani_ai.gemini;
        in
        lib.mkIf (biryani_ai.enable && biryani_gemini.enable) {
            programs.gemini-cli = {
                enable = true;
                enableMcpIntegration = true;
                skills = biryani_ai.skills;
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
                    mcpServers = lib.mkIf (biryani_gemini.mcpServers != null) biryani_gemini.mcpServers;
                    mcp.allowed =
                        (if (biryani_ai.mcpServers != null) then (lib.attrNames biryani_ai.mcpServers) else [ ])
                        ++ (if (biryani_gemini.mcpServers != null) then (lib.attrNames biryani_gemini.mcpServers) else [ ]);
                };
            };
        };
}
