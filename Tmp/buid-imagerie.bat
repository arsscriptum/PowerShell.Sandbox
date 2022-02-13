@echo off



set BASEPATH="C:\Jenkins\workspace\CAD_CPP\CAD_CPP_Packaging"
set OUTPATH=="C:\Jenkins\workspace\CAD_CPP\CAD_CPP_Packaging\x64"
pushd %BASEPATH%

hg clone --rev Imaging-default --noupdate https://scmmanager.bodycad.com/hg/Bodycad/ %BASEPATH%
hg update --rev Imaging-default
hg tag --local Segmentor-1.0.0.0
popd

set SHELLSCRIPTS="C:\Jenkins\workspace\CAD_CPP\CAD_CPP_Packaging\ShellScripts"
pushd %SHELLSCRIPTS%

Package.bat Release
Package.bat Retail

popd

set SHAREDFOLDER="E:\Share\Public\Imagerie"

if not exist %SHAREDFOLDER%(
  mkdir %SHAREDFOLDER%
)

xcopy /e %OUTPATH% %SHAREDFOLDER%