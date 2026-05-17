{ inputs, ... }:
inputs.mcp_python.skills
// {
  nixos-configuration = ./skills/nixos-configuration;
  cavecrew = "${inputs.caveman_skill}/skills/cavecrew";
  caveman-commit = "${inputs.caveman_skill}/skills/caveman-commit";
  caveman-compress = "${inputs.caveman_skill}/skills/caveman-compress";
  caveman-help = "${inputs.caveman_skill}/skills/caveman-help";
  caveman-review = "${inputs.caveman_skill}/skills/caveman-review";
  caveman-stats = "${inputs.caveman_skill}/skills/caveman-stats";
  caveman = "${inputs.caveman_skill}/skills/caveman";
}
