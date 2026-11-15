# Models.dev includes newer deployments (Kimi K3.1 Pro and DeepSeek V4.1) missing from Catwalk.
{ pkgs, src }: builtins.fromJSON (builtins.readFile (import ./catalog.nix { inherit pkgs src; }))
