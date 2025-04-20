{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_theming = config.propheci.theming;
  in
    lib.mkIf pro_theming.enable {
      fonts.packages = with pkgs;
        [
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-color-emoji

          unifont
          liberation_ttf
        ]
        ++ (
          pkgs.lohit-fonts
          |> lib.attrValues
          |> (lib.filter (v: lib.typeOf v == "set"))
        )
        ++ (
          pkgs.nerd-fonts
          |> (lib.filterAttrs (k: v: (lib.elem k pro_theming.fonts.nerdfonts)))
          |> lib.attrValues
        );

      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          emoji = ["Noto Color Emoji"];
          monospace = ["${pro_theming.fonts.main.name}"];
          sansSerif = ["${pro_theming.fonts.main.name}"];
          serif = ["${pro_theming.fonts.main.name}"];
        };
        localConf =
          # xml
          ''
            <fontconfig>
            <match target="pattern">
            <test qual="any" name="family"><string>monospace</string></test>
            <edit name="family" mode="assign" binding="same"><string>${pro_theming.fonts.main.name}</string></edit>
            <edit name="family" mode="append" binding="weak"><string>${
              (builtins.elemAt pro_theming.fonts.backups 0).name
            }</string></edit>
            </match>

            <match target="pattern">
            <test qual="any" name="family"><string>ui-monospace</string></test>
            <edit name="family" mode="assign" binding="same"><string>${pro_theming.fonts.main.name}</string></edit>
            <edit name="family" mode="append" binding="weak"><string>${
              (builtins.elemAt pro_theming.fonts.backups 0).name
            }M</string></edit>
            </match>

            <match target="pattern">
            <test qual="any" name="family"><string>serif</string></test>
            <edit name="family" mode="assign" binding="same"><string>${pro_theming.fonts.main.name}</string></edit>
            <edit name="family" mode="append" binding="weak"><string>${
              (builtins.elemAt pro_theming.fonts.backups 0).name
            }M</string></edit>
            <edit name="family" mode="append" binding="weak"><string>Noto Serif</string></edit>
            </match>

            <match target="pattern">
            <test qual="any" name="family"><string>sans-serif</string></test>
            <edit name="family" mode="assign" binding="same"><string>${pro_theming.fonts.main.name}</string></edit>
            <edit name="family" mode="append" binding="weak"><string>${
              (builtins.elemAt pro_theming.fonts.backups 0).name
            }M</string></edit>
            <edit name="family" mode="append" binding="weak"><string>Noto Serif</string></edit>
            </match>

            <match target="pattern">
            <test qual="any" name="family"><string>emoji</string></test>
            <edit name="family" mode="assign" binding="same"><string>Noto Color Emoji</string></edit>
            </match>
            </fontconfig>
          '';
      };
    };
}
