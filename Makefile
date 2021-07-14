include common.mk

test: lint test-regions-and-samples test-regions test-samples

test-regions-and-samples:
	miniwdl run --verbose --copy-input-files vcf_view.wdl --input tests/regions_and_samples.json
	scripts/verify.py _LAST/out/output_vcf/$(shell cat tests/regions_and_samples.json | jq -r .output_filename) \
	--regions-file tests/fixtures/regions.txt \
	--samples-file tests/fixtures/samples.txt

test-samples:
	miniwdl run --verbose --copy-input-files vcf_view.wdl --input tests/samples.json
	scripts/verify.py _LAST/out/output_vcf/$(shell cat tests/samples.json | jq -r .output_filename) \
	--regions-file tests/fixtures/regions.txt --regions-should-not-match \
	--samples-file tests/fixtures/samples.txt

test-regions:
	miniwdl run --verbose --copy-input-files vcf_view.wdl --input tests/regions.json
	scripts/verify.py _LAST/out/output_vcf/$(shell cat tests/regions.json | jq -r .output_filename) \
	--regions-file tests/fixtures/regions.txt \
	--samples-file tests/fixtures/samples.txt --samples-should-not-match

lint:
	miniwdl check vcf_view.wdl

clean:
	git clean -dfx

.PHONY: test test-regions-and-samples test-samples test-regions lint clean
