{ enableExtendedCLI }: # local args
{ lib, ... }: {
  imports = [
    (lib.modules.importApply ./basic {})
  ] ++ lib.optional enableExtendedCLI ./extended;
}
