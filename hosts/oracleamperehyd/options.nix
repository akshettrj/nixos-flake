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
      iphone.enable = false;
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
      openvpn = {
        enable = true;
        allow_duplicate_cns = true;
        protocol = "udp";
        port = 1194;
        server_name = "server";
        dns = "cloudflare";
        enable_unbound = false;
        clients = ["akshett" "atlas"];
        ca_dir = "/var/lib/openvpn";
        network = "10.8.0.0/24";
        cipher = "AES-256-GCM";
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
          hostname = "ff.nfak.xyz";
          nginx.enable_ssl = true;
        };
        dokuwiki = {
          enable = true;
          disable_registration = true;
          hostname = "wiki.nfak.xyz";
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
        glance = {
          enable = true;
          port = 4534;
          hostname = "glance.nfak.xyz";
          pages = [
            {
              name = "HOME";
              columns = [
                {
                  size = "small";
                  widgets = [
                    {
                      type = "monitor";
                      cache = "1h";
                      title = "Self Hosted";
                      sites = [
                        {
                          title = "Navidrome";
                          url = "https://navi.nfak.xyz";
                          icon = "di:navidrome";
                        }
                        {
                          title = "Vikunja";
                          url = "https://vikunja.nfak.xyz";
                          icon = "di:vikunja";
                        }
                        {
                          title = "Firefly III";
                          url = "https://ff.nfak.xyz";
                          icon = "di:firefly-iii";
                        }
                        {
                          title = "FreshRSS";
                          url = "https://rss.nfak.xyz";
                          icon = "di:freshrss";
                        }
                        {
                          title = "Wallabag";
                          url = "https://read.cyks.in";
                          icon = "di:wallabag";
                        }
                        {
                          title = "AdGuard";
                          url = "https://dns.nfak.xyz";
                          icon = "di:adguard-home";
                        }
                      ];
                    }
                    {
                      type = "server-stats";
                      servers = [
                        {
                          type = "local";
                          name = "Oracle Ampere Hyd";
                        }
                      ];
                    }
                    {
                      type = "releases";
                      cache = "1d";
                      repositories = [
                        "glanceapp/glance"
                      ];
                    }
                  ];
                }
                {
                  size = "full";
                  widgets = [
                    {
                      type = "split-column";
                      widgets = [
                        {
                          type = "weather";
                          units = "metric";
                          hour-format = "12h";
                          location = "Gurugram";
                        }
                        {
                          type = "weather";
                          units = "metric";
                          hour-format = "12h";
                          location = "Panchkula";
                        }
                      ];
                    }
                  ];
                }
              ];
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
      ai = {
        enable = false;
      };
      media = {
        enable = false;
      };
      gaming = {
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
        emacs.enable = false;
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
        taggie.enable = false;
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
