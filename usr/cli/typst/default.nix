# The current nixpkgs typst ecosystem faces two significant problems.
#
# Problem 1: All packages are `@preview` and do not support `@local` packages
#
# This issue stems from design limitations in pkgs.buildTypstPackage and pkgs.typst.withPackages.
# A pull request addressing this has been submitted (https://github.com/NixOS/nixpkgs/pull/471798),
# but it has remained inactive for over a month.
#
# Problem 2: Transitive dependencies are not resolved
#
# This problem is caused by a design flaw in pkgs.typst.withPackages.
# Currently, only direct dependencies are included, while indirect (transitive) dependencies are ignored.
#
# For example, if you want to use the academic-conf-pre package and write the following Nix expression:
# nix
#
# ```nix
# your-typst = pkgs.typst.withPackages (p: with p; [academic-conf-pre])
# ```
#
# You will find that your-typst (by inspecting TYPST_PACKAGE_CACHE_PATH in <your-typst>/bin/typst) only includes:
# * academic-conf-pre and its direct dependencies
# * cuti, touying, and unify
#
# However, sourcerer — a dependency of cuti and an indirect dependency of academic-conf-pre — is not added.
# As a result, your project may fail to compile unless you explicitly add sourcerer to typst.withPackages,
# which is inelegant and impractical.
{ pkgs, ... }: {
  home.packages = [ pkgs.typst ];
}
