ANSIBLE_LINTER = ansible-lint
YAMLLINT = yamllint

.PHONY: all
all: ansible-lint yamllint cleanup
test: test

.PHONY: ansible-lint
ansible-lint:
	@echo "Running ansible-lint..."
	$(ANSIBLE_LINTER) ./*

.PHONY: yamllint
yamllint:
	@echo "Running yamllint..."
	$(YAMLLINT) .

.PHONY: cleanup
cleanup:
	@echo "Cleaning up..."
	rm -rf .ansible

.PHONY: test
test:
	rm -rf ~/.ansible/roles/tbauriedel.k3s
	cp -r ../ansible-role-k3s ~/.ansible/roles/tbauriedel.k3s
	ansible-playbook -i testing/inventory.ini testing/playbook.yml --ask-pass
