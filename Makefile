.PHONY: run
run:	## Run project with compose
	poetry run mkdocs serve -a localhost:4200

.PHONY: check
check:	## Check formatting and linting rules
	poetry run markdownlint docs/

.PHONY: format
format:	## Format docs
	poetry run markdownlint --fix docs/

.PHONY: pre-commit
pre-commit:	## Run pre-commit checks
	poetry run pre-commit run --all-files
