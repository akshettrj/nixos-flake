{
  config,
  pkgs,
}: let
  pro_theming = config.propheci.theming;

  ueberzugpp =
    if pro_theming.enable
    then "${pkgs.ueberzugpp}/bin/ueberzugpp"
    else "random_non_existing_binary";
in
  pkgs.writeShellScript "previewer.sh"
  /*
  sh
  */
  ''
    set -C -f
    IFS="$(printf '%b_' '\n')"; IFS="''${IFS%_}"

    image() {
      if [ -f "$1" ] && [ -n "$DISPLAY" ] && command -V ${ueberzugpp} >/dev/null 2>&1; then
        FILE_PATH="$1"
        X=$4
        Y=$5
        MW=$(($2 - 1))
        MH=$3
        ${ueberzugpp} cmd -s "$UB_SOCKET" -a add -i PREVIEW -x "$X" -y "$Y" --max-width "$MW" --max-height "$MH" -f "$FILE_PATH"
      else
        ${pkgs.mediainfo}/bin/mediainfo "$6"
      fi
    }


    case "$(file --dereference --brief --mime-type -- "$1")" in
      image/*) image "$1" "$2" "$3" "$4" "$5" "$1" ;;
      text/html) ${pkgs.lynx}/bin/lynx -width="$4" -display_charset=utf-8 -dump "$1" ;;
      text/troff) man ./ "$1" | col -b ;;
      text/* | */xml | application/json) ${pkgs.bat}/bin/bat --pager never --terminal-width "$(($4-2))" -f "$1" ;;
      application/zip | application/gzip) ${pkgs.atool}/bin/atool --list -- "$1" ;;
      audio/* | application/octet-stream) ${pkgs.mediainfo}/bin/mediainfo "$1" || exit 1 ;;
      video/* )
          CACHE="''${XDG_CACHE_HOME:-$HOME/.cache}/lf/thumb.$(${pkgs.coreutils}/bin/stat --printf '%n\0%i\0%F\0%s\0%W\0%Y' -- "$(${pkgs.coreutils}/bin/readlink -f "$1")" | ${pkgs.coreutils}/bin/sha256sum | ${pkgs.coreutils}/bin/cut -d' ' -f1)"
          [ ! -f "$CACHE" ] && ffmpegthumbnailer -i "$1" -o "$CACHE" -s 0
          image "$CACHE" "$2" "$3" "$4" "$5" "$1"
          ;;
      */pdf)
          CACHE="''${XDG_CACHE_HOME:-$HOME/.cache}/lf/thumb.$(${pkgs.coreutils}/bin/stat --printf '%n\0%i\0%F\0%s\0%W\0%Y' -- "$(${pkgs.coreutils}/bin/readlink -f "$1")" | ${pkgs.coreutils}/bin/sha256sum | ${pkgs.coreutils}/bin/cut -d' ' -f1)"
          [ ! -f "$CACHE.jpg" ] && ${pkgs.poppler-utils}/bin/pdftoppm -jpeg -f 1 -singlefile "$1" "$CACHE"
          image "$CACHE.jpg" "$2" "$3" "$4" "$5" "$1"
          ;;
      *opendocument*) ${pkgs.odt2txt}/bin/odt2txt "$1" ;;
      application/pgp-encrypted) ${pkgs.gnupg}/bin/gpg -d -- "$1" ;;
    esac
    exit 1
  ''
