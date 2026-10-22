.PHONY: validate test deploy smoke clean
validate:
	./scripts/validate-local.sh
test:
	./tests/test-template.sh
deploy:
	./scripts/deploy-local.sh
smoke:
	./scripts/smoke-test.sh
clean:
	./scripts/cleanup.sh
