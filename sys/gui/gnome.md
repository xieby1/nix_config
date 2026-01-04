# Why moving away from GNOME?

* Incompatibility. Every time update, there must be broken addons.
* Conservative. It does not support layer_shell protocol, which is needed by rofi
  * https://gitlab.gnome.org/GNOME/mutter/-/issues/973
  * There maybe other protocol not supported.
* JS based & Memory Leakage
  * The plugin system seems memory leakage consuming large chunk of memory.
    I have to `alt-f2 r` to reclaim a little bit memory.
