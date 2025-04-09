# CodeRunnerCompileScripts

Customised language compile scripts for CodeRunner4 for macOS.

These scripts replace the compile.sh files for the .crLanguage package under ~/Library/Application Support/CodeRunner/Languages/ e.g.:
~/Library/Application Support/CodeRunner/Languages/Rust.crLanguage/Scripts/compile.sh

The standard compile.sh for the Rust language uses rustc only to compile the current file.
The modified script in the Rust directory:
- uses cargo build if a Cargo.toml file is found
- uses --error-format=short so that warnings and errors are reported inline in the editor rather than just the console