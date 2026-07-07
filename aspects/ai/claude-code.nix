{
    config,
    lib,
    pkgs,
    ...
}:
{
    config =
        let
            biryani_ai = config.biryani.programs.ai;
            biryani_claude_code = biryani_ai.claude-code;
        in
        lib.mkIf (biryani_ai.enable && biryani_claude_code.enable) {
            programs.claude-code = {
                enable = true;
                package = pkgs.llm-agents.claude-code;
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
                    model = "claude-opus-4-8";
                    effortLevel = "high";
                    editorMode = "vim";
                    includeCoAuthoredBy = false;
                    enabledPlugins = {
                        "lua-lsp@claude-plugins-official" = true;
                        "gopls-lsp@claude-plugins-official" = true;
                        "rust-analyzer-lsp@claude-plugins-official" = true;
                        "frontend-design@claude-plugins-official" = true;
                    };
                    statusLine = {
                        type = "command";
                        command = ''input=$(cat); model=$(echo "$input" | jq -r '.model.display_name // "Claude"'); cwd=$(echo "$input" | jq -r '.cwd // ""'); dir=$(basename "$cwd"); used=$(echo "$input" | jq -r '.context_window.used_percentage // empty'); ctx_str=""; [ -n "$used" ] && ctx_str=" ctx:$(printf '%.0f' "$used")%"; five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty'); rate_str=""; [ -n "$five" ] && rate_str=" 5h:$(printf '%.0f' "$five")%"; printf "%s  %s%s%s" "$model" "$dir" "$ctx_str" "$rate_str"'';
                    };
                };
            };

            # home.sessionVariables = {
            #     CLAUDE_CONFIG_DIR = "${config.xdg.configHome}/claude";
            # };
        };
}
