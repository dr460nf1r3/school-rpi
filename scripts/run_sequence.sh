#!/usr/bin/env bash
set -e # abort on error
DEPS=(sl cowsay) # these are needed to run the script

# Function to install our dependencies
install_deps() {
    for dep in "${DEPS[@]}"; do
        sudo apt install "$dep"
    done
}

# Check whether arguments were passed to this script
# if there aren't any, use our defaults
if [ -z "$1" ] && [ -z "$2" ]; then
    COWSAY=3
    SL=2
# if install is passed, install this scripts dependencies
elif [ "$1" == "install" ]; then
    install_deps
else
    # Checking whether the passed argument is a number
    # if it isn't, abort with an error message
    REGEX='^[0-9]+$'
    if ! [[ "$1" =~ $REGEX ]] && ! [[ "$1" =~ $REGEX ]]; then
        echo "You need to pass 2 integeters to this script!" >&2
        exit 1
    else
        # if it is, assign arguments to our variables
        SL="$1"
        COWSAY="$2"
    fi
fi

# Install deps if they aren't available
if ! (type sl &>/dev/null) || ! (type cowsay &>/dev/null); then
    install_deps
fi

# First loop
N=0
while [ $N -lt "$SL" ]; do
    sl
    N=$((N + 1))
done

# Second loop
N=0
while [ $N -lt "$COWSAY" ]; do
    cowsay "I Love CPS"
    N=$((N + 1))
done
