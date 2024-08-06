{
  isMinimalConfig = false;
} // (
  if (builtins.pathExists ./opt4imports-local.nix)
  then import ./opt4imports-local.nix
  else {}
)
