let
  # TODO: completely clean standalone npins hierarchy, use lazy-tree layout.
  # Though (import ./.) is callable and can serve as `npinsFun`,
  # I want `npinsFun` to be clean, without other attributes mixed in.
  npinsFun = (import ./.).__functor null;
in (import ./.) // {
  # Desktop Environment
  de = import ./de npinsFun;
  my = import ./my npinsFun;
}
