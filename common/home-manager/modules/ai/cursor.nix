{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_ai = config.propheci.programs.ai;
    pro_cursor = pro_ai.cursor;
  in
    lib.mkIf (pro_ai.enable && pro_cursor.enable) {
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
      ) pro_ai.skills;
    };
}
