{
  config,
  lib,
  ...
}: {
  config = let
    pro_ai = config.propheci.programs.ai;
    pro_ollama = pro_ai.ollama;
  in
    lib.mkIf (pro_ai.enable && pro_ollama.enable) {
      services.ollama = {
        enable = true;
        acceleration = pro_ollama.acceleration;
      };
    };
}
