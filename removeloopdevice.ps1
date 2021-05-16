# check administrator privilege 
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}

Switch ([intptr]::Size) {
    8 {.\devcon remove "*msloop";}
    4 {.\devcon32 remove "*msloop";}
}


Write-Output "Press any key to exit.";
[Console]::ReadKey();
