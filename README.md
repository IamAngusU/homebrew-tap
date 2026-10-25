# Angus's Homebrew tap

Install the stable [php-fpm-audit](https://github.com/IamAngusU/php-fpm-audit) launcher on Linux or macOS:

```sh
brew install iamangusu/tap/php-fpm-audit
php-fpm-audit --ssh root@SERVER
```

Replace `SERVER` with your existing SSH target. macOS is an SSH client; the audit runs on Linux. Linux targets need Python 3.8+ and readable `/proc`. The supported configuration workflow is Debian/Ubuntu host PHP-FPM with Nginx and systemd.

On Linux, for a complete local audit:

```sh
sudo "$(brew --prefix)/bin/php-fpm-audit"
```

The default audits only. Review changes with `--dry-run` before using `--fix`. For Homebrew rollback, pass the printed rollback options to the installed `php-fpm-audit` command, using its absolute path with sudo as above.

Upgrade with `brew update && brew upgrade php-fpm-audit`; uninstall with `brew uninstall php-fpm-audit`.

The formula downloads the versioned 2.2.2 release archive and verifies its SHA-256. A small command wrapper invokes Homebrew's Bash; the embedded release launcher stays byte-for-byte unchanged. Linux also receives a declared Python dependency; macOS does not need local Python for SSH use. The legacy `p2s-harden.sh` command remains available.

[Usage](https://github.com/IamAngusU/php-fpm-audit#start-here) · [Download provenance](https://github.com/IamAngusU/php-fpm-audit/blob/v2.2.2/docs/PROVENANCE.md) · [Public packaging CI](https://github.com/angusu-de/homebrew-tap/actions/workflows/ci.yml)

Packaging CI checks Linux, Apple Silicon macOS and Intel macOS installation, formula style/audit, unchanged launcher bytes, diagnostics and SSH transport through a local fixture. It does not audit or change a real PHP-FPM server. CI runs on a separate account of the same maintainer and requires matching source/fork commits.
