{ lib, pkgs, ... }:
let
    jsonFormat = pkgs.formats.json { };
in
{
    options.biryani.programs.ai = {
        enable = lib.mkEnableOption "AI assistant tools.";
        mcpServers = lib.mkOption {
            type = jsonFormat.type;
            description = "Shared MCP server configuration for AI tools.";
        };
        skills = lib.mkOption {
            type = lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path);
            description = "Skill definitions exposed to AI tools.";
        };
        cursor.enable = lib.mkEnableOption "Cursor editor AI integration.";
        gemini = {
            enable = lib.mkEnableOption "Gemini CLI.";
            mcpServers = lib.mkOption {
                type = jsonFormat.type;
                description = "Gemini-specific MCP server configuration.";
            };
        };
        codex = {
            enable = lib.mkEnableOption "Codex CLI.";
            mcpServers = lib.mkOption {
                type = jsonFormat.type;
                description = "Codex-specific MCP server configuration.";
            };
        };
        claude-code = {
            enable = lib.mkEnableOption "Claude Code CLI.";
            mcpServers = lib.mkOption {
                type = jsonFormat.type;
                description = "Claude-Code-specific MCP server configuration.";
            };
        };
        # Pi exposes a single `pi` binary that is both the coding agent and its
        # TUI. It has no native `mcpServers` settings key (MCP is wired through
        # adapter packages), so unlike the other agents it carries no such field.
        pi.enable = lib.mkEnableOption "Pi coding agent (TUI).";
        ollama = {
            enable = lib.mkEnableOption "Ollama service.";
            acceleration = lib.mkOption {
                type = lib.types.nullOr (
                    lib.types.enum [
                        false
                        "rocm"
                        "cuda"
                    ]
                );
                description = "Ollama hardware acceleration mode.";
            };
        };
    };
}
