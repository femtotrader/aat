CONFIG=./config/backtest_multi.cfg
EXCHANGE=gdax


runconfig: build ## Clean and make target, run target
	python3 -m aat --config=$(CONFIG)

run:  clean build  ## Clean and make target, run target
	python3 -m aat --live --verbose=$(VERBOSE) --exchange=$(EXCHANGE)

sandbox: build  ## Clean and make target, run target
	python3 -m aat --sandbox --verbose=$(VERBOSE) -exchange=$(EXCHANGE)

backtest_config: ## Clean and make target, run backtest
	python3 -m aat --config=./config/backtest_gemini.cfg

backtest: ## Clean and make target, run backtest
	python3 -m aat --backtest --verbose=$(VERBOSE) --exchange=$(EXCHANGE)

backtest_inline:  ## Clean and make target, run backtest, plot in terminal
	bash -c "export MPLBACKEND=\"module://itermplot\";	export ITERMPLOT=\"rv\"; python3 -m aat backtest $(VERBOSE) $(EXCHANGE)"

boost:  ## Install boost python dependencies on os x with homebrew
	brew install boost boost-python3
	sudo ln -s /usr/local/lib/libboost_python37.dylib /usr/local/lib/libboost_python.dylib

buildext: ## build the package extensions
	python3 setup.py build_ext

build: ## build the package
	python3 setup.py build

install: ## install the package
	python3 setup.py install

tests: ## Clean and Make unit tests
	python3 -m pytest -v ./aat/tests --cov=aat

test: clean build lint ## run the tests for travis CI
	@ python3 -m pytest -v ./aat/tests --cov=aat

test_verbose: ## run the tests with full output
	@ python3 -m pytest -vv ./aat/tests --cov=aat

lint: ## run linter
	flake8 aat 

annotate: ## MyPy type annotation check
	mypy -s aat 

annotate_l: ## MyPy type annotation check - count only
	mypy -s aat | wc -l 

docs:  ## Build the sphinx docs
	make -C docs html

micro:  ## steps before dist, defaults to previous tag + one micro
	. scripts/deploy.sh MICRO

minor:  ## steps before dist, defaults to previous tag + one micro
	. scripts/deploy.sh MINOR

major:  ## steps before dist, defaults to previous tag + one micro
	. scripts/deploy.sh MAJOR

dist:  ## dist to pypi
	python3 setup.py sdist upload -r pypi

clean: ## clean the repository
	find . -name "__pycache__" | xargs rm -rf
	find . -name "*.pyc" | xargs rm -rf
	rm -rf .coverage coverage cover htmlcov logs build dist *.egg-info
	find . -name "*.so"  | xargs rm -rf
	make -C ./docs clean

# Thanks to Francoise at marmelab.com for this
.DEFAULT_GOAL := help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

print-%:
	@echo '$*=$($*)'

.PHONY: clean run runconfig sandbox backtest backtest_config test tests test_verbose help install docs data dist js build buildext boost
