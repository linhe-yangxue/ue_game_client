@echo off
del .\UE\Assets\Res\sproto\*.bytes
copy ..\sharedata\sproto\bin\*.spb .\UE\Assets\Res\sproto\*.spb.bytes
cd ../../../../