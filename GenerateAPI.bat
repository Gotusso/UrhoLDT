@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
if "%~1"=="" (
	echo Usage: %~0 URHO_3D_SOURCE_DIR
	exit /B 1
)
if exist out rmdir /s /q out
mkdir out
mkdir out\api
pushd %~1\Source\Engine\LuaScript\pkgs\
echo Generating API...
..\..\..\..\Bin\tolua++ -L %~dp0\src\generator.lua -P -o %~dp0\out\api\api.lua Urho3D.tolua
if errorlevel 1 (
	popd
	exit /B 1
)
popd
pushd out
del api\api.lua
lua ..\lib\luadocumentor-0.1.3\luadocumentor.lua api
popd
