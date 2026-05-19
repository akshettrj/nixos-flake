{
    config,
    lib,
    pkgs,
    ...
}:
{
    options.biryani.services.telegram_bot_api = {
        enable = lib.mkOption {
            type = lib.types.bool;
            description = "Enable a local Telegram Bot API server instance.";
        };

        port = lib.mkOption {
            type = lib.types.port;
            description = "HTTP port for the Telegram Bot API server.";
        };

        data_dir = lib.mkOption {
            type = lib.types.oneOf [
                lib.types.str
                lib.types.path
            ];
            description = "Directory used by the Telegram Bot API server for persistent data and logs.";
        };
    };

    config =
        let
            biryani_services = config.biryani.services;
            biryani_user = config.biryani.user;

            tgbotapi_script = pkgs.writeShellScriptBin "tgbotapi" ''
                [[ -d "${biryani_services.telegram_bot_api.data_dir}" ]] || mkdir "${biryani_services.telegram_bot_api.data_dir}"
                [[ -d "${biryani_services.telegram_bot_api.data_dir}/temp" ]] || mkdir "${biryani_services.telegram_bot_api.data_dir}/temp"
                [[ -f "${biryani_services.telegram_bot_api.data_dir}/logs.txt" ]] || touch "${biryani_services.telegram_bot_api.data_dir}/logs.txt"

                ${pkgs.telegram-bot-api}/bin/telegram-bot-api \
                    --local \
                    --api-id 611335 \
                    --api-hash d524b414d21f4d37f08684c1df41ac9c \
                    --http-port ${toString (biryani_services.telegram_bot_api.port)} \
                    --dir ${biryani_services.telegram_bot_api.data_dir} \
                    --temp-dir ${biryani_services.telegram_bot_api.data_dir}/temp \
                    --log ${biryani_services.telegram_bot_api.data_dir}/logs.txt \
            '';
        in
        lib.mkIf biryani_services.telegram_bot_api.enable {
            systemd.services.tgbotapi = {
                description = "Running local instance of Telegram Bot API server";

                after = [ "network.target" ];
                requires = [ "network.target" ];

                serviceConfig = {
                    User = biryani_user.username;
                    Type = "exec";
                    Restart = "on-failure";
                    ExecStart = "${tgbotapi_script}/bin/tgbotapi";
                };
            };
        };
}
