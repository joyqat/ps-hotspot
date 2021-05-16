# check administrator privilege 
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}

# check netloop is installed
$loopAdapterName = (Get-NetAdapter | Where-Object -Property DriverDescription -Match "KM-TEST").Name;
$loopProfile = [Windows.Networking.Connectivity.NetworkInformation,Windows.Networking.Connectivity,ContentType=WindowsRuntime]::GetConnectionProfiles() | where-object -Property ProfileName -Match $loopAdapterName;
$tetheringManager = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager,Windows.Networking.NetworkOperators,ContentType=WindowsRuntime]::CreateFromConnectionProfile($loopProfile);

Write-Output "Stoping hotspot...";
if ($tetheringManager.TetheringOperationalState -eq 1) {
    $tetheringManager.StopTetheringAsync() | Out-Null;
    Start-Sleep(1);
}
Write-Output "Done";
Write-Output "";

Write-Output "Press any key to exit.";
[Console]::ReadKey();
