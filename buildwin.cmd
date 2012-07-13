@echo off
setlocal enabledelayedexpansion

rem
rem buildwin.cmd
rem
rem POCO C++ Libraries command-line build script 
rem for MS Visual Studio 2003 to 2010
rem
rem $Id: //poco/1.4/dist/buildwin.cmd#2 $
rem
rem Copyright (c) 2006-2010 by Applied Informatics Software Engineering GmbH
rem and Contributors.
rem
rem Original version by Aleksandar Fabijanic.
rem Modified by Guenter Obiltschnig.
rem
rem Usage:
rem ------
rem buildwin DEVENV VS_VERSION [ACTION] [LINKMODE] [CONFIG] [PLATFORM] [SAMPLES] [TESTS]
rem DEVENV:     devenv|vcexpress|msbuild
rem VS_VERSION: 71|80|90|100
rem ACTION:     build|rebuild|clean
rem LINKMODE:   static_mt|static_md|shared|all
rem CONFIG:     release|debug|both
rem PLATFORM:   Win32|x64|WinCE
rem SAMPLES:    samples|nosamples
rem TESTS:      tests|notests

rem
rem DEVENV and VS_VERSION are required arguments. Default is build all.

rem Change OPENSSL_DIR to match your setup
set OPENSSL_DIR=C:\OpenSSL
set OPENSSL_INCLUDE=%OPENSSL_DIR%\include
set OPENSSL_LIB=%OPENSSL_DIR%\lib\VC
set INCLUDE=%INCLUDE%;%OPENSSL_INCLUDE%
set LIB=%LIB%;%OPENSSL_LIB%

rem Change MYSQL_DIR to match your setup
set MYSQL_DIR=C:\PROGRA~1\MySQL\MYSQLS~1.5
set MYSQL_INCLUDE=%MYSQL_DIR%\include
set MYSQL_LIB=%MYSQL_DIR%\lib
set INCLUDE=%INCLUDE%;%MYSQL_INCLUDE%
set LIB=%LIB%;%MYSQL_LIB%

set POCO_BASE=%CD%
set PATH=%POCO_BASE%\bin;%PATH%

rem Build environment
if "%1"=="" goto usage
set BUILD_TOOL="%1"

rem if not msbuild, validate that there is a VS environment
if %BUILD_TOOL%=="msbuild" (
   if not defined WindowsSdkDir (
   echo Error: No Windows SDK environment found.
   echo Please run this script from a Windows SDK Command Prompt
   goto :EOF)
) else (
   if not defined VCINSTALLDIR (
   echo Error: No Visual C++ environment found.
   echo Please run this script from a Visual Studio Command Prompt
   echo or run "%%VSnnCOMNTOOLS%%\vcvars32.bat" first.
   goto :EOF)
)

rem VS version {71|80|90|100}
if "%2"=="" goto usage
set VS_VERSION=vs%2

set VCPROJ_EXT="vcproj"
if %VS_VERSION%==100 (set VCPROJ_EXT="vcxproj")

rem Action [build|rebuild|clean]
set ACTION=%3
if not "%ACTION%"=="build" (
if not "%ACTION%"=="rebuild" (
if not "%ACTION%"=="" (
if not "%ACTION%"=="clean" goto usage)))

if "%ACTION%"=="" (set ACTION="build")

rem Link mode [static|shared|both]
set LINK_MODE=%4
if not "%LINK_MODE%"=="static_mt" (
if not "%LINK_MODE%"=="static_md" (
if not "%LINK_MODE%"=="shared" (
if not "%LINK_MODE%"=="" (
if not "%LINK_MODE%"=="all" goto usage))))

rem Configuration [release|debug|both]
set CONFIGURATION=%5
if not "%CONFIGURATION%"=="release" (
if not "%CONFIGURATION%"=="debug" (
if not "%CONFIGURATION%"=="" (
if not "%CONFIGURATION%"=="both" goto usage)))

rem Platform [Win32|x64|WinCE]
set PLATFORM=%6%

