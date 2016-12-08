#############################################################################################################################################
###~ Hyper-V - VM Attach Template ###########################################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-12-05
#~ Modified: 2016-12-06
#
#~ References:
#~ Get-Help
#
#############################################################################################################################################

#############################################################################################################################################
###~ Assigning Variables, and System Specifications #########################################################################################
#############################################################################################################################################

#~ Import Hyper-V Modules
Import-Module Hyper-V

#~ Define Variables
$date = get-date -date $(get-date) -format yyyy_MM_dd-HHmmss
$time = $date.substring($date.length - 6, 6)
$proActive = Get-Process "mmc" -ErrorAction SilentlyContinue
$user = ([Security.Principal.WindowsIdentity]::GetCurrent()).Name.Replace("$env:UserDomain\","")
$vmName = "$user-template-$time"
$vmPath = "$env:HomeDrive\Hyper-V"
$vhdTemp = "Ubuntu_Template_16_12.vhdx"
$vhdName = "$vmName.vhdx"
$vhdPath = "$vmPath\$vmName\Virtual Hard Disks"
$vhdFull = "$vhdPath\$vhdName"

#~ Define VM Specs
$vmGen = 1
$vmProc = 2
$memSize = 2GB
$vmBoot = @("IDE","CD","LegacyNetworkAdapter","Floppy")
$vmSwitch = 'External Virtual Switch'
$ssName = "Day0: DND"

New-Item -ItemType Directory -Path $vhdPath -Force

#~ Copy VHDX to $vhdPath
If (Test-Path "$vhdFull"){
    Write-Host "`nTemplate Disk exists: " -ForegroundColor White -BackgroundColor Black -NoNewline
    Write-Host "$vhdFull" -ForegroundColor Green -BackgroundColor Black
}
Else {
    Write-Host "`nCopying Template Disk as: " -ForegroundColor White -BackgroundColor Black -NoNewline
    Write-Host "$vhdName" -ForegroundColor Green -BackgroundColor Black
    Copy-Item ".\$vhdTemp" "$vhdFull"
    Write-Host "`nTemplate Disk now exists: " -ForegroundColor White -BackgroundColor Black -NoNewline
    Write-Host "$vhdFull" -ForegroundColor Green -BackgroundColor Black
}

#############################################################################################################################################
###~ Create Virtual Machine and Provision Resources #########################################################################################
#############################################################################################################################################

#~ Create New Virtual Machine, assign attributes
Write-Host "`nCreating Virtual Machine: "-ForegroundColor White -BackgroundColor Black -NoNewline
Write-Host "$vmName ...`n" -ForegroundColor Green -BackgroundColor Black

New-VM -Name $vmName -MemoryStartupBytes $memSize -Generation $vmGen -vhdPath $vhdFull -SwitchName $vmswitch -Path $vmPath
Set-VMProcessor $vmName -Count $vmProc
Set-VMMemory $vmName -DynamicMemoryEnabled $false
Set-VMBios $vmName -StartupOrder $vmBoot
Checkpoint-VM -Name $vmName -SnapshotName $ssName

#~ Start VM if uncommented
#Start-VM –Name $vmName

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
