let
    flake = builtins.getFlake (toString ../.);
    lib = flake.inputs.nixpkgs.lib;

    optionToRecord = graph: path: option: {
        inherit graph path;
        description = option.description or "";
        type = option.type.description or "";
        default = if option ? defaultText then toString option.defaultText else "";
        declarations = map toString (option.declarations or [ ]);
    };

    collectOptions =
        graph: prefix: attrs:
        lib.flatten (
            lib.mapAttrsToList (
                name: value:
                let
                    pathParts = prefix ++ [ name ];
                    path = lib.concatStringsSep "." pathParts;
                in
                if lib.isOption value then
                    [ (optionToRecord graph path value) ]
                else if builtins.isAttrs value then
                    collectOptions graph pathParts value
                else
                    [ ]
            ) attrs
        );

    nixosOptions = flake.nixosConfigurations.alienrj.options.biryani;
    homeOptions = flake.homeConfigurations."akshettrj@alienrj".options.biryani;
in
{
    generatedFrom = {
        nixos = "nixosConfigurations.alienrj";
        homeManager = "homeConfigurations.akshettrj@alienrj";
    };

    options = {
        nixos = collectOptions "nixos" [ "biryani" ] nixosOptions;
        homeManager = collectOptions "home-manager" [ "biryani" ] homeOptions;
    };
}
