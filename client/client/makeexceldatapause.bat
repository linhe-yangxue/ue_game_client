@echo off
if "%1" == "" goto label1
cd %1
:label1
cd ../sharedata/exceldata/
call .\\run.bat
copy .\data\client\*.lua ..\..\client\LuaScript\Data\
echo success!
cd ../../client
pause