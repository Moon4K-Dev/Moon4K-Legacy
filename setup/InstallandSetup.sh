echo Installing and Setting up Haxe!
sudo add-apt-repository ppa:haxe/releases -y
sudo apt-get update
sudo apt-get install haxe -y
mkdir ~/haxelib && haxelib setup ~/haxelib
echo Haxe installed and properly set up!
echo Installing needed libs for Lantern Framework!
haxelib install lime 7.9.0
haxelib install openfl
haxelib --never install flixel 4.11.0
haxelib run lime setup flixel
haxelib run lime setup -y
haxelib install flixel-tools
haxelib install flixel-addons 2.11.0
haxelib install flixel-ui
haxelib git polymod https://github.com/larsiusprime/polymod
haxelib git hscript-improved https://github.com/YoshiCrafter29/hscript-improved
haxelib set lime 7.9.0
haxelib set flixel 4.11.0
haxelib set flixel-addons 2.11.0
echo Setting up lime..
haxelib run lime setup -y
echo Lantern Framework! fully set up for building!