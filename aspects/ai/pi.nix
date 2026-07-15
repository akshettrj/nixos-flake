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
            biryani_pi = biryani_ai.pi;
        in
        lib.mkIf (biryani_ai.enable && biryani_pi.enable) {
            # `pi` is a terminal-based (TUI) coding agent. The upstream Home
            # Manager module defaults `package` to `pkgs.pi-coding-agent`, but
            # this flake ships the binary via the llm-agents overlay, so point
            # it there explicitly.
            programs.pi-coding-agent = {
                enable = true;
                package = pkgs.llm-agents.pi;
                context = ''
                    - On every iteration, send the user a concise list of next steps, including progress updates and the final response.
                    - Other than MPVs, ensure that the code generated is scalable, maintainable and easily extensible.
                '';
                settings = {
                    theme = "dark";
                    quietStartup = true;
                    defaultThinkingLevel = "high";
                };
            };
        };
}
