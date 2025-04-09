#!/bin/bash
# This is a CodeRunner compile script. Compile scripts are used to compile
# code before being run using the run command specified in CodeRunner
# preferences. This script is invoked with the following properties:
#
# Current directory:	The directory of the source file being run
#
# Arguments $1-$n:		User-defined compile flags	
#
# Environment:			$CR_FILENAME	Filename of the source file being run
#						$CR_ENCODING	Encoding code of the source file
#						$CR_TMPDIR		Path of CodeRunner's temporary directory
#
# This script should have the following return values:
# 
# Exit status:			0 on success (CodeRunner will continue and execute run command)
#
# Output (stdout):		On success, one line of text which can be accessed
#						using the $compiler variable in the run command
#
# Output (stderr):		Anything outputted here will be displayed in
#						the CodeRunner console

[ -z "$CR_SUGGESTED_OUTPUT_FILE" ] && CR_SUGGESTED_OUTPUT_FILE="$PWD/${CR_FILENAME%.*}"
cratename="$(basename "$CR_SUGGESTED_OUTPUT_FILE" | sed 's/[[:blank:]]/_/g')"

#!/bin/bash

# Constants
MAX_DEPTH=5  # Maximum number of directories to traverse up

# Look for a Cargo.tml file and use cargo build if it is found.
CURRENT_DIR=$(pwd)
DEPTH=0
CARGO_TOML_DIR=""

# Traverse up until Cargo.toml found, or max depth is reached
while [ "$CURRENT_DIR" != "/" ]; do
	if [ -f "$CURRENT_DIR/Cargo.toml" ]; then
		CARGO_TOML_DIR=$CURRENT_DIR
		break
	fi
	
	# Check if maximum depth is reached
	if [ $DEPTH -ge $MAX_DEPTH ]; then
		break
	fi
	
	# Move up one directory
	CURRENT_DIR=$(dirname "$CURRENT_DIR")
	DEPTH=$((DEPTH + 1))
done

if [ -n "$CARGO_TOML_DIR" ]; then
	echo "Found Cargo.toml in: $CARGO_TOML_DIR"
	cd "$CARGO_TOML_DIR"
	
	# Generate short messages that CodeRunner can interpret for inline reporting
	cargo build --message-format=short
	status=$?
	if [ $status -eq 0 ]; then
		# Extract package name from toml
		PACKAGE_NAME=$(awk '/^name = / { print $3; exit }' "$CARGO_TOML_DIR/Cargo.toml" | tr -d '"')
		# Run binary
		echo "$CARGO_TOML_DIR/target/debug/$PACKAGE_NAME"
	fi
	exit $status
fi

echo "No Cargo.lock found. Falling back to rustc."
rustc --error-format=short -o "$CR_SUGGESTED_OUTPUT_FILE" --crate-name "$cratename" "$CR_FILENAME" "${@:1}" ${CR_DEBUGGING:+-g}

status=$?
if [ $status -eq 0 ]; then
	echo $CR_SUGGESTED_OUTPUT_FILE
fi
exit $status