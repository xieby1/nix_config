all: test

md: SUMMARY.md
	mdbook build

NIXs = $(shell find . -name "*.nix" -not -path "./book*")
NIX_MDs = $(addsuffix .md,${NIXs})
%.md: %
	markcode $< > $@

# update markcode progross
README.md: ./.markcode_progress.sh ${NIXs}
	./$<

ALL_MDs = $(shell find . -name "*.md" -not -name "SUMMARY.md")
SUMMARY.md: .genSUMMARY.sh ${NIX_MDs} ${ALL_MDs}
	./$< > $@

test: all.test.nix.run all.test.sh.run all.test.py.run
all.test.nix.run: $(addsuffix .run, $(shell find . -name test.nix))
all.test.sh.run: $(addsuffix .run, $(shell find . -name test.sh))
%.nix.run: %.nix
	nix eval -f $<
%.sh.run: %.sh
	bash $<
