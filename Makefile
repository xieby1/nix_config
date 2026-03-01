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

TEST_NIXs = $(shell find . -name test.nix)
test: $(addsuffix .run, ${TEST_NIXs})
%.nix.run: %.nix
	nix eval -f $< | tee /dev/tty | grep -q '\[ \]'

SOURCES_JSONs = $(shell find . -name sources.json)
npins-show: $(addsuffix .show, ${SOURCES_JSONs})
%.json.show: %.json
	npins --lock-file $< show | grep -v "^$$" | grep -v "^ " | sed 's/^/  /'
