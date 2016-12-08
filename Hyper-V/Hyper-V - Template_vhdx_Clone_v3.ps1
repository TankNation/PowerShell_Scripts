#############################################################################################################################################
###~ Hyper-V - VM Clone Template ############################################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-12-05
#~ Modified: 2016-12-05
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
$vhdClone = "Ubuntu_Template_16_12.vhdx"
$vhdName = "$vmName.vhdx"
$vhdPath = "$vmPath\$vmName\Virtual Hard Disks"
$vhdFull = "$vhdPath\$vhdName"

#~ Define System Specs
$vmGen = 1
$vmProc = 2
$memSize = 2GB
$vmBoot = @("IDE","CD","LegacyNetworkAdapter","Floppy")
$vmSwitch = 'External Virtual Switch'
$ssName = "Day0: DND"

#############################################################################################################################################
###~ Create Virtual Machine and Provision Resources #########################################################################################
#############################################################################################################################################

#~ Create New Virtual Machine, attch VHDX assign attributes
Write-Host "`nCreating Virtual Machine: $vmName...`n" -ForegroundColor Black -BackgroundColor Yellow
New-VM -Name $vmName -MemoryStartupBytes $memSize -Generation $vmGen -NoVHD -SwitchName $vmswitch -Path $vmPath
Set-VMProcessor $vmName -Count $vmProc
Set-VMMemory $vmName -DynamicMemoryEnabled $false
Set-VMBios $vmName -StartupOrder $vmBoot

#~ Mount and Clone Source VHDX, then Attach to New VM
Write-Host "Cloning $vhdClone to $vhdFull...`n" -ForegroundColor Black -BackgroundColor Yellow
$vhdCloneMount = Mount-VHD "$vhdClone" -PassThru
New-VHD -Dynamic -Path "$vhdFull" -SourceDisk $vhdCloneMount.DiskNumber
Dismount-VHD $vhdCloneMount.DiskNumber
Add-VMHardDiskDrive $vmName -ControllerType IDE -ControllerNumber 0 –Path "$vhdFull" -Passthru

#~ System Checkpoint
Checkpoint-VM -Name $vmName -SnapshotName $ssName

#~ Start Virtual Machine if uncommented
#Start-VM –Name $vmName

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
