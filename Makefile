DOTFILES := $(subst ./src/, , $(wildcard ./src/.??*))
FILES := $(subst ./src/, , $(wildcard ./src/*))

.PHONY: deploy
deploy:
	@$(foreach file, $(DOTFILES), ln -s $(abspath ./src/$(file)) $(HOME)/$(file);)
	@$(foreach file, $(FILES), ln -s $(abspath ./src/$(file)) $(HOME)/$(file);)

