{ ... }: {
  # Superseded the upstream ponytail extension (npins pin removed): the rules
  # now live in a pi-hermes-memory managed skill, injected by this one-file
  # extension. Level switching and the status bar went with the old extension.
  home.file.".pi/agent/extensions/inject-ponytail.ts".source = ./inject-ponytail.ts;
}
