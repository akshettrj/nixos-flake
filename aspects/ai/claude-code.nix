{ config, lib, ... }:
{
    config =
        let
            biryani_ai = config.biryani.programs.ai;
            biryani_claude_code = biryani_ai.claude-code;
        in
        lib.mkIf (biryani_ai.enable && biryani_claude_code.enable) {
            programs.claude-code = {
                enable = true;
                enableMcpIntegration = true;
                # configDir = "${config.xdg.configHome}/claude";
                skills = biryani_ai.skills;
                context = ''
                    - On every iteration, send the user a concise list of next steps, including progress updates and the final response.
                    - Other than MPVs, ensure that the code generated is scalable, maintainable and easily extensible.
                '';
                mcpServers = lib.mkIf (biryani_claude_code.mcpServers != null) biryani_claude_code.mcpServers;
                settings = {
                    theme = "auto";
                    editorMode = "vim";
                };
            };

            # home.sessionVariables = {
            #     CLAUDE_CONFIG_DIR = "${config.xdg.configHome}/claude";
            # };
        };
}
