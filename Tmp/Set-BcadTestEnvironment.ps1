
Function Log
{
	param(
            [string] $Str,
            [string] $Color = 'White'
        )


	Write-Host $Str -BackgroundColor Blue -ForegroundColor $Color
}

Clear-Host
Log "=================================================="
Log "Bodycad Test Environment Simulator"
Log "=================================================="
Write-Host

$BasePath = $Env:BcadTestBasePath
if ($Env:BcadTestBasePath -eq '')
{
	Log 'Please provide development BASE PATH'
	$BasePath = Read-Host -Prompt '?'
	Set-Item -Path Env:BcadTestBasePath -Value $BasePath
}
else
{
	$Env:BcadTestBasePath
	Log 'Please confirm development BASE PATH (enter to confirm)'
	$BasePath = Read-Host -Prompt '?'
	if ($BasePath -eq '')
	{
		$BasePath = $Env:BcadTestBasePath
	}

}

Log "Configuration from $BasePath"

$Value="{0}\\external\Qt5124\msvc2015_64\bin;{0}\\external\ceres-solver\install\Release\lib;{0}\\external\quazip\install\Release\lib;{0}\\external\OpenMesh\x64\Release;{0}\\external\gtest\install\Release\lib;{0}\\external\Visualisation\install\Release\bin;{0}\\external\mpir\bin\x64\Release\generic;{0}\\external\Geomagic\x64\Release;{0}\\external\OpenCTM\lib;;C:\Python27;$env:PATH"  -f $BasePath
Set-Item -Path Env:PATH -Value $Value

# DATA_TEST_ROOT
$Value="{0}\\Test\Data" -f $BasePath
Set-Item -Path Env:DATA_TEST_ROOT -Value $Value

$Value="{0}\\x64\Release\Dicom2TestData.exe" -f $BasePath
Set-Item -Path Env:DICOM_VALIDATION_TOOL -Value $Value

$Value="{0}\\Tools\dicom2.exe" -f $BasePath
Set-Item -Path Env:DICOM2 -Value $Value

Set-Item -Path Env:QT_PLUGIN_PATH -Value "."

$Value="{0}\\QmlScripts" -f $BasePath
Set-Item -Path Env:QML_BASE_URL -Value $Value

$Value="{0}\\external\OtherQmlModules;{0}\\QmlScripts\Common;{0}\\QmlScripts\Panthera;{0}\\QmlScripts\Bodycad;{0}\\QmlScripts\Production" -f $BasePath
Set-Item -Path Env:QML2_IMPORT_PATH -Value $Value"{0}\\external\OtherQmlModules;{0}\\QmlScripts\Common;{0}\\QmlScripts\Panthera;{0}\\QmlScripts\Bodycad;{0}\\QmlScripts\Production"

$Value="{0}\\OpenCL" -f $BasePath
Set-Item -Path Env:OPENCL_INCLUDE_PATH -Value $Value

Set-Item -Path Env:QMLSHELL_ROOT -Value $BasePath

$Value="{0}\\ui2d.qml" -f $BasePath
Set-Item -Path Env:QMLSHELL_UI2D_FILE_PATH -Value $Value
Set-Item -Path Env:QMLSHELL_MEMLIMIT_GB -Value "16"
