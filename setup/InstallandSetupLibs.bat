@echo off
title Lantern Framework! Setup - Start
echo Make sure Haxe and HaxeFlixel is installed (4.1.5 is important)!
echo Press any key to install required libraries.
pause >nul
title Lantern Framework! Setup - Installing libraries
echo Installing haxelib libraries...
cinst haxe --version 4.1.5 -y
mkdir "%HAXELIB_ROOT%"
haxelib setup "%HAXELIB_ROOT%"
haxelib install lime 7.9.0
haxelib install openfl
haxelib --never install flixel 4.11.0
haxelib run lime setup flixel
haxelib git polymod https://github.com/larsiusprime/polymod
haxelib run lime setup -y
haxelib install flixel-tools
haxelib install flixel-addons 2.11.0
haxelib install flixel-ui
title Lantern Framework! Setup - Press anything to activate lime & flixel tools.
cls
echo Setting up lime...
haxelib run lime setup
haxelib set flixel 4.11.0
haxelib set lime 7.9.0
haxelib set flixel-addons 2.11.0
cls