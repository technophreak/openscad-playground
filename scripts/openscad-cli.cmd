@echo off
setlocal
"%~dp0openscad-cli.exe" %*
exit /b %ERRORLEVEL%