if not "%PLATFORM%"=="" (
if not "%PLATFORM%"=="Win32" (
if not "%PLATFORM%"=="x64" (
if not "%PLATFORM%"=="WinCE" goto usage)))

if "%PLATFORM%"=="" (set PLATFORM_SUFFIX=) else (
if "%PLATFORM%"=="Win32" (set PLATFORM_SUFFIX=) else (
if "%PLATFORM%"=="x64" (set PLATFORM_SUFFIX=_x64) else (
if "%PLATFORM%"=="WinCE" (set PLATFORM_SUFFIX=_CE))))

rem Samples [samples|nosamples]
set SAMPLES=%7
if "%SAMPLES%"=="" (set SAMPLES=samples)

rem Tests [tests|notests]
set TESTS=%8
if "%TESTS%"=="" (set TESTS=notests)

set DEBUG_SHARED=0
set RELEASE_SHARED=0
set DEBUG_STATIC_MT=0
set RELEASE_STATIC_MT=0
set DEBUG_STATIC_MD=0
set RELEASE_STATIC_MD=0

if "%LINK_MODE%"=="shared" (
if "%CONFIGURATION%"=="release" (set RELEASE_SHARED=1) else (
if "%CONFIGURATION%"=="both" (set RELEASE_SHARED=1) else (
if "%CONFIGURATION%"=="" (set RELEASE_SHARED=1))))

if "%LINK_MODE%"=="shared" (
if "%CONFIGURATION%"=="debug" (set DEBUG_SHARED=1) else (
if "%CONFIGURATION%"=="both" (set DEBUG_SHARED=1) else (
if "%CONFIGURATION%"=="" (set DEBUG_SHARED=1))))

if "%LINK_MODE%"=="static_mt" (
if "%CONFIGURATION%"=="release" (set RELEASE_STATIC_MT=1) else (
if "%CONFIGURATION%"=="both" (set RELEASE_STATIC_MT=1) else (
if "%CONFIGURATION%"=="" (set RELEASE_STATIC_MT=1))))

if "%LINK_MODE%"=="static_md" (
if "%CONFIGURATION%"=="release" (set RELEASE_STATIC_MD=1) else (
if "%CONFIGURATION%"=="both" (set RELEASE_STATIC_MD=1) else (
if "%CONFIGURATION%"=="" (set RELEASE_STATIC_MD=1))))

if "%LINK_MODE%"=="static_mt" (
if "%CONFIGURATION%"=="debug" (set DEBUG_STATIC_MT=1) else (
if "%CONFIGURATION%"=="both" (set DEBUG_STATIC_MT=1) else (
if "%CONFIGURATION%"=="" (set DEBUG_STATIC_MT=1))))

if "%LINK_MODE%"=="static_md" (
if "%CONFIGURATION%"=="debug" (set DEBUG_STATIC_MD=1) else (
if "%CONFIGURATION%"=="both" (set DEBUG_STATIC_MD=1) else (
if "%CONFIGURATION%"=="" (set DEBUG_STATIC_MD=1))))

if "%LINK_MODE%"=="all" (
if "%CONFIGURATION%"=="debug" (
set DEBUG_STATIC_MT=1
set DEBUG_STATIC_MD=1
set DEBUG_SHARED=1) else (
if "%CONFIGURATION%"=="release" (
set RELEASE_STATIC_MT=1
set RELEASE_STATIC_MD=1
set RELEASE_SHARED=1) else (
if "%CONFIGURATION%"=="both" (
set DEBUG_STATIC_MT=1
set DEBUG_STATIC_MD=1
set DEBUG_SHARED=1
set RELEASE_STATIC_MT=1
set RELEASE_STATIC_MD=1
set RELEASE_SHARED=1) else (
if "%CONFIGURATION%"=="" (
set DEBUG_STATIC_MT=1
set DEBUG_STATIC_MD=1
set DEBUG_SHARED=1
set RELEASE_STATIC_MT=1
set RELEASE_STATIC_MD=1
set RELEASE_SHARED=1)))))

