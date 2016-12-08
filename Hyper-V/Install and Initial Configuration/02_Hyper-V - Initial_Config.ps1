#############################################################################################################################################
###~ Hyper-V - Initial Configurations #######################################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-09-27
#~ Modified: 2016-11-07
#
#~ References:
#~ https://blogs.technet.microsoft.com/heyscriptingguy/2013/10/09/use-powershell-to-create-virtual-switches/
#
#############################################################################################################################################

#############################################################################################################################################
###~ Assigning Variables  ###################################################################################################################
#############################################################################################################################################

#~ Import Hyper-V Module
Import-Module Hyper-V

#~ Define Variables
$exNet = Get-NetAdapter -Name 'Ethernet'
$def_vmPath = "$env:SystemDrive\Hyper-V\Virtual Machines"
$def_vdPath = "$env:SystemDrive\Hyper-V\Virtual Hard Disks"

#############################################################################################################################################
###~ Configure Hyper-V Settings #############################################################################################################
#############################################################################################################################################

#~ Get local adapter name and create Virtual Switch Types within Hyper-V 
New-VMSwitch -Name "External Virtual Switch" -AllowManagementOS $True -NetAdapterName $exNet.Name -Notes 'WAN - Access to the Internet'
New-VMSwitch -Name "Private Virtual Switch" -SwitchType Private -Notes ‘Private Network - Internal VMs Only’
New-VMSwitch -Name "Internal Virtual Switch" -SwitchType Internal -Notes ‘Internal Network - Host OS and Internal VMs Only’

#~ Adjust VM and VHD Default Folders
Set-VMHost -VirtualMachinePath $def_vmPath
Set-VMHost -VirtualHardDiskPath $def_vdPath

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
