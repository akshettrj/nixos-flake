{ config, lib, ... }: {
    config =
        let
            biryani_ai = config.biryani.programs.ai;
            biryani_ollama = biryani_ai.ollama;
        in
        lib.mkIf (biryani_ai.enable && biryani_ollama.enable) {
            services.ollama = {
                enable = true;
                acceleration = biryani_ollama.acceleration;
            };
        };
}
