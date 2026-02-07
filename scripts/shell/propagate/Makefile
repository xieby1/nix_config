NIXs = $(wildcard *.nix)

test: $(addprefix test.,${NIXs})

test.%: %
	# If this command run successfully, then it means the hello is propagated!
	nix-shell --pure $< --run hello
