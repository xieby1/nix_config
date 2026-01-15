{ lib, stdenvNoCC }: lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;
  excludeDrvArgNames = ["typstDeps"];
  extendDrvArgs = finalAttrs: let
    typst_toml = lib.importTOML (finalAttrs.src + /typst.toml);
  in { typstDeps ? [], ... }: {
    pname = typst_toml.package.name;
    version = typst_toml.package.version;
    name = "typst-local-package-${finalAttrs.pname}-${finalAttrs.version}";
    dontBuild = true;
    installPhase = let
      outDir = "$out/lib/typst-local-packages/${finalAttrs.pname}/${finalAttrs.version}";
    in ''
      runHook preInstall
      mkdir -p ${outDir}
      cp -r . ${outDir}
      runHook postInstall
    '';
    propagatedBuildInputs = typstDeps;
    passthru = { inherit typstDeps; };
  };
}
