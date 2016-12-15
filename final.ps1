#powershell assignment 
#Lucas Carroll
#200245897
#this is my work


"----------------------------
Operating System Information
----------------------------"


$manufacturer = (Get-WmiObject Win32_OperatingSystem).manufacturer
$caption = (Get-WmiObject Win32_OperatingSystem).Name
$version = (Get-WmiObject Win32_OperatingSystem).version
$architecture = (Get-WmiObject Win32_OperatingSystem).osarchitecture
$registereduser = (Get-WmiObject Win32_OperatingSystem).RegisteredUser
$serialnumber = (Get-WmiObject Win32_OperatingSystem).serialnumber


Write-output "Manufacturer : $manufacturer"
Write-Output "Caption : $caption"
Write-Output "Version : $version"
Write-Output "Architecture : $architecture"
Write-Output "Registered user : $registereduser"
Write-Output "Serial Number : $serialnumber"

“`n”

"-----------------------------
Computer Information
------------------------------"

$cmanufacturer = (Get-WmiObject Win32_computersystem).manufacturer
$cmodel = (Get-WmiObject Win32_computersystem).model
$ccaption = (Get-WmiObject Win32_computersystem).caption
$cdomain = (Get-WmiObject Win32_computersystem).domain
$cprimaryownername = (Get-WmiObject Win32_computersystem).primaryownername
$csystemtype = (Get-WmiObject Win32_computersystem).systemtype


Write-Output "Manufacturer : $cmanufacturer"
Write-Output "Model : $cmodel"
Write-Output "Caption : $ccaption"
Write-Output "Domain : $cdomain"
Write-Output "PrimaryOwnerName : $cprimaryownername"
Write-Output "SystemType : $csystemtype"

“`n”

"------------------------------
BIOS Information
-------------------------------"

$bmanufacturer = (Get-WmiObject Win32_BIOS).manufacturer
$bdescription = (Get-WmiObject Win32_BIOS).description
$bversion=(Get-WmiObject Win32_BIOS).version
$bsmbiosbiosversion = (Get-WmiObject Win32_BIOS).smbiosbiosversion
$bserialnumber = (Get-WmiObject Win32_BIOS).serialnumber

Write-Output "Manufacturer : $bmanufacturer"
Write-Output "Description : $bdescription"
Write-Output "Version : $bversion"
Write-Output "SMBIOSBIOSVersion : $smbiosbiosversion"
Write-Output "SerialNumber : $bserialnumber"

“`n”

"----------------------------
Processor Information
-----------------------------"

$pmanufacturer = (Get-WmiObject Win32_Processor).manufacturer
$pname = (Get-WmiObject Win32_Processor).name
$pcaption = (Get-WmiObject Win32_Processor).caption
$pnumberofcores = (Get-WmiObject Win32_Processor).numberofcores
$pmaxclockspeed = (Get-WmiObject Win32_Processor).maxclockspeed
$pl2cachesize = (Get-WmiObject Win32_Processor).l2cachesize
$pl3cachesize = (Get-WmiObject Win32_Processor).l3cachesize

Write-Output "Manufacturer : $pmanufacturer"
Write-Output "Name : $pname"
Write-Output "Caption : $pcaption"
Write-Output "NumberOfCores : $pnumberofcores"
Write-Output "MaxClockSpeed : $pmaxclockspeed"
Write-Output "L2CacheSize : $pl2cachesize"
Write-Output "L3cacheSize : $pl3cachesize"

“`n”

"----------------------------
Memory Information
-----------------------------"

$totalcapacity = 0
Get-WmiObject -class win32_physicalmemory |
foreach{
New-Object -TypeName psobject -Property @{
Manufacturer = $_.manufacturer
"Speed(Mhz)" = $_.speed
"Size(Mb)" = $_.capacity/1mb
Bank = $_.banklabel
Slot = $_.devicelocator
}

$totalcapacity += $_.capacity/1mb
}|
ft -auto Manufacturer, "Size(mb)", "Speed(Mhz)", Bank,Slot 
"total RAM: ${totalcapacity}Mb "

“`n”

"--------------------------
Network Connections
---------------------------"

Get-WmiObject Win32_NetworkAdapter
? adaptertype -match "ethernet" |
ForEach-Object {
$nac = $_.GetRelated("Win32_NetworkAdapterConfiguration")

New-Object PSObject -Property @{name=$_.name
ipaddress=$nac.ipaddress|where-object {($_ -is [string]) -and ($_.indexof(".") -gt 0)}
ipgateway=$nac.defaultipgateway|where-object {($_ -is [string]) -and ($_.indexof(".") -gt 0)}
macaddress=$nac.macaddress|Where-Object {($_ -is [string]) -and ($_.indexof(":") -gt 0)}
speed=$nac.speed
netmask=$nac.ipsubnet|Where-Object {($_ -is [string]) -and ($_.indexof(".") -gt 0)}
domain=$nac.dnsdomain
hostname=$nac.dnshostname
}
}|
Format-Table name,ipaddress,ipgateway,macaddress,Speed,Netmask,domain,hostname -AutoSize

"---------------------------
Disk Usage
----------------------------"


Get-WmiObject Win32_Volume -Filter "DriveType='3'" |
 ForEach-Object {
            New-Object PSObject -property  @{
                id = $_.Name
                providername = $_.Label
                space = ([Math]::Round($_.FreeSpace /1GB,2))
                size = ([Math]::Round($_.Capacity /1GB,2))
                percentfree = ([Math]::Round($_.Capacity /1GB,2)) - ([Math]::Round($_.FreeSpace /1GB,2))
            }
        }

Format-Table id,size"(GB)",space"(GB)",percentfree,providername -AutoSize

"--------------------------
Configured Printers
---------------------------"

Get-WmiObject -class win32_printer |    select name,     @{n="Default?";e={if($_.attributes -band 4){$attr="default"};$attr}},     @{n="Shared?";e={if($_.attributes -band 8){$attr="shared"};$attr}},     @{n="Status";e={switch($_.printerstatus){1{$stat="other"}                                            2{$stat="unknown"}                                            3{$stat="idle"}                                            4{$stat="printing"}                                            5{$stat="warming up"}                                            6{$stat="stopped printing"}                                            7{$stat="offline"}};                                            $stat}} |    Format-Table -AutoSize


"------------------------
Installed Software
-------------------------"
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
Select-Object InstallDate, Publisher, DisplayName |
Format-Table –AutoSize

#Lucas Carroll
#200245897
#This is My work
