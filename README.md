# PowerShell Script to Start/Stop Native Wi-Fi Hotspot on Windows 10
Start a Wi-Fi hotspot even if there is NO INTERNET CONNECTION!

Usage:

Edit SSID(Wi-Fi hotspot name), PASSWORD(Wi-Fi hotspot password), TRYUSE5GHZ(whether to try to use 5GHz band) in starthotspot.ps1.

Double click starthotspot.bat to enable hotspot.

Double click stophotspot.bat to disable hotspot.

Double click removeloopdevice.bat to remove additional loop device this script installed when not used.

# PowerShell脚本启动/停止Windows10原生Wi-Fi热点
没有网络也可以开启热点！

使用方法：

首先编辑starthotspot.ps1，将SSID(Wi-Fi热点名称)、PASSWORD(Wi-Fi热点密码)、TRYUSE5GHZ(是否尝试使用5GHz)修改为需要的值。

双击starthotspot.bat启动热点。

双击stophotspot.bat停止热点。

不需要使用时，双击removeloopdevice.bat删除此前安装的loop设备。

Thank Ben N's method to use async api in powershell, https://superuser.com/questions/1341997/using-a-uwp-api-namespace-in-powershell.
