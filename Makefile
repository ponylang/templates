PACKAGE := templates
GET_DEPENDENCIES_WITH := corral fetch
CLEAN_DEPENDENCIES_WITH := corral clean
COMPILE_WITH := corral run -- ponyc

SRC_DIR ?= $(PACKAGE)

SOURCE_FILES := $(shell find $(SRC_DIR) -name *.pony)

all: test docs

docs: $(SOURCE_FILES)
	$(GET_DEPENDENCIES_WITH)
	$(COMPILE_WITH) --docs-public --pass=docs --output build $(SRC_DIR)

build/templates: $(SOURCE_FILES)
	$(GET_DEPENDENCIES_WITH)
	$(COMPILE_WITH) -o build $(SRC_DIR)

build/templates_dbg: build/templates
	$(COMPILE_WITH) --debug -o build -b templates_dbg $(SRC_DIR)

test: build/templates
	$^

build/coverage:
	mkdir -p build/coverage

coverage: build/coverage build/templates_dbg
	kcov --include-pattern="/$(SRC_DIR)/" --exclude-pattern="/test/,_test.pony" build/coverage build/templates_dbg

clean:
	$(CLEAN_DEPENDENCIES_WITH)
	rm -rf build

.PHONY: all clean docs test
