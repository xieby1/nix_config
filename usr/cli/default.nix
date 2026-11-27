{
  enableExtendedCLI,
  enableServer,
}: # local args
{ lib, ... }: {
  imports = [
    (lib.modules.importApply ./basic { inherit enableExtendedCLI; })
  ] ++ lib.optional enableExtendedCLI ./extended
    ++ lib.optional enableServer ./server
  ;
}
