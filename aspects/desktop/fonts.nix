{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.theming =
        let
            fontType = lib.types.submodule {
                options = {
                    name = lib.mkOption {
                        type = lib.types.str;
                        description = "Font family name.";
                    };

                    size = lib.mkOption {
                        type = lib.types.ints.unsigned;
                        description = "Font size in points.";
                    };
                };
            };
        in
        {
            enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable system-level theming defaults.";
            };

            fonts = {
                nerdfonts = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    description = "Nerd Font package names to install from pkgs.nerd-fonts.";
                };

                main = {
                    name = lib.mkOption {
                        type = lib.types.str;
                        description = "Primary font family used for system fontconfig defaults.";
                    };

                    size = lib.mkOption {
                        type = lib.types.ints.unsigned;
                        description = "Primary font size in points.";
                    };
                };

                backups = lib.mkOption {
                    type = lib.types.listOf fontType;
                    description = "Fallback fonts used by fontconfig when the primary font lacks glyphs.";
                };
            };
        };

    config =
        let
            biryani_theming = config.biryani.theming;
        in
        lib.mkIf biryani_theming.enable {
            fonts.packages =
                with pkgs;
                [
                    noto-fonts
                    noto-fonts-cjk-sans
                    noto-fonts-cjk-serif
                    noto-fonts-color-emoji

                    unifont
                    liberation_ttf
                ]
                ++ (pkgs.lohit-fonts |> lib.attrValues |> (lib.filter (v: lib.typeOf v == "set")))
                ++ (
                    pkgs.nerd-fonts
                    |> (lib.filterAttrs (k: v: (lib.elem k biryani_theming.fonts.nerdfonts)))
                    |> lib.attrValues
                );

            fonts.fontconfig = {
                enable = true;
                defaultFonts = {
                    emoji = [ "Noto Color Emoji" ];
                    monospace = [ "${biryani_theming.fonts.main.name}" ];
                    sansSerif = [ "${biryani_theming.fonts.main.name}" ];
                    serif = [ "${biryani_theming.fonts.main.name}" ];
                };
                localConf =
                    # xml
                    ''
                        <fontconfig>
                        <match target="pattern">
                        <test qual="any" name="family"><string>monospace</string></test>
                        <edit name="family" mode="assign" binding="same"><string>${biryani_theming.fonts.main.name}</string></edit>
                        <edit name="family" mode="append" binding="weak"><string>${(builtins.elemAt biryani_theming.fonts.backups 0).name}</string></edit>
                        </match>

                        <match target="pattern">
                        <test qual="any" name="family"><string>ui-monospace</string></test>
                        <edit name="family" mode="assign" binding="same"><string>${biryani_theming.fonts.main.name}</string></edit>
                        <edit name="family" mode="append" binding="weak"><string>${(builtins.elemAt biryani_theming.fonts.backups 0).name}M</string></edit>
                        </match>

                        <match target="pattern">
                        <test qual="any" name="family"><string>serif</string></test>
                        <edit name="family" mode="assign" binding="same"><string>${biryani_theming.fonts.main.name}</string></edit>
                        <edit name="family" mode="append" binding="weak"><string>${(builtins.elemAt biryani_theming.fonts.backups 0).name}M</string></edit>
                        <edit name="family" mode="append" binding="weak"><string>Noto Serif</string></edit>
                        </match>

                        <match target="pattern">
                        <test qual="any" name="family"><string>sans-serif</string></test>
                        <edit name="family" mode="assign" binding="same"><string>${biryani_theming.fonts.main.name}</string></edit>
                        <edit name="family" mode="append" binding="weak"><string>${(builtins.elemAt biryani_theming.fonts.backups 0).name}M</string></edit>
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
