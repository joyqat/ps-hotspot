$SSID = "ssid";
$PASSWORD = "password";
$TRYUSE5GHZ = $true;

# check administrator privilege 
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}

# check netloop is installed
$loopAdapterName = (Get-NetAdapter | Where-Object -Property DriverDescription -Match "KM-TEST").Name;

if (!$loopAdapterName) {
    # configure a netloop.inf device
    Write-Output "No loop adapter found, try to install one...";
    Switch ([intptr]::Size) {
        8 {.\devcon install $env:windir\inf\netloop.inf "*msloop";}
        4 {.\devcon32 install $env:windir\inf\netloop.inf "*msloop";}
    }
    
    $loopAdapterName = (Get-NetAdapter | Where-Object -Property DriverDescription -Match "KM-TEST").Name;
    if (!$loopAdapterName) {
        Write-Output "Install loop adapter failed, exiting...";
        exit;
    }
}

Write-Output "Name of loop adapter: $loopAdapterName";
Write-Output "";

# https://superuser.com/questions/1341997/using-a-uwp-api-namespace-in-powershell
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
Function Await($WinRtTask, $ResultType) {
    $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
    $netTask = $asTask.Invoke($null, @($WinRtTask))
    $netTask.Wait(-1) | Out-Null
    $netTask.Result
}
Function AwaitAction($WinRtAction) {
    $asTask = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and !$_.IsGenericMethod })[0]
    $netTask = $asTask.Invoke($null, @($WinRtAction))
    $netTask.Wait(-1) | Out-Null
}

$loopProfile = [Windows.Networking.Connectivity.NetworkInformation,Windows.Networking.Connectivity,ContentType=WindowsRuntime]::GetConnectionProfiles() | where-object -Property ProfileName -Match $loopAdapterName;
$tetheringManager = [Windows.Networking.NetworkOperators.NetworkOperatorTetheringManager,Windows.Networking.NetworkOperators,ContentType=WindowsRuntime]::CreateFromConnectionProfile($loopProfile);

Write-Output "Configuring Wifi hotspot...";
$tetherConfig = $tetheringManager.GetCurrentAccessPointConfiguration();
if ($TRYUSE5GHZ -and $tetherConfig.IsBandSupported(2)) {
    # if 5GHz supported, set to 5GHz
    $tetherConfig.band = 2;
    Write-Output "Band: 5GHz";
} else {
    Write-Output "Band: 2.4GHz";
}
$tetherConfig.Ssid = $SSID;
Write-Output "SSID: $SSID";
$tetherConfig.Passphrase = $PASSWORD;
Write-Output "Password: $PASSWORD";
AwaitAction ($tetheringManager.ConfigureAccessPointAsync($tetherConfig));
Write-Output "Done";
Write-Output "";

Write-Output "Starting hotspot...";
Await ($tetheringManager.StartTetheringAsync()) ([Windows.Networking.NetworkOperators.NetworkOperatorTetheringOperationResult]) | Out-Null;
Write-Output "Done";
Write-Output "";

$hotspotAdapterId = (Get-NetAdapter | Where-Object -Property DriverDescription -Match "Wi-Fi Direct").InterfaceIndex;
$hotspotIPv4 = (Get-NetIPAddress -InterfaceIndex $hotspotAdapterId).IPv4Address;
$hotspotIPv6 = (Get-NetIPAddress -InterfaceIndex $hotspotAdapterId).IPv6Address;
Write-Output "AP IPv4: $hotspotIPv4";
Write-Output "AP IPv6: $hotspotIPv6";
Write-Output "";

Write-Output "Press any key to exit.";
[Console]::ReadKey();