if "%LINK_MODE%"=="" (
if "%CONFIGURATION%"=="debug" (
set DEBUG_STATIC_MT=1
set DEBUG_STATIC_MD=1
set DEBUG_SHARED=1) else (
if "%CONFIGURATION%"=="release" (
set RELEASE_STATIC_MT=1
set RELEASE_STATIC_MD=1
set RELEASE_SHARED=1) else (
if "%CONFIGURATION%"=="both" (
set DEBUG_STATIC_MT=1
set DEBUG_STATIC_MD=1
set DEBUG_SHARED=1
set RELEASE_STATIC_MT=1
set RELEASE_STATIC_MD=1
set RELEASE_SHARED=1) else (
if "%CONFIGURATION%"=="" (
set DEBUG_STATIC_MT=1
set DEBUG_STATIC_MD=1
set DEBUG_SHARED=1
set RELEASE_STATIC_MT=1
set RELEASE_STATIC_MD=1
set RELEASE_SHARED=1)))))

echo.
echo.
echo ########################################################################
echo ####
echo #### STARTING VISUAL STUDIO BUILD (%VS_VERSION%, %PLATFORM%)
echo ####
echo ########################################################################
echo.
echo.
echo The following configurations will be built:

if %DEBUG_SHARED%==1      (echo debug_shared)
if %RELEASE_SHARED%==1    (echo release_shared)
if %DEBUG_STATIC_MT%==1   (echo debug_static_mt)
if %DEBUG_STATIC_MD%==1   (echo debug_static_md)
if %RELEASE_STATIC_MT%==1 (echo release_static_mt)
if %RELEASE_STATIC_MD%==1 (echo release_static_md)

rem build for up to 4 levels deep
for /f %%G in ('findstr /R "." components') do (
if exist %%G (
  cd %%G
  for /f "tokens=1,2,3,4 delims=/" %%Q in ("%%G") do (
   set PROJECT_NAME=%%Q%PLATFORM_SUFFIX%_%VS_VERSION%.vcproj
   set TEST_PROJECT_NAME=testsuite/TestSuite%PLATFORM_SUFFIX%_%VS_VERSION%.vcproj
   if exist !PROJECT_NAME! (call :build %%G )
   set PROJECT_NAME=%%R%PLATFORM_SUFFIX%_%VS_VERSION%.vcproj
   if exist !PROJECT_NAME! (call :build %%G )
   set PROJECT_NAME=%%S%PLATFORM_SUFFIX%_%VS_VERSION%.vcproj
   if exist !PROJECT_NAME! (call :build %%G )
   set PROJECT_NAME=%%T%PLATFORM_SUFFIX%_%VS_VERSION%.vcproj
   if exist !PROJECT_NAME! (call :build %%G )
   )
  )
  cd %POCO_BASE%
)
)

rem ////////////////////
rem / build subroutine /
rem ////////////////////
:build

 echo.
 echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 echo ++++
 echo ++++ Building %1 [!PROJECT_NAME!]
 echo ++++
 echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 echo.
