all: SUMMARY.md
	mdbook build

.PHONY: SUMMARY.md
SUMMARY.md: .genSUMMARY.sh
	./$< > $@
