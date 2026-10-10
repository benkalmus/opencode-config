## Quick start

```sh
git clone git@github.com:benkalmus/opencode-config.git
cd opencode-config
make all
```

This initializes submodules, installs plugin deps, and stows config to `~/.config/opencode`.

Or manually:

```sh
stow -t ~ opencode
```

## First-time setup on new machine

```sh
git clone git@github.com:benkalmus/opencode-config.git
cd opencode-config
git submodule update --init --recursive
make stow
```

## Prereq

Add a key to your environment variables:

```sh
#.env
export OPENROUTER_API_KEY=...

```

Enable web search in opencode:
 
```sh 
# .zshrc / .bashrc
export OPENCODE_ENABLE_EXA=1 
```

## Plugins

Already configured:
- [DCP](https://github.com/Opencode-DCP/opencode-dynamic-context-pruning): Dynamic Context Pruning: significantly reduces context usage by removing tool calls, errors and repeat mistakes.

Consider [superpowers](https://github.com/obra/superpowers). A set of skills to guide development, careful planning, incorporating best practices and without making the same mistakes.
Navigate to [this page](https://github.com/obra/superpowers/blob/main/docs/README.opencode.md)

See more [on this page](https://github.com/awesome-opencode/awesome-opencode).

## Remote Opencode-

### Discord bot

1. Create a service file (replace path and username)
2. Perform `npx remote-opencode setup`
3. Symlink the **user** service file:

```sh 
ln -snf $(pwd)/remote-opencode.service ~/.config/systemd/user/remote-opencode.service
```

4. Start and enable the service:

```sh
systemctl --user daemon-reload

systemctl --user start remote-opencode.service
systemctl --user enable remote-opencode.service

# Troubleshooting logs:
journalctl --user -u remote-opencode.service -f
```

### Telegram bot

Uses [opencode-telegram-bot](https://github.com/grinev/opencode-telegram-bot). Starts the OpenCode V2 background service and the Telegram bot in a single service.

1. Install the bot's dependencies and run initial config wizard:

```sh
npx @grinev/opencode-telegram-bot
```

2. Configure the bot for OpenCode V2 in `~/.config/opencode-telegram-bot/.env`:

```env
OPENCODE_SERVER_VERSION=v2
OPENCODE_API_URL=http://127.0.0.1:49374
OPENCODE_SERVER_PASSWORD=<output of `opencode service get password`>
```

The password is stored in `~/.config/opencode/service.json` and survives restarts. Set your own with `opencode service set password <value>` (this stops the background service once). The standalone `opencode serve` prints a new password on every start, so point the bot at the background service, not a standalone server.

3. Symlink the service file:

```sh
ln -snf $(pwd)/opencode-telegram.service ~/.config/systemd/user/opencode-telegram.service
```

4. Start and enable:

```sh
systemctl --user daemon-reload
systemctl --user enable --now opencode-telegram

# Allow service to run without an active login session:
loginctl enable-linger $(whoami)
```

5. Check status / logs:

```sh
systemctl --user status opencode-telegram
journalctl --user -u opencode-telegram -f
```