echo %TESTS%
if %BUILD_TOOL%=="msbuild" (
 if %DEBUG_SHARED%==1      (%BUILD_TOOL% !PROJECT_NAME! /m /p:Configuration=debug_shared /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.
   if "%TESTS%"=="tests" (
     if exist !TEST_PROJECT_NAME! (%BUILD_TOOL% !TEST_PROJECT_NAME! /m /p:Configuration=debug_shared /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.)
   )
 )
 if %RELEASE_SHARED%==1    (%BUILD_TOOL% !PROJECT_NAME! /m /p:Configuration=release_shared /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.
   if "%TESTS%"=="tests" (
     if exist !TEST_PROJECT_NAME! (%BUILD_TOOL% !TEST_PROJECT_NAME! /m /p:Configuration=release_shared /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.)
   )
 )
 if %DEBUG_STATIC_MT%==1   (%BUILD_TOOL% !PROJECT_NAME! /m /p:Configuration=debug_static_mt /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.
   if "%TESTS%"=="tests" (
     if exist !TEST_PROJECT_NAME! (%BUILD_TOOL% !TEST_PROJECT_NAME! /m /p:Configuration=debug_static_mt /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.)
   )
 )
 if %RELEASE_STATIC_MT%==1 (%BUILD_TOOL% !PROJECT_NAME! /m /p:Configuration=release_static_mt /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.
   if "%TESTS%"=="tests" (
     if exist !TEST_PROJECT_NAME! (%BUILD_TOOL% !TEST_PROJECT_NAME! /m /p:Configuration=release_static_mt /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.)
   )
 )
 if %DEBUG_STATIC_MD%==1   (%BUILD_TOOL% !PROJECT_NAME! /m /p:Configuration=debug_static_md /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.
   if "%TESTS%"=="tests" (
     if exist !TEST_PROJECT_NAME! (%BUILD_TOOL% !TEST_PROJECT_NAME! /m /p:Configuration=debug_static_md /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.)
   )
 )
 if %RELEASE_STATIC_MD%==1 (%BUILD_TOOL% !PROJECT_NAME! /m /p:Configuration=release_static_md /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.
   if "%TESTS%"=="tests" (
     if exist !TEST_PROJECT_NAME! (%BUILD_TOOL% !TEST_PROJECT_NAME! /m /p:Configuration=release_static_md /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.)
   )
 )
) else (
 echo "building"
 if %DEBUG_SHARED%==1      (%BUILD_TOOL% /useenv /%ACTION% debug_shared !PROJECT_NAME! && echo. && echo. && echo.
   if "%TESTS%"=="tests" (
      echo ****
     if exist !TEST_PROJECT_NAME! (%BUILD_TOOL% /useenv /%ACTION% debug_shared !TEST_PROJECT_NAME! && echo. && echo. && echo.)
   )
 )
 if %RELEASE_SHARED%==1    (%BUILD_TOOL% /useenv /%ACTION% release_shared !PROJECT_NAME! && echo. && echo. && echo.
   if "%TESTS%"=="tests" (
     if exist !TEST_PROJECT_NAME! (%BUILD_TOOL% /useenv /%ACTION% release_shared !TEST_PROJECT_NAME! && echo. && echo. && echo.)
   )
 )
 if %DEBUG_STATIC_MT%==1   (%BUILD_TOOL% /useenv /%ACTION% debug_static_mt !PROJECT_NAME! && echo. && echo. && echo.
   if "%TESTS%"=="tests" (
     if exist !TEST_PROJECT_NAME! (%BUILD_TOOL% /useenv /%ACTION% debug_static_mt !TEST_PROJECT_NAME! && echo. && echo. && echo.)
   )
 )
 if %RELEASE_STATIC_MT%==1 (%BUILD_TOOL% /useenv /%ACTION% release_static_mt !PROJECT_NAME! && echo. && echo. && echo.
   if "%TESTS%"=="tests" (
     if exist !TEST_PROJECT_NAME! (%BUILD_TOOL% /useenv /%ACTION% release_static_mt !TEST_PROJECT_NAME! && echo. && echo. && echo.)
   )
 )
 if %DEBUG_STATIC_MD%==1   (%BUILD_TOOL% /useenv /%ACTION% debug_static_md !PROJECT_NAME! && echo. && echo. && echo.
   if "%TESTS%"=="tests" (
     if exist !TEST_PROJECT_NAME! (%BUILD_TOOL% /useenv /%ACTION% debug_static_md !TEST_PROJECT_NAME! && echo. && echo. && echo.)
   )
 )
 if %RELEASE_STATIC_MD%==1 (%BUILD_TOOL% /useenv /%ACTION% release_static_md !PROJECT_NAME! && echo. && echo. && echo.
   if "%TESTS%"=="tests" (
     if exist !TEST_PROJECT_NAME! (%BUILD_TOOL% /useenv /%ACTION% release_static_md !TEST_PROJECT_NAME! && echo. && echo. && echo.)
   )
 )
)

 echo ------------------------------------------------------------------------
 echo ----
 echo ---- Done building %1 [!PROJECT_NAME!]
 echo ----
 echo ------------------------------------------------------------------------
 echo.
 
