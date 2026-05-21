{ config, lib, ... }:
let
    biryani_shells = config.biryani.shells;
    configFlakePath = "$HOME/.config/nixos-flake";

    posixFunctions = # sh
        ''
            function nixos-remote() {
                local max_jobs_args=()
                local no_cache_args=()
                local remote_user="''${USER:-$(id -un)}"
                local remote_host=""
                while [ "$#" -gt 0 ]; do
                    case "$1" in
                        -j|--max-jobs)
                            if [ "$#" -lt 2 ]; then
                                echo "usage: nixos-remote [--no-cache] [-j jobs] [-u user] [-r remote_host] <boot|build|switch> <target_configuration> [nixos-rebuild args...]" >&2
                                return 2
                            fi
                            max_jobs_args=(--option max-jobs "$2")
                            shift 2
                            ;;
                        --no-cache)
                            no_cache_args=(--option narinfo-cache-negative-ttl 0)
                            shift
                            ;;
                        -u|--user)
                            if [ "$#" -lt 2 ]; then
                                echo "usage: nixos-remote [--no-cache] [-j jobs] [-u user] [-r remote_host] <boot|build|switch> <target_configuration> [nixos-rebuild args...]" >&2
                                return 2
                            fi
                            remote_user="$2"
                            shift 2
                            ;;
                        -r|--remote|--host|--remote-host)
                            if [ "$#" -lt 2 ]; then
                                echo "usage: nixos-remote [--no-cache] [-j jobs] [-u user] [-r remote_host] <boot|build|switch> <target_configuration> [nixos-rebuild args...]" >&2
                                return 2
                            fi
                            remote_host="$2"
                            shift 2
                            ;;
                        *)
                            break
                            ;;
                    esac
                done

                if [ "$#" -lt 2 ]; then
                    echo "usage: nixos-remote [--no-cache] [-j jobs] [-u user] [-r remote_host] <boot|build|switch> <target_configuration> [nixos-rebuild args...]" >&2
                    return 2
                fi

                local action="$1"
                local target_configuration="$2"
                shift 2

                if [ -z "$remote_host" ]; then
                    remote_host="$target_configuration"
                fi

                local target_host="$remote_user@$remote_host"

                nixos-rebuild "$action" \
                    "''${no_cache_args[@]}" \
                    "''${max_jobs_args[@]}" \
                    --target-host "$target_host" \
                    --sudo \
                    --flake "${configFlakePath}#$target_configuration" \
                    "$@" 2>&1 | nom
            }

            function hm-remote() {
                local max_jobs_args=()
                local no_cache_args=()
                local remote_user="''${USER:-$(id -un)}"
                local remote_host=""
                while [ "$#" -gt 0 ]; do
                    case "$1" in
                        -j|--max-jobs)
                            if [ "$#" -lt 2 ]; then
                                echo "usage: hm-remote [--no-cache] [-j jobs] [-u user] [-r remote_host] <configuration> [home_configuration]" >&2
                                return 2
                            fi
                            max_jobs_args=(--option max-jobs "$2")
                            shift 2
                            ;;
                        --no-cache)
                            no_cache_args=(--option narinfo-cache-negative-ttl 0)
                            shift
                            ;;
                        -u|--user)
                            if [ "$#" -lt 2 ]; then
                                echo "usage: hm-remote [--no-cache] [-j jobs] [-u user] [-r remote_host] <configuration> [home_configuration]" >&2
                                return 2
                            fi
                            remote_user="$2"
                            shift 2
                            ;;
                        -r|--remote|--host|--remote-host)
                            if [ "$#" -lt 2 ]; then
                                echo "usage: hm-remote [--no-cache] [-j jobs] [-u user] [-r remote_host] <configuration> [home_configuration]" >&2
                                return 2
                            fi
                            remote_host="$2"
                            shift 2
                            ;;
                        *)
                            break
                            ;;
                    esac
                done

                if [ "$#" -lt 1 ]; then
                    echo "usage: hm-remote [--no-cache] [-j jobs] [-u user] [-r remote_host] <configuration> [home_configuration]" >&2
                    echo "example: hm-remote --no-cache -j 8 raspi" >&2
                    return 2
                fi

                local target_configuration="$1"
                local home_configuration="''${2:-}"

                if [[ "$target_configuration" == *@* ]]; then
                    remote_user="''${target_configuration%@*}"
                    target_configuration="''${target_configuration#*@}"
                fi

                if [ -z "$remote_host" ]; then
                    remote_host="$target_configuration"
                fi
                if [ -z "$home_configuration" ]; then
                    home_configuration="$remote_user@$target_configuration"
                fi

                local target_host="$remote_user@$remote_host"

                nom build "''${no_cache_args[@]}" "''${max_jobs_args[@]}" "${configFlakePath}#homeConfigurations.$home_configuration.activationPackage" \
                    && (set -o pipefail; nix "''${no_cache_args[@]}" --log-format internal-json -v copy --to "ssh://$target_host" ./result 2>&1 | nom --json) \
                    && ssh "$target_host" "$(readlink -f result)/activate"
            }
        '';

    fishFunctions = # fish
        ''
            function nixos-remote
                set max_jobs_args
                set no_cache_args
                set remote_user (id -un)
                if set -q USER
                    set remote_user $USER
                end
                set remote_host
                while test (count $argv) -gt 0
                    switch $argv[1]
                        case -j --max-jobs
                            if test (count $argv) -lt 2
                                echo "usage: nixos-remote [--no-cache] [-j jobs] [-u user] [-r remote_host] <boot|build|switch> <target_configuration> [nixos-rebuild args...]" >&2
                                return 2
                            end
                            set max_jobs_args --option max-jobs $argv[2]
                            set --erase argv[1..2]
                        case --no-cache
                            set no_cache_args --option narinfo-cache-negative-ttl 0
                            set --erase argv[1]
                        case -u --user
                            if test (count $argv) -lt 2
                                echo "usage: nixos-remote [--no-cache] [-j jobs] [-u user] [-r remote_host] <boot|build|switch> <target_configuration> [nixos-rebuild args...]" >&2
                                return 2
                            end
                            set remote_user $argv[2]
                            set --erase argv[1..2]
                        case -r --remote --host --remote-host
                            if test (count $argv) -lt 2
                                echo "usage: nixos-remote [--no-cache] [-j jobs] [-u user] [-r remote_host] <boot|build|switch> <target_configuration> [nixos-rebuild args...]" >&2
                                return 2
                            end
                            set remote_host $argv[2]
                            set --erase argv[1..2]
                        case '*'
                            break
                    end
                end

                if test (count $argv) -lt 2
                    echo "usage: nixos-remote [--no-cache] [-j jobs] [-u user] [-r remote_host] <boot|build|switch> <target_configuration> [nixos-rebuild args...]" >&2
                    return 2
                end

                set action $argv[1]
                set target_configuration $argv[2]
                if test -z "$remote_host"
                    set remote_host $target_configuration
                end
                set target_host "$remote_user@$remote_host"

                nixos-rebuild $action \
                    $no_cache_args \
                    $max_jobs_args \
                    --target-host $target_host \
                    --sudo \
                    --flake "${configFlakePath}#$target_configuration" \
                    $argv[3..-1] 2>&1 | nom
            end

            function hm-remote
                set max_jobs_args
                set no_cache_args
                set remote_user (id -un)
                if set -q USER
                    set remote_user $USER
                end
                set remote_host
                while test (count $argv) -gt 0
                    switch $argv[1]
                        case -j --max-jobs
                            if test (count $argv) -lt 2
                                echo "usage: hm-remote [--no-cache] [-j jobs] [-u user] [-r remote_host] <configuration> [home_configuration]" >&2
                                return 2
                            end
                            set max_jobs_args --option max-jobs $argv[2]
                            set --erase argv[1..2]
                        case --no-cache
                            set no_cache_args --option narinfo-cache-negative-ttl 0
                            set --erase argv[1]
                        case -u --user
                            if test (count $argv) -lt 2
                                echo "usage: hm-remote [--no-cache] [-j jobs] [-u user] [-r remote_host] <configuration> [home_configuration]" >&2
                                return 2
                            end
                            set remote_user $argv[2]
                            set --erase argv[1..2]
                        case -r --remote --host --remote-host
                            if test (count $argv) -lt 2
                                echo "usage: hm-remote [--no-cache] [-j jobs] [-u user] [-r remote_host] <configuration> [home_configuration]" >&2
                                return 2
                            end
                            set remote_host $argv[2]
                            set --erase argv[1..2]
                        case '*'
                            break
                    end
                end

                if test (count $argv) -lt 1
                    echo "usage: hm-remote [--no-cache] [-j jobs] [-u user] [-r remote_host] <configuration> [home_configuration]" >&2
                    echo "example: hm-remote --no-cache -j 8 raspi" >&2
                    return 2
                end

                set target_configuration $argv[1]
                set home_configuration
                if test (count $argv) -ge 2
                    set home_configuration $argv[2]
                end
                if string match -q '*@*' $target_configuration
                    set remote_user (string replace -r '@.*$' "" $target_configuration)
                    set target_configuration (string replace -r '^.*@' "" $target_configuration)
                end
                if test -z "$remote_host"
                    set remote_host $target_configuration
                end
                if test -z "$home_configuration"
                    set home_configuration "$remote_user@$target_configuration"
                end
                set target_host "$remote_user@$remote_host"

                nom build $no_cache_args $max_jobs_args "${configFlakePath}#homeConfigurations.$home_configuration.activationPackage"; or return

                nix $no_cache_args --log-format internal-json -v copy --to "ssh://$target_host" ./result 2>&1 | nom --json
                set copy_status $pipestatus
                if test "$copy_status" != "0 0"
                    return 1
                end

                ssh $target_host (readlink -f result)/activate
            end
        '';
in
{
    config = lib.mkMerge [
        (lib.mkIf biryani_shells.bash.enable { programs.bash.initExtra = posixFunctions; })
        (lib.mkIf biryani_shells.zsh.enable { programs.zsh.initContent = lib.mkOrder 1200 posixFunctions; })
        (lib.mkIf biryani_shells.fish.enable { programs.fish.interactiveShellInit = fishFunctions; })
    ];
}
