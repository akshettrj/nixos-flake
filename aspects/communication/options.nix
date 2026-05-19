{ lib, ... }:
{
    options.biryani.programs.social_media = {
        telegram.enable = lib.mkEnableOption "Telegram Desktop.";
        discord.enable = lib.mkEnableOption "Discord.";
        beeper.enable = lib.mkEnableOption "Beeper.";
        slack.enable = lib.mkEnableOption "Slack.";
        teams.enable = lib.mkEnableOption "Microsoft Teams.";
        zulip.enable = lib.mkEnableOption "Zulip.";
    };
}
