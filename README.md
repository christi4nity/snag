<p align="center">
  <img src="assets/logo.svg?v=2" width="128" height="128" alt="Snag logo">
</p>

<h1 align="center">Snag</h1>

<p align="center">
  Copy on select for macOS. Select text anywhere and it's instantly on your clipboard.
</p>

<p align="center">
  <a href="#install">Install</a> · <a href="#how-it-works">How it works</a> · <a href="#usage">Usage</a>
</p>

---

## Install

### Homebrew

```bash
brew tap christi4nity/snag
brew install snag
open $(brew --prefix)/opt/snag/Snag.app
```

### From source

```bash
git clone https://github.com/christi4nity/snag.git
cd snag
make build
open Snag.app
```

Requires Xcode Command Line Tools and macOS 13 (Ventura) or later.

## How it works

Snag monitors mouse events system-wide. When you select text — by dragging, double-clicking (word), or triple-clicking (line) — it fires a `Cmd+C` keystroke after a brief delay. That's it.

On first launch, macOS will ask you to grant Accessibility permission. Snag needs this to detect selections and simulate the copy keystroke.

## Usage

- **Left-click** the scissors icon in the menu bar to toggle on/off
- **Right-click** for the menu: Enable/Disable, Launch at Login, Quit

When enabled, any text you select — by dragging, double-clicking, or triple-clicking — is automatically copied to your clipboard.

## License

[MIT](LICENSE)
