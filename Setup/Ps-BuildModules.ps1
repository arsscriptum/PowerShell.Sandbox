Install-Module VSSetup -Scope CurrentUser -Force

 Install-Module BuildUtils -Scope CurrentUser -Force
  Install-PackageProvider -Name NuGet -Force

function Get-LatestMsbuildLocation
{
  Param 
  (
    [bool] $allowPreviewVersions = $false
  )
    if ($allowPreviewVersions) {
      $latestVsInstallationInfo = Get-VSSetupInstance -All -Prerelease | Sort-Object -Property InstallationVersion -Descending | Select-Object -First 1
    } else {
      $latestVsInstallationInfo = Get-VSSetupInstance -All | Sort-Object -Property InstallationVersion -Descending | Select-Object -First 1
    }
    Write-Host "Latest version installed is $($latestVsInstallationInfo.InstallationVersion)"
    if ($latestVsInstallationInfo.InstallationVersion -like "15.*") {
      $msbuildLocation = "$($latestVsInstallationInfo.InstallationPath)\MSBuild\15.0\Bin\msbuild.exe"
    
      Write-Host "Located msbuild for Visual Studio 2017 in $msbuildLocation"
    } else {
      $msbuildLocation = "$($latestVsInstallationInfo.InstallationPath)\MSBuild\Current\Bin\msbuild.exe"
      Write-Host "Located msbuild in $msbuildLocation"
    }

    return $msbuildLocation
}

Install-Module -Name Invoke-MsBuild -RequiredVersion 2.6.2