echo Installing needed libs for Moon4K!
haxelib --global install hmm
haxelib --global run hmm setup
hmm install
echo Setting up lime..
haxelib run lime setup -y
echo Moon4K! fully set up for building!