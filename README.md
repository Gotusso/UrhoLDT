UrhoLDT
=======

This project provides autocomplete for Urho3D API in Eclipse LDT.
To install this environment follow the instructions at [Eclipse LDT reference](http://wiki.eclipse.org/Koneki/LDT/Developer_Area/User_Guides/User_Guide_0.9#Managing_Execution_Environments)

How it works?
------
Urho3D uses toLua++ to wire up the engine with the Lua environment by parsing the Urho's C++ code. This project uses the same method to auto-generate a description of the Lua API in a way readable by Eclipse. This means that if you are using a development version and the provided package doesn't work for you, you can generate a new environment from your own Urho3D working copy by using one of the two provided build scripts (GenerateAPI.sh / GenerateAPI.bat).