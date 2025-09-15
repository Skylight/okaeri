#!/bin/bash

set -e

if ! type -p git >/dev/null; then
	sudo apt install git -y git
fi

if [ ! -d "$HOME/okaeri" ]; then
	echo "Setting up repository"
	cd $HOME
	git clone git@github.com:Skylight/okaeri.git
fi

grep -qxF '. \$HOME/okaeri/core/bash/initialize' $HOME/.bashrc || printf "\n\n# Okaeri (https://github.com/Skylight/okaeri)\n. \$HOME/okaeri/core/bash/initialize\n" >> $HOME/.bashrc

echo ""
echo "Okaeri installed"
echo "================"
echo ""
echo "The next time you connect to the terminal, the boot script will be loaded. To run the boot script now, type:"
echo ""
echo ". okaeri/core/bash/initialize"
echo ""