.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

clean: ## Clean the project
	cmake --build ./build --target clean

configure: ## Configure the project
	cmake . -Bbuild -DCMAKE_INSTALL_PREFIX=build -DCMAKE_BUILD_TYPE=Release

configure-debug: ## Configure the project for debug
	cmake . -Bbuild -DCMAKE_INSTALL_PREFIX=build -DCMAKE_BUILD_TYPE=Debug

build-webrtc: ## Build the project
	cmake --build ./build

pack: ## Pack the artifacts
	cmake --build ./build --target pack
