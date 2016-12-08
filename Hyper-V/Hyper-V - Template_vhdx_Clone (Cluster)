#############################################################################################################################################
###~ Hyper-V - VM Clone Template ############################################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-11-03
#~ Modified: 2016-11-28
#
#~ References:
#~ Get-Help
#~ https://blogs.msdn.microsoft.com/virtual_pc_guy/2010/09/23/a-self-elevating-powershell-script/  (First Section of code -Ben Armstrong)
#
#############################################################################################################################################

#############################################################################################################################################
###~ Verifying Script is being run under an Elevated syntax #################################################################################
#############################################################################################################################################

#~ Get the ID and security principal of the current user account and Administrator role
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

#~ Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   #~ We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
else
   {
   #~ We are not running "as Administrator" - so relaunch as administrator
   #~ Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   #~ Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   #~ Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   #~ Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   #~ Exit from the current, unelevated, process
   exit
   }
 
#############################################################################################################################################
###~ Assigning Variables, and System Specifications #########################################################################################
#############################################################################################################################################

#~ Import Hyper-V Modules
Import-Module Hyper-V

#~ Define Variables
$cluStorage = "$env:HomeDrive\ClusterStorage"
$volNum = "Volume5"
$vhdSrcPath = "$cluStorage\ISOs\Images"
$vhdSrcName = "Ubuntu_Image.vhdx"

#~ Define System Specs
Write-Host "`nCreating Virtual Machine..." -ForegroundColor Black -BackgroundColor Yellow
Write-Host "`nEnter Desired Virtual Machine Name: " -BackgroundColor Black -ForegroundColor White -NoNewline
$vmName = Read-Host
$vmGen = 1
$vmProc = 2
$memSize = 2GB
$vmBoot = @("IDE","CD","LegacyNetworkAdapter","Floppy")
$vmSwitch = 'External Virtual Switch'
$vmPath = "$cluStorage\$volNum"
$vhdDst = "$vmPath\$vmName\Virtual Hard Disks\$vmName.vhdx"
$vhdSrc = "$vhdSrcPath\$vhdSrcName"

#~ Open Hyper-V Manager
$proActive = Get-Process "mmc" -ErrorAction SilentlyContinue
if($proActive -eq $null)
{
[System.Diagnostics.Process]::Start("$env:windir\System32\virtmgmt.msc")
}

#############################################################################################################################################
###~ Create Virtual Machine and Provision Resources #########################################################################################
#############################################################################################################################################

#~ Create New Virtual Machine, assign attributes
Write-Host "Creating Virtual Machine: $vmName...`n" -ForegroundColor Black -BackgroundColor Yellow
New-VM -Name $vmName -MemoryStartupBytes $memSize -Generation $vmGen -NoVHD -SwitchName $vmswitch -Path $vmPath
Set-VMProcessor $vmName -Count $vmProc
Set-VMMemory $vmName -DynamicMemoryEnabled $false
Set-VMBios $vmName -StartupOrder $vmBoot

#~ Mount and Clone Source VHD and Attach to New VM
Write-Host "Cloning $vhdSrc to $vhdDst...`n" -ForegroundColor Black -BackgroundColor Yellow
$vhdSrcMount = Mount-VHD "$vhdSrc" -PassThru
New-VHD -Dynamic -Path "$vhdDst" -SourceDisk $vhdSrcMount.DiskNumber
Dismount-VHD $vhdSrcMount.DiskNumber
Add-VMHardDiskDrive $vmName -ControllerType IDE -ControllerNumber 0 –Path "$vhdDst" -Passthru

#~ Add new VM as Clustered Role
Add-ClusterVirtualMachineRole -VirtualMachine $vmName -Name "$vmName" 

#~ Open Console of created VM and start if uncommented
vmconnect localhost $vmName
#Start-VM –Name $vmName

#~ Complete Display
$wshell = New-Object -ComObject Wscript.Shell
$wshell.Popup("Operation Completed",0,"Done",0x1)

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
