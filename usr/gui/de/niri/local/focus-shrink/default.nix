{ ... }: {
  patches = [
    # https://github.com/niri-wm/niri/discussions/1380
    ./main.patch
  ];
}
