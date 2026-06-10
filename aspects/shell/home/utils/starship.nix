{ config, lib, ... }: {
    config =
        let
            biryani_shells = config.biryani.shells;
        in
        lib.mkIf biryani_shells.starship.enable {
            programs.starship = {
                enable = true;
                enableBashIntegration = lib.mkIf biryani_shells.bash.enable true;
                enableFishIntegration = lib.mkIf biryani_shells.fish.enable true;
                enableNushellIntegration = lib.mkIf biryani_shells.nushell.enable true;
                enableZshIntegration = lib.mkIf biryani_shells.zsh.enable true;
                settings = {
                    add_newline = true;
                    command_timeout = 1000;

                    format = "\${custom.ps1_osc133_prefix}$all\${custom.ps1_osc133_postfix}";

                    character = {
                        format = "\n $symbol";
                        success_symbol = "[󰁕](bold green)";
                        error_symbol = "[󰁕](bold red)";
                    };

                    aws.disabled = true;
                    azure.disabled = true;
                    battery.disabled = true;
                    buf.disabled = true;
                    c.disabled = true;
                    cmake.disabled = true;
                    cobol.disabled = true;
                    crystal.disabled = true;
                    daml.disabled = true;
                    dart.disabled = true;
                    deno.disabled = true;
                    docker_context.disabled = true;
                    dotnet.disabled = true;
                    elixir.disabled = true;
                    elm.disabled = true;
                    erlang.disabled = true;
                    gcloud.disabled = true;
                    haskell.disabled = true;
                    helm.disabled = true;
                    java.disabled = true;
                    julia.disabled = true;
                    kotlin.disabled = true;
                    kubernetes.disabled = true;
                    line_break.disabled = true;
                    localip.disabled = true;
                    lua.disabled = true;
                    memory_usage.disabled = true;
                    hg_branch.disabled = true;
                    nim.disabled = true;
                    nodejs.disabled = true;
                    ocaml.disabled = true;
                    openstack.disabled = true;
                    package.disabled = true;
                    perl.disabled = true;
                    php.disabled = true;
                    pulumi.disabled = true;
                    purescript.disabled = true;
                    rlang.disabled = true;
                    raku.disabled = true;
                    red.disabled = true;
                    ruby.disabled = true;
                    scala.disabled = true;
                    shell.disabled = true;
                    shlvl.disabled = true;
                    singularity.disabled = true;
                    spack.disabled = true;
                    sudo.disabled = true;
                    swift.disabled = true;
                    terraform.disabled = true;
                    vagrant.disabled = true;
                    vlang.disabled = true;
                    vcsh.disabled = true;
                    zig.disabled = true;

                    cmd_duration = {
                        disabled = false;
                        min_time = 1500;
                        show_milliseconds = true;
                        show_notifications = true;
                        min_time_to_notify = 45000;
                        notification_timeout = 3000;
                    };

                    conda = {
                        disabled = false;
                        truncation_length = 1;
                        symbol = "🅒 ";
                        style = "bold green";
                        ignore_base = false;
                    };

                    container = {
                        disabled = false;
                        symbol = "⬢";
                        style = "bold red dimmed";
                    };

                    directory = {
                        disabled = false;
                        truncation_length = 3;
                        truncate_to_repo = false;
                        read_only = "🔒";
                        truncation_symbol = "";
                    };

                    git_branch = {
                        disabled = false;
                        always_show_remote = false;
                        symbol = " ";
                        style = "bold purple";
                        only_attached = false;
                    };

                    git_commit = {
                        disabled = false;
                        commit_hash_length = 7;
                        only_detached = false;
                        tag_disabled = false;
                    };

                    git_state.disabled = false;
                    git_metrics.disabled = false;

                    git_status = {
                        disabled = false;
                        conflicted = "=";
                        ahead = "⇡";
                        behind = "⇣";
                        diverged = "⇕";
                        up_to_date = "";
                        untracked = "?";
                        stashed = "\\\$";
                        modified = "!";
                        staged = "+";
                        renamed = "»";
                        deleted = "✘ ";
                        style = "red bold";
                        ignore_submodules = false;
                    };

                    golang = {
                        disabled = false;
                        symbol = " ";
                    };

                    hostname = {
                        disabled = false;
                        ssh_only = true;
                        ssh_symbol = "";
                        trim_at = "";
                    };

                    nix_shell = {
                        disabled = false;
                        symbol = "❄️ ";
                    };

                    python = {
                        disabled = false;
                        format = "via [\${symbol}\${pyenv_prefix}(\${version} )(\\(\$virtualenv\\) )](\$style)";
                        version_format = "v\${raw}";
                        symbol = " ";
                        style = "yellow bold";
                        pyenv_version_name = false;
                        pyenv_prefix = "pyenv ";
                        python_binary = [
                            "python"
                            "python3"
                            "python2"
                        ];
                        detect_extensions = [ ];
                        detect_files = [
                            "requirements.txt"
                            ".python-version"
                            "pyproject.toml"
                            "Pipfile"
                            "tox.ini"
                            "setup.py"
                            "__init__.py"
                        ];
                        detect_folders = [ ];
                    };

                    rust = {
                        disabled = false;
                    };

                    time = {
                        disabled = false;
                        use_12hr = false;
                        style = "bold yellow";
                        utc_time_offset = "local";
                        time_range = "-";
                    };

                    username = {
                        disabled = false;
                        show_always = false;
                        format = "[\$user](\$style) in ";
                    };

                    custom = {
                        lf_instance = {
                            command = "echo $LF_LEVEL";
                            when = ''test "$LF_LEVEL" -gt 0'';
                            format = ''\(lf_level:[$output]($style)\) '';
                            shell = [
                                "bash"
                                "--noprofile"
                                "--norc"
                            ];
                        };

                        shell = {
                            command = "echo $STARSHIP_SHELL";
                            when = ''test "$STARSHIP_SHELL" != "zsh"'';
                            format = ''\([$output]($style)\) '';
                            shell = [
                                "bash"
                                "--noprofile"
                                "--norc"
                            ];
                        };

                        ps1_osc133_prefix = {
                            command = "printf \"\\033]133;A\\007\"";
                            when = "true";
                        };
                        ps1_osc133_postfix = {
                            command = "printf \"\\033]133;B\\007\"";
                            when = "true";
                        };
                    };
                };
            };
        };
}
