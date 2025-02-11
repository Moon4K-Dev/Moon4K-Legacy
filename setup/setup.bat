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
haxelib --global install hmm
haxelib --global run hmm setup
cd .. && hmm install
cls