exit /b

if "%SAMPLES%"=="nosamples" goto :EOF

rem root level component samples
for /f %%G in ('findstr /R "." components') do (
if exist %%G\samples\samples%PLATFORM_SUFFIX%_%VS_VERSION%.sln (
  cd %%G\samples
    echo.
    echo.
    echo ########################################################################
    echo ####
    echo #### Building %%G/samples
    echo ####
    echo ########################################################################
    echo.
  set PROJECT_NAME=samples%PLATFORM_SUFFIX%_%VS_VERSION%
  if %BUILD_TOOL%=="msbuild" (
  if %DEBUG_SHARED%==1      (%BUILD_TOOL% !PROJECT_NAME!.sln /m /p:Configuration=debug_shared /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.)
  if %RELEASE_SHARED%==1    (%BUILD_TOOL% !PROJECT_NAME!.sln /m /p:Configuration=release_shared /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.)
  if %DEBUG_STATIC_MT%==1   (%BUILD_TOOL% !PROJECT_NAME!.sln /m /p:Configuration=debug_static_mt /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.)
  if %RELEASE_STATIC_MT%==1 (%BUILD_TOOL% !PROJECT_NAME!.sln /m /p:Configuration=release_static_mt /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.)
  if %DEBUG_STATIC_MD%==1   (%BUILD_TOOL% !PROJECT_NAME!.sln /m /p:Configuration=debug_static_md /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.)
  if %RELEASE_STATIC_MD%==1 (%BUILD_TOOL% !PROJECT_NAME!.sln /m /p:Configuration=release_static_md /p:Platform=%PLATFORM% /verbosity:minimal /p:VCBuildAdditionalOptions="/useenv" /t:%ACTION% && echo. && echo. && echo.)
  ) else (
  if %DEBUG_SHARED%==1      (%BUILD_TOOL% /useenv /%ACTION% debug_shared !PROJECT_NAME!.sln && echo. && echo. && echo.)
  if %RELEASE_SHARED%==1    (%BUILD_TOOL% /useenv /%ACTION% release_shared !PROJECT_NAME!.sln && echo. && echo. && echo.)
  if %DEBUG_STATIC_MT%==1   (%BUILD_TOOL% /useenv /%ACTION% debug_static_mt !PROJECT_NAME!.sln && echo. && echo. && echo.)
  if %RELEASE_STATIC_MT%==1 (%BUILD_TOOL% /useenv /%ACTION% release_static_mt !PROJECT_NAME!.sln && echo. && echo. && echo.)
  if %DEBUG_STATIC_MD%==1   (%BUILD_TOOL% /useenv /%ACTION% debug_static_md !PROJECT_NAME!.sln && echo. && echo. && echo.)
  if %RELEASE_STATIC_MD%==1 (%BUILD_TOOL% /useenv /%ACTION% release_static_md !PROJECT_NAME!.sln && echo. && echo. && echo.)
  )
  
  cd %POCO_BASE%
)
)

goto :EOF

:usage
echo Usage:
echo ------
echo buildwin DEVENV VS_VERSION [ACTION] [LINKMODE] [CONFIGURATION] [PLATFORM] [SAMPLES] [TESTS]
echo DEVENV:     "devenv|vcexpress|msbuild"
echo VS_VERSION: "71|80|90|100"
echo ACTION:     "build|rebuild|clean"
echo LINKMODE:   "static_mt|static_md|shared|all"
echo CONFIG:     "release|debug|both"
echo PLATFORM:   "Win32|x64|WinCE"
echo SAMPLES:    "samples|nosamples"
echo TESTS:    "tests|notests"

echo.
echo Default is build all.
endlocal