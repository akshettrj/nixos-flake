{
  config,
  lib,
  pkgs,
  ...
}: {
  config = let
    pro_watgbridge = config.propheci.services.self_hosted.watgbridge;
    setting_to_service_mapper = (
      setting: {
        name = "watgbridge-${setting.instance_name}";
        value = let
          config_file_arg =
            if setting.config_file != null
            then (" " + setting.config_file)
            else "";
        in {
          description = "WaTgBridge for instance ${setting.instance_name}";
          after = ["network.target"] ++ setting.after;
          requires = ["network.target"] ++ setting.requires;
          wantedBy = [] ++ lib.optionals setting.enabled ["multi-user.target"];

          path = with pkgs; [
            ffmpeg
            imagemagick
            libwebp
          ];

          serviceConfig =
            {
              User = setting.user;
              Group = setting.group;
              Type = "exec";
              Restart = "on-failure";
              ExecStart = "${setting.package}/bin/watgbridge" + config_file_arg;
            }
            // (lib.optionalAttrs (setting.max_runtime != null) {
              RuntimeMaxSec = setting.max_runtime;
            })
            // (lib.optionalAttrs (setting.working_directory != null) {
              WorkingDirectory = setting.working_directory;
            });
        };
      }
    );
  in
    lib.mkIf pro_watgbridge.enable {
      systemd.services = (
        pro_watgbridge.settings |> builtins.map setting_to_service_mapper |> builtins.listToAttrs
      );
    };
}
