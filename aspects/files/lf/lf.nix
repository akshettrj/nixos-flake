{
    config,
    pkgs,
    lib,
    ...
}:
{
    options.biryani = {
        programs.file_explorers = {
            main = lib.mkOption {
                type = lib.types.str;
                description = "Primary file explorer name.";
            };

            backup = lib.mkOption {
                type = lib.types.str;
                description = "Fallback file explorer name.";
            };

            lf.enable = lib.mkOption {
                type = lib.types.bool;
                description = "Enable lf through Home Manager.";
            };
        };

    };

    config =
        let
            biryani_shells = config.biryani.shells;
            biryani_theming = config.biryani.theming;

            shells_meta = import ../../core/metadata/programs/shells.nix { inherit pkgs; };
        in
        lib.mkIf config.biryani.programs.file_explorers.lf.enable {
            programs.lf = {
                enable = true;
                package = if biryani_theming.enable then (import ./wrapper.nix { inherit pkgs; }) else pkgs.lf;
                settings = {
                    shell = shells_meta."${biryani_shells.main}".bin;
                    shellopts = "-euy";
                    hidden = true;
                    ifs = "\\n";
                    number = true;
                    relativenumber = true;
                    icons = true;
                    preview = true;
                    drawbox = true;
                    cleaner = "${import ./cleaner.nix { inherit config pkgs; }}";
                };
                keybindings = {
                    "<enter>" = "shell";
                    x = ''''$"$f"'';
                    X = ''!"$f"'';
                    J = ":updir; set dironly true; down; set dironly false; open";
                    K = ":updir; set dironly true; up; set dironly false; open";
                    DD = "delete";

                    gM = "cd ${config.home.homeDirectory}/media";
                    gm = ''cd "${config.xdg.userDirs.music}"'';
                    gv = ''cd "${config.xdg.userDirs.videos}"'';
                };
                commands = {
                    # Basics
                    mkdir = ''%mkdir "$@"'';
                    touch = ''%touch "$@"'';
                }
                // lib.optionalAttrs biryani_shells.zoxide.enable {
                    # Zoxide
                    z = ''
                        %{{
                            result="$(${pkgs.zoxide}/bin/zoxide query --exclude $PWD $@)"
                            lf -remote "send $id cd $result"
                        }}
                    '';
                    zi = ''
                        ''${{
                            result="$(zoxide query -i)"
                            lf -remote "send $id cd $result"
                        }}
                    '';
                };
                previewer = {
                    keybinding = "i";
                    source = import ./previewer.nix { inherit config pkgs; };
                };
                extraConfig = ''
                    %[ $LF_LEVEL -eq 1 ] || echo "Warning: You're in a nested lf instance! [LEVEL $LF_LEVEL]"
                '';
            };

            home.sessionVariables = {
                LF_ICONS =
                    {
                        "*.wiki" = ":";
                        "*.vimrc" = ":";
                        "*.viminfo" = ":";
                        "*.gitignore" = ":";
                        "*.c" = ":";
                        "*.cc" = ":";
                        "*.clj" = ":";
                        "*.coffee" = ":";
                        "*.cpp" = ":";
                        "*.d" = ":";
                        "*.dart" = ":";
                        "*.erl" = ":";
                        "*.exs" = ":";
                        "*.fs" = ":";
                        "*.go" = ":";
                        "*.h" = ":";
                        "*.hh" = ":";
                        "*.hpp" = ":";
                        "*.hs" = ":";
                        "*.jl" = ":";
                        "*.js" = ":";
                        "*.jsx" = ": ";
                        "*.json" = ":";
                        "*.lua" = ":";
                        "*.php" = ":";
                        "*.pl" = ":";
                        "*.pro" = ":";
                        "*.py" = ":";
                        "*.rb" = ":";
                        "*.rs" = ":";
                        "*.scala" = ":";
                        "*.ts" = ":";
                        "*.vim" = ":";
                        "*.cmd" = ":";
                        "*.ps1" = ":";
                        "*.sh" = ":";
                        "*.bash" = ":";
                        "*.zsh" = ":";
                        "*.fish" = ":";
                        "*.tar" = ":";
                        "*.tgz" = ":";
                        "*.arc" = ":";
                        "*.arj" = ":";
                        "*.taz" = ":";
                        "*.lha" = ":";
                        "*.lz4" = ":";
                        "*.lzh" = ":";
                        "*.lzma" = ":";
                        "*.tlz" = ":";
                        "*.txz" = ":";
                        "*.tzo" = ":";
                        "*.t7z" = ":";
                        "*.z" = ":";
                        "*.dz" = ":";
                        "*.gz" = ":";
                        "*.lrz" = ":";
                        "*.lz" = ":";
                        "*.lzo" = ":";
                        "*.xz" = ":";
                        "*.zst" = ":";
                        "*.tzst" = ":";
                        "*.bz2" = ":";
                        "*.bz" = ":";
                        "*.tbz" = ":";
                        "*.tbz2" = ":";
                        "*.tz" = ":";
                        "*.deb" = ":";
                        "*.rpm" = ":";
                        "*.war" = ":";
                        "*.ear" = ":";
                        "*.sar" = ":";
                        "*.alz" = ":";
                        "*.ace" = ":";
                        "*.zoo" = ":";
                        "*.cpio" = ":";
                        "*.rz" = ":";
                        "*.cab" = ":";
                        "*.wim" = ":";
                        "*.swm" = ":";
                        "*.dwm" = ":";
                        "*.esd" = ":";
                        "*.mjpg" = ":";
                        "*.mjpeg" = ":";
                        "*.bmp" = ":";
                        "*.pbm" = ":";
                        "*.pgm" = ":";
                        "*.ppm" = ":";
                        "*.tga" = ":";
                        "*.xbm" = ":";
                        "*.xpm" = ":";
                        "*.svgz" = ":";
                        "*.mng" = ":";
                        "*.pcx" = ":";
                        "*.m2v" = ":";
                        "*.ogm" = ":";
                        "*.m4v" = ":";
                        "*.mp4v" = ":";
                        "*.vob" = ":";
                        "*.qt" = ":";
                        "*.nuv" = ":";
                        "*.asf" = ":";
                        "*.rm" = ":";
                        "*.rmvb" = ":";
                        "*.flc" = ":";
                        "*.fli" = ":";
                        "*.gl" = ":";
                        "*.dl" = ":";
                        "*.xwd" = ":";
                        "*.yuv" = ":";
                        "*.cgm" = ":";
                        "*.emf" = ":";
                        "*.ogv" = ":";
                        "*.ogx" = ":";
                        "*.aac" = ":";
                        "*.au" = ":";
                        "*.mid" = ":";
                        "*.midi" = ":";
                        "*.mka" = ":";
                        "*.mpc" = ":";
                        "*.ra" = ":";
                        "*.oga" = ":";
                        "*.spx" = ":";
                        "*.xspf" = ":";
                        "*.nix" = ":";
                        "*.ovpn" = "󰖟:";
                        "di" = ":";
                        "fi" = "󰈔:";
                        "tw" = "🤝:";
                        "ow" = "📂:";
                        "ln" = "⛓:";
                        "or" = "❌:";
                        "ex" = "🎯:";
                        "*.txt" = "✍:";
                        "*.mom" = "✍:";
                        "*.me" = "✍:";
                        "*.ms" = "✍:";
                        "*.png" = "🖼:";
                        "*.webp" = "🖼:";
                        "*.ico" = "🖼:";
                        "*.jpg" = "📸:";
                        "*.jpe" = "📸:";
                        "*.jpeg" = "📸:";
                        "*.gif" = "🖼:";
                        "*.svg" = "🗺:";
                        "*.tif" = "🖼:";
                        "*.tiff" = "🖼:";
                        "*.xcf" = "🖌:";
                        "*.html" = "🌎:";
                        "*.xml" = "📰:";
                        "*.gpg" = "🔒:";
                        "*.css" = "🎨:";
                        "*.pdf" = "📚:";
                        "*.djvu" = "📚:";
                        "*.epub" = "📚:";
                        "*.csv" = "📓:";
                        "*.xlsx" = "📓:";
                        "*.tex" = "📜:";
                        "*.md" = "📘:";
                        "*.r" = "📊:";
                        "*.R" = "📊:";
                        "*.rmd" = "📊:";
                        "*.Rmd" = "📊:";
                        "*.m" = "📊:";
                        "*.mp3" = "🎵:";
                        "*.opus" = "🎵:";
                        "*.ogg" = "🎵:";
                        "*.m4a" = "🎵:";
                        "*.flac" = "🎼:";
                        "*.wav" = "🎼:";
                        "*.mkv" = "🎥:";
                        "*.mp4" = "🎥:";
                        "*.webm" = "🎥:";
                        "*.mpeg" = "🎥:";
                        "*.avi" = "🎥:";
                        "*.mov" = "🎥:";
                        "*.mpg" = "🎥:";
                        "*.wmv" = "🎥:";
                        "*.m4b" = "🎥:";
                        "*.flv" = "🎥:";
                        "*.zip" = "📦:";
                        "*.rar" = "📦:";
                        "*.7z" = "📦:";
                        "*.tar.gz" = "📦:";
                        "*.z64" = "🎮:";
                        "*.v64" = "🎮:";
                        "*.n64" = "🎮:";
                        "*.gba" = "🎮:";
                        "*.nes" = "🎮:";
                        "*.gdi" = "🎮:";
                        "*.1" = "ℹ:";
                        "*.nfo" = "ℹ:";
                        "*.info" = "ℹ:";
                        "*.log" = "📙:";
                        "*.iso" = "📀:";
                        "*.img" = "📀:";
                        "*.bib" = "🎓:";
                        "*.ged" = "👪:";
                        "*.part" = "💔:";
                        "*.torrent" = "🔽:";
                        "*.jar" = "♨:";
                        "*.java" = "♨:";
                        "*rc" = ":";
                        "*.conf" = ":";
                    }
                    |> (lib.mapAttrsToList (name: value: "${name}=${value}"))
                    |> lib.concatStrings;
            };
        };
}
