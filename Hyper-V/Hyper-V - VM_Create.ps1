#############################################################################################################################################
###~ Hyper-V - Create VM Shell ##############################################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-09-27
#~ Modified: 2016-12-08
#
#~ References:
#~ http://www.tenforums.com/tutorials/56837-hyper-v-virtual-machines-default-folder-change-windows-10-a.html#option2
#~ https://msdn.microsoft.com/en-us/virtualization/hyperv_on_windows/quick_start/walkthrough_create_vm
#
#############################################################################################################################################
 
#############################################################################################################################################
###~ Assigning Variables, and Functions #####################################################################################################
#############################################################################################################################################

#~ Import Hyper-V Modules
Import-Module Hyper-V

#~ Define Variables
$user = ([Security.Principal.WindowsIdentity]::GetCurrent()).Name.Replace("$env:UserDomain\","")
$symLink = "VMConnect.lnk"
$symPath = "$env:HomeDrive\users\$user\Desktop"
$symValue = "$env:windir\System32\vmconnect.exe"
$date = get-date -date $(get-date) -format yyyy_MM_dd-HHmmss
$time = $date.substring($date.length - 6, 6)
$proActive = Get-Process "mmc" -ErrorAction SilentlyContinue
$proValue = "$env:windir\System32\virtmgmt.msc"

#~ Define System Specs
#$vmGen = Read-Host -Prompt "Enter Desired VM Generation (1,2)" #Replaced with Function vmGenPrompt
$vmProc = 2
$memSize = 2GB
$vhdSize = 25GB
$switch = 'External Virtual Switch'
$vmName = "$user-VM-$time"
$vmPath = "$env:HomeDrive\Hyper-V"
$vhdPath = "$vmPath\$vmName\Virtual Hard Disks\$vmName.vhdx"
$vhdPath2 = "$vmPath\$vmName\Virtual Hard Disks\$vmName-Dif.vhdx"
$isoName = "ubuntu-16.04.1-desktop-amd64.iso"
$isoPath = "$vmPath\zz_ISOs"
$isoFull = "$isoPath\$isoName"
$ssName = "Day0: DND"

#############################################################################################################################################
###~ Assigning Functions ####################################################################################################################
#############################################################################################################################################

function stagePaths{
    New-Item -ItemType directory -Path $isoPath -Force
    New-Item -ItemType SymbolicLink -Path $symPath -Name $symLink -Value $symValue -Force
}

function openMMC{
    If ($proActive -eq $null){[System.Diagnostics.Process]::Start($proValue)}
}

function copyISO{
    If (Test-Path "$isoFull"){Write-Host "`nISO Media exists: $isoFull"}
    Else {
        Copy-Item "$isoName" "$isoPath" #Move-Item is cleaner but breaks re-run via SCCM
        Write-Host "`nISO Media now exists: $isoFull"
    }
}

function vmGenPrompt{
    Clear-Host
    Write-Host "`nCreating Virtual Machine...`n" -ForegroundColor Black -BackgroundColor Yellow
    Do{
        Write-Host "Enter Desired Virtual Machine Generation " -BackgroundColor Black -ForegroundColor White -NoNewline
        Write-Host "(1,2)" -BackgroundColor Black -ForegroundColor Yellow -NoNewline
        Write-Host ": " -BackgroundColor Black -ForegroundColor White -NoNewline
        $vmGen = Read-Host
        If ($vmGen -eq '1' -or $vmGen -eq '2'){$vmGenData = $true}
        Else {
            Clear-Host
            $vmGenData = $false
            Write-Host "`nInvalid Selection" -ForegroundColor Yellow -BackgroundColor Red
        }
    }While ($vmGenData -ne $true)
}

function vmCreate{
    New-VM -Name $vmName -MemoryStartupBytes $memSize -Generation $vmGen -NewVHDPath $vhdPath -NewVHDSizeBytes $vhdSize -Path $vmPath -SwitchName $switch
    Set-VMProcessor $vmName -Count $vmProc
    Set-VMMemory $vmName -DynamicMemoryEnabled $false
}

function vmBootOrder{
   
    function vmBoot1{
        $vmBoot1 = @("CD","IDE","LegacyNetworkAdapter","Floppy")
        Set-VMDvdDrive -VMName $vmName -Path $isoFull
        Set-VMBios $vmName -StartupOrder $vmBoot1
    }#~ Gen1 Boot Order

    function vmBoot2{
        Add-VMDvdDrive -VMName $vmName -ControllerNumber 0 -ControllerLocation 1 -Path $isoFull
        $vmDVD = Get-VMDvdDrive -VMName $vmName
        $vmHDD = Get-VMHardDiskDrive -VMName $vmName
        $vmNet = Get-VMNetworkAdapter -VMName $vmName
        $vmBoot2 = @($vmDVD,$vmHDD,$vmNet)
        If ($isoName -like "*ubuntu*"){Set-VMFirmware $vmName -EnableSecureBoot Off -BootOrder $vmBoot2}
        If ($isoName -notlike "*ubuntu*"){Set-VMFirmware $vmName -EnableSecureBoot Off -BootOrder $vmBoot2}
    }#~ Gen2 Boot Order

    If ($vmGen -eq 1){vmBoot1}
    If ($vmGen -eq 2){vmBoot2}

}

function vmSnapshot{
    
    function vmDiff{
        New-VHD –Path “$vhdPath2” –ParentPath “$vhdPath” –Differencing
        If ($vmGen -eq 2){
            Add-VMScsiController -VMName $vmName
            Add-VMHardDiskDrive -VMName $vmName -Path $vhdPath2 -ControllerNumber 1 -ControllerLocation 0 -ControllerType SCSI
        }
        If ($vmGen -eq 1){
            Add-VMHardDiskDrive -VMName $vmName -Path $vhdPath2 -ControllerNumber 0 -ControllerLocation 0 -ControllerType SCSI
        }
    }
                    
    Checkpoint-VM -Name $vmName -SnapshotName $ssName
#    vmDiff

}

function vmOpen{
    vmconnect localhost $VMname
#    Start-VM –Name $vmName
}

function opComplete{
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("Operation Completed",0,"Done",0x1)
}

#############################################################################################################################################
###~ Prepare Directories, Files, and open Hyper-V MMC #######################################################################################
#############################################################################################################################################

#~ Create ISO Path and Shortcuts
stagePaths

#~ Open Hyper-V Manager
openMMC

#~ Copy ISO to $isoPath
copyISO

#############################################################################################################################################
###~ Create Virtual Machine and Provision Resources #########################################################################################
#############################################################################################################################################

#~ Create New Virtual Machine, assign attributes and attach devices
vmGenPrompt
vmCreate

#~ Mount Installation Media and Configure Virtual Machine to Boot CD\DVD
vmBootOrder

#~ Snapshot VM #Create and add Differncing Disk if uncommented from function
vmSnapshot

#~ Open Console of created VM and start if uncommented from function
vmOpen

#~ Display "Completed"
opComplete

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
