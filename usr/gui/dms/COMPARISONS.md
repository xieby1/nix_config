## Gnome

* **Incompatibility issues**: Updates frequently break extensions and addons.
* **Conservative approach**: GNOME doesn't support the layer_shell protocol, which is required by applications like rofi.
  * https://gitlab.gnome.org/GNOME/mutter/-/issues/973
  * Other protocols may also be unsupported.
* **JavaScript-based extensions with memory leaks**:
  The extension system appears to have memory leaks that consume significant memory. I often need to use `alt-f2 r` to reclaim some memory.
* **Wayland limitations exacerbated by GNOME**: 
  * After transitioning from X11 to Wayland, several important desktop features stopped working,
  such as using xdotool to move specific windows to specific workspaces.
  * While these limitations originate from Wayland itself, many window managers provide alternative solutions.
  However, GNOME makes it particularly difficult to implement such workarounds.
  Creating custom GNOME extensions is possible, but the learning curve is steep and the API lacks stability.

## Hyprland

- Cons:
  - Static workspace (id: 1,2,3,...)
    - As a result, it is not easy to insert a new workspace into a place.
    - Though we can write a script to swap workspace from tail to the place,
      it is very inelegant.

## Plasma

Cons:
- Does not support set 3-finger swipe directions
- Extensions use JS
