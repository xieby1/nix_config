all: SUMMARY.md
	mdbook build

NIXs = $(shell find . -name "*.nix" -not -path "./book*")
NIX_MDs = $(addsuffix .md,${NIXs})
%.md: %
	markcode $< > $@

ALL_MDs = $(shell find . -name "*.md" -not -name "SUMMARY.md")
SUMMARY.md: .genSUMMARY.sh ${NIX_MDs} ${ALL_MDs}
	./$< > $@
