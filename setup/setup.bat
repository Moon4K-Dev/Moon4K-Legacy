@echo off
title Moon4K! Setup - Start
echo Make sure Haxe and HaxeFlixel is installed (4.1.5 is important)!
echo Press any key to install required libraries.
pause >nul
title Moon4K! Setup - Installing libraries
echo Installing haxelib libraries...
cinst haxe --version 4.1.5 -y
mkdir "%HAXELIB_ROOT%"
haxelib setup "%HAXELIB_ROOT%"
haxelib install lime 
haxelib install openfl
haxelib --never install flixel
haxelib run lime setup flixel
haxelib git hscript-improved https://github.com/FNF-CNE-Devs/hscript-improved
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc.git
haxelib install hxCodec
haxelib install newgrounds 1.1.4
haxelib git tentools https://github.com/TentaRJ/tentools
haxelib git hxcpp https://github.com/yophlox/fxcpp
haxelib run lime setup -y
haxelib install flixel-tools
haxelib install flixel-addons
haxelib install flixel-ui
cls