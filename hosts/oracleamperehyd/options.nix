{
  config,
  inputs,
  pkgs,
  ...
}: {
  propheci = rec {
    system = {
      hostname = "oracleamperehyd";
      time_zone = "Asia/Kolkata";
      swap_devices = [];
    };
    user = {
      username = "akshettrj";
      homedir = "/home/akshettrj";
    };
    security = {
      sudo_without_password = true;
      polkit.enable = true;
    };

    hardware = {
      bluetooth.enable = false;
      nvidia.enable = false;
      pulseaudio.enable = false;
      graphics.enable = false;
    };

    # Various Services
    services = {
      virtualisation.enable = false;
      printing.enable = false;
      firewall = {
        enable = true;
        tcp_ports = [
          22
          80
          443
        ];
        udp_ports = [];
      };
      pipewire.enable = false;
      openssh = {
        server = {
          enable = true;
          ports = [22];
          password_authentication = false;
          root_login = "no";
          x11_forwarding = false;
        };
      };
      tailscale.enable = true;
      xdg_portal.enable = false;
      telegram_bot_api = {
        enable = true;
        port = 8082;
        data_dir = config.propheci.user.homedir + "/.local/share/telegram-bot-api";
      };
      nginx.enable = true;
      self_hosted = {
        firefly_iii = {
          enable = true;
          hostname = "ff.propheci.xyz";
          nginx.enable_ssl = true;
        };
        dokuwiki = {
          enable = true;
          disable_registration = true;
          hostname = "wiki.propheci.xyz";
          nginx.enable_ssl = true;
        };
        vikunja = {
          enable = true;
          settings = {
            service = {
              enableregistration = false;
              enableemailreminders = false;
              customlogourl = "https://avatars.githubusercontent.com/u/176999088?v=4";
            };
            mailer = {
              enabled = true;
              forcessl = true;
            };
          };
        };
        watgbridge = {
          enable = true;
          settings = [
            {
              enabled = true;
              instance_name = "jio";
              config_file = null;
              user = user.username;
              group = "users";
              max_runtime = "1d";
              working_directory = user.homedir + "/work/watgbridge/jio";
              after = ["tgbotapi.service"];
              requires = ["tgbotapi.service"];
            }
            {
              enabled = true;
              instance_name = "vi";
              config_file = null;
              user = user.username;
              group = "users";
              max_runtime = "1d";
              working_directory = user.homedir + "/work/watgbridge/vi";
              after = ["tgbotapi.service"];
              requires = ["tgbotapi.service"];
            }
          ];
        };
      };
    };

    # Nix/NixOS specific
    nix = {
      garbage_collection.enable = false;
      nix_community_cache = true;
      hyprland_cache = false;
      helix_cache = true;
      wezterm_cache = false;
    };

    # Appearance
    theming.enable = false;

    dev = {
      git = {
        enable = true;
        user = {
          name = "Akshett Rai Jindal";
        };
        delta.enable = true;
        default_branch = "main";
      };
      direnv.enable = true;
      cachix.enable = false;
    };

    programs = {
      media = {
        enable = false;
      };
      editors = {
        main = "neovim";
        backup = "helix";
        neovim = {
          enable = true;
          nightly = true;
        };
        helix = {
          enable = true;
          nightly = false;
        };
        zeditor.enable = false;
      };
      terminals.enable = false;
      browsers.enable = false;
      file_explorers = {
        main = "lf";
        backup = "yazi";
        lf.enable = true;
        yazi.enable = true;
      };
      extra_utilities = {
        taggie.enable = true;
      };
      launchers.enable = false;
      screenshot_tools.enable = false;
      notification_daemons.enable = false;
      clipboard_managers.enable = false;
      bars.enable = false;
      screenlocks.enable = false;
    };

    shells = {
      main = "zsh";
      aliases = import ../../common/home-manager/modules/shells/aliases.nix;
      bash.enable = true;
      fish.enable = false;
      nushell.enable = false;
      zsh.enable = true;

      eza.enable = true;
      starship.enable = true;
      zoxide.enable = true;
    };

    desktop_environments.enable = false;
  };
}
