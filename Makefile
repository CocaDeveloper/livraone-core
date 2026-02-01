.PHONY: help build gate-auth gate-auth-smoke gate-auth-e2e gate-auth-issuer

help:
	@echo "Targets: build gate-auth"

build:
	@echo "Nothing to build yet"

gate-auth-smoke:
	@./scripts/gate-auth-smoke.sh

gate-auth-e2e:
	@./scripts/gate-auth-e2e.sh

gate-auth-issuer:
	@./scripts/gate-auth-issuer.sh

gate-auth: gate-auth-issuer gate-auth-smoke gate-auth-e2e
