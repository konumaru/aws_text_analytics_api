default: help

.PHONY: help
help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

.PHONY: init
init: # Install dependencies with poetry.
	@echo "Installing dependencies..."
	poetry install

	./bin/init.sh

.PHONY: lint
lint: # Run lint with poetry.
	@echo "Running lint..."
	poetry run isort tests/
	poetry run black tests/
	poetry run pflake8 tests/
	poetry run mypy tests/

.PHONY: tests
tests: # Run lint and tests with poetry.
	make lint
	@echo "Running tests..."
	poetry run pytest ./tests
