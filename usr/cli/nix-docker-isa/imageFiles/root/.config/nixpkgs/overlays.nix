[(self: super:
{
  bison = super.bison.overrideAttrs (old: {
    doInstallCheck = false;
  });
  coreutils = super.coreutils.overrideAttrs (old: {
    doCheck = false;
  });
  diffutils = super.diffutils.overrideAttrs (old: {
    doCheck = false;
  });
  findutils = super.findutils.overrideAttrs (old: {
    doCheck = false;
  });
  gnugrep = super.gnugrep.overrideAttrs (old: {
    doCheck = false;
  });
  hello = super.hello.overrideAttrs (old: {
    doCheck = false;
  });
})]
