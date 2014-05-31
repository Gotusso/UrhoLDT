#!/bin/bash
if [ -z "$1" ]; then
    echo Usage: $0 URHO_3D_SOURCE_DIR
    exit 1
fi
echo "Generating API..."
cd $( dirname $0 )
WD=`pwd`
if [ -d "out" ]; then
  rm -rf out
fi
mkdir -p out/api
pushd $1/Source/Engine/LuaScript/pkgs > /dev/null
for i in *.pkg; do echo "\$pfile \"$i\"" >> $WD/out/Urho3D.pkg; done
../../../../Bin/tolua++ -L $WD/src/generator.lua -P -o $WD/out/api/api.lua $WD/out/Urho3D.pkg
if [ $? -ne 0 ]; then 
	popd > /dev/null
	exit 1
fi
popd > /dev/null
pushd out > /dev/null
rm -f api/api.lua
rm -f /Urho3D.pkg
lua ../lib/luadocumentor-0.1.3/luadocumentor.lua api
popd > /dev/null