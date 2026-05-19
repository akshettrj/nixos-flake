{ lib, ... }:
{
    options.biryani.services.self_hosted.mediawiki.enable = lib.mkEnableOption "MediaWiki service.";
}
