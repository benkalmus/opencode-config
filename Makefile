PACKAGES := opencode

.PHONY: all init stow unstow restow adopt clean backup

all: init stow

init:
	@echo "Initializing submodules..."
	@git submodule update --init --recursive

stow: init backup
	@for pkg in $(PACKAGES); do \
		echo "Stowing $$pkg..."; \
		stow -v -R -t $(HOME) $$pkg; \
	done

# Back up only genuine collisions: a real file standing under real directories.
# Anything living under a symlink belongs to stow's subtree and is left alone.
backup:
	@for pkg in $(PACKAGES); do \
		( cd $$pkg && find . -mindepth 1 \( -type f -o -type l \) | sed 's|^\./||' | while IFS= read -r f; do \
			tgt="$(HOME)/$$f"; \
			d="$$tgt"; owned=0; \
			while [ "$$d" != "$(HOME)" ] && [ "$$d" != "/" ]; do \
				d=$$(dirname "$$d"); \
				if [ -L "$$d" ]; then owned=1; break; fi; \
			done; \
			if [ $$owned -eq 0 ] && [ -e "$$tgt" ] && [ ! -L "$$tgt" ]; then \
				suffix=".bak.$$(date +%Y%m%d%H%M%S)"; \
				echo "Collision on $$tgt, backing up to $$tgt$$suffix..."; \
				mv "$$tgt" "$$tgt$$suffix"; \
			fi; \
		done ); \
	done

unstow:
	@for pkg in $(PACKAGES); do \
		echo "Unstowing $$pkg..."; \
		stow -v -D -t $(HOME) $$pkg; \
	done

restow: unstow stow

adopt:
	@for pkg in $(PACKAGES); do \
		echo "Adopting $$pkg..."; \
		stow -v --adopt -t $(HOME) $$pkg; \
	done

# Import live cli.json into the repo, validate it, and restore the stow symlink.
# The TUI rewrites this file by replace (breaking the link); run this after
# changing settings in the TUI instead of letting the next restow collide.
sync-cli:
	@test -f $(HOME)/.config/opencode/cli.json || (echo "no live cli.json"; exit 1)
	@if [ ! -L $(HOME)/.config/opencode/cli.json ]; then cp $(HOME)/.config/opencode/cli.json opencode/.config/opencode/cli.json; else echo "link intact, nothing to import"; fi
	@if [ ! -L $(HOME)/.config/opencode/cli.json ]; then rm $(HOME)/.config/opencode/cli.json; fi
	@stow -R -t $(HOME) opencode
	@ls -l $(HOME)/.config/opencode/cli.json

clean:
	@echo "WARNING: This will remove opencode config symlinks from \$$HOME."
	@printf "Proceed? [y/N] "; read ans; case "$$ans" in [yY]|[yY][eE][sS]) ;; *) echo "Aborted."; exit 1;; esac
	@echo "Removing old symlinks..."
	@for pkg in $(PACKAGES); do \
		stow -v -D -t $(HOME) $$pkg 2>/dev/null; \
	done
	@rm -f $(HOME)/.config/opencode/AGENTS.md \
		$(HOME)/.config/opencode/dcp.jsonc \
		$(HOME)/.config/opencode/cli.json \
		$(HOME)/.config/opencode/opencode.json
	@rm -rf $(HOME)/.config/opencode/command \
		$(HOME)/.config/opencode/commands \
		$(HOME)/.config/opencode/plugin \
		$(HOME)/.config/opencode/skills \
		$(HOME)/.config/opencode/plugins
	@echo "Clean. Run 'make stow' to deploy."