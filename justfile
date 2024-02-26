default:
  just --list

run:
  poetry run mkdocs serve -a localhost:4200

check:
  poetry run markdownlint docs/

lint:
  poetry run markdownlint --fix docs/

pc:
  poetry run pre-commit run --all-files
