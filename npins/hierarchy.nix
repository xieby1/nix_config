let
  # Though (import ./.) is callable and can serve as `npinsFun`,
  # I want `npinsFun` to be clean, without other attributes mixed in.
  npinsFun = (import ./.).__functor null;
in (import ./.) // {
  # Artificial Intelligence
  ai = import ./ai npinsFun;
  # Desktop Environment
  de = import ./de npinsFun;
}
