{ inputs, ... }:
{
    caveman = "${inputs.caveman_skill}/commands/caveman.toml";
    caveman-commit = "${inputs.caveman_skill}/commands/caveman-commit.toml";
    caveman-init = "${inputs.caveman_skill}/commands/caveman-init.toml";
    caveman-review = "${inputs.caveman_skill}/commands/caveman-review.toml";
}
