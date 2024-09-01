echo Installing and Setting up Haxe!
sudo add-apt-repository ppa:haxe/releases -y
sudo apt-get update
sudo apt-get install haxe -y
mkdir ~/haxelib && haxelib setup ~/haxelib
echo Haxe installed and properly set up!
echo Installing needed libs for Moon4K!
haxelib install lime 7.9.0
haxelib install openfl
haxelib --never install flixel 4.11.0
haxelib run lime setup flixel
haxelib run lime setup -y
haxelib install flixel-tools
haxelib install flixel-addons 2.11.0
haxelib install flixel-ui
haxelib git hscript-improved https://github.com/FNF-CNE-Devs/hscript-improved
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc.git
haxelib install hxCodec
haxelib install newgrounds 1.1.4
haxelib git tentools https://github.com/TentaRJ/tentools
haxelib git hxcpp https://github.com/yophlox/fxcpp
haxelib set lime 7.9.0
haxelib set flixel 4.11.0
haxelib set flixel-addons 2.11.0
echo Setting up lime..
haxelib run lime setup -y
echo Moon4K! fully set up for building!