@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
if "%~1"=="" (
	echo Usage: %~0 URHO_3D_SOURCE_DIR
	exit /B 1
)
echo Generating API...
if exist out rmdir /s /q out
mkdir out
mkdir out\api
pushd %~1\Source\Engine\LuaScript\pkgs\
for %%i in (*.pkg) do echo $pfile "%%~nxi" >> %~dp0\out\Urho3D.pkg
..\..\..\..\Bin\tolua++ -L %~dp0\src\generator.lua -P -o %~dp0\out\api\api.lua %~dp0\out\Urho3D.pkg
if errorlevel 1 (
	popd
	exit /B 1
)
popd
pushd out
del api\api.lua
del api\Urho3D.pkg
lua ..\lib\luadocumentor-0.1.3\luadocumentor.lua api
popd
