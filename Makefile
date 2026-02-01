.PHONY: help build gate-auth gate-auth-smoke gate-auth-e2e gate-auth-issuer gate-hub gate-hub-auth-codeflow gate-hub-rbac

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

gate-hub-auth-codeflow:
	@./scripts/gate-hub-auth-codeflow.sh

gate-hub-rbac:
	@./scripts/gate-hub-rbac.sh

gate-hub: gate-hub-auth-codeflow gate-hub-rbac
