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
            biryani_cursor = biryani_ai.cursor;
        in
        lib.mkIf (biryani_ai.enable && biryani_cursor.enable) {
            home.packages = [ pkgs.code-cursor ];

            home.file = lib.mapAttrs' (
                n: v:
                if lib.isPath v && lib.pathIsDirectory v then
                    lib.nameValuePair "./.cursor/skills/${n}" {
                        source = v;
                        recursive = true;
                    }
                else
                    lib.nameValuePair "./.cursor/skills/${n}/SKILL.md" (
                        if lib.isPath v then { source = v; } else { text = v; }
                    )
            ) biryani_ai.skills;
        };
}
