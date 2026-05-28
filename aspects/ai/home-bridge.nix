{ lib, biryani, ... }:
{
    config.biryani.programs.ai = {
        enable = biryani.programs.ai.enable or false;
    }
    // lib.optionalAttrs (biryani.programs.ai.enable or false) {
        codex = biryani.programs.ai.codex;
        cursor = biryani.programs.ai.cursor;
        gemini = biryani.programs.ai.gemini;
        mcpServers = biryani.programs.ai.mcpServers;
        ollama = biryani.programs.ai.ollama;
        skills = biryani.programs.ai.skills;
        commands = biryani.programs.ai.commands;
    };
}
