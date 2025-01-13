@echo off

:: KDSP Signtool wrapper for Eden SDK / AAX wraptool
::
:: wraptool invokes signtool but makes a lot of assumptions about how we're going to sign
:: which are incompatible with Azure Trusted Signing.
::
:: This tool removes all its arguments and replaces it with the correct or necessary ones.
:: Please adjust accordingly if necessary.
::
:: Run Eden SDK's wraptool as follows:
::
:: wraptool.exe sign --signtool signtool.bat --signid 1 --verbose --installedbinaries --account ... --password ... --wcguid ... --in ...
::
:: signid 1 is bogus, but wraptool needs this nonsense in order to start up..
::
:: The following environment variables are necessary:
::
:: SIGNTOOL_PATH
:: ACS_DLIB (points to Dlib.dll file)
:: ACS_JSON (points to the metadata.json file)
:: AZURE_TENANT_ID (Microsoft Azure tenant ID)
:: AZURE_CLIENT_ID (Microsoft Azure codesigning app client ID)
:: AZURE_SECRET_ID (Microsoft Azure codesigning app secret value)
::

:: Get script root dir, so we can find aax-signtool.py
set root=%~dp0
set root=%root:~0,-1%

:: wraptool seems to mangle signtool's args and doesn't properly quote-escape the final binary path,
:: and batch is not easy with string handling, so we use python to fix things up..
set args=%*
echo %args%>args.tmp
echo Patched signtool: Input arguments: %args%
python "%root%\aax-signtool.py"
set /p args=<args.tmp
echo Patched signtool: Filtered arguments: %args%
set file="%args%"

echo Patched signtool: File to sign: %file%

if not defined SIGNTOOL_PATH (
	echo Patched signtool: ERROR: SIGNTOOL_PATH not defined
	exit /b 1000
)
if not exist "%SIGNTOOL_PATH%" (
	echo Patched signtool: ERROR: Could not find signtool.exe at "%SIGNTOOL_PATH%"
	exit /b 1000
)

echo Patched signtool: Executing: "%SIGNTOOL_PATH%" sign /v /debug /fd SHA256 /tr "http://timestamp.acs.microsoft.com" /td SHA256 /dlib %ACS_DLIB% /dmdf %ACS_JSON% %file%
"%SIGNTOOL_PATH%" sign /v /debug /fd SHA256 /tr "http://timestamp.acs.microsoft.com" /td SHA256 /dlib %ACS_DLIB% /dmdf %ACS_JSON% %file%
@if %errorlevel% neq 0 exit /b %errorlevel%

echo Patched signtool: Success