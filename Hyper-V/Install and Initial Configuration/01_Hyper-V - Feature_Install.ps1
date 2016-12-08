#############################################################################################################################################
###~ Hyper-V - Feature Install ##############################################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-09-27
#~ Modified: 2016-11-09
#
#~ References:
#~ https://technet.microsoft.com/en-us/library/hh846766.aspx
#
#############################################################################################################################################

#############################################################################################################################################
###~ Installing Hyper-V Role and Features ###################################################################################################
#############################################################################################################################################

#~ Add user as local Hyper-V Administrator
$userWinNT = ((wmic computersystem get username /format:list | Out-String).Trim()).split('=')[1].split(' ') -replace "\W", '/'
([adsi]”WinNT://./Hyper-V Administrators,group”).Add(“WinNT://$userWinNT,user”)

#~ Add and Install All Hyper-V Features on Client OS
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

#~ Add and Install Some But not All Hyper-V Features on Client OS
#Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V,Microsoft-Hyper-V-Tools-All -All -NoRestart;Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Services -NoRestart

#~ RESTART NEEDED TO PROCEED WITH .\02_HyperV_Initial_Config.ps1

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################