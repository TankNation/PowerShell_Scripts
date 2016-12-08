#############################################################################################################################################
###~ AllUser Desktop Shortcut Cleanup #######################################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-11-23
#~ Modified: 2016-11-28
#
#~ References:
#~ http://windowsitpro.com/powershell/q-how-do-i-read-content-file-windows-powershell
#~ https://social.technet.microsoft.com/Forums/scriptcenter/en-US/57550bdc-550d-49a2-9551-ad739b27263b/powershell-yesno-popup?forum=ITCG
#
#############################################################################################################################################

#############################################################################################################################################
###~ Public Folder Shortcuts (.lnk) No Prompt Removal #######################################################################################
#############################################################################################################################################

#~ Declare Variables
$tar_Dir = "$env:PUBLIC\Desktop"
$tar_Filter = "*.lnk"
$tar_Exclusions = @("*Post*", "*Exclusions*", "*Here*")
$txt_File = ".\"+(($tar_Dir | Out-String).Trim()).split('\')[1]+'.txt'
$dm_Dir = "Delete_Me_Lab"
$dm_File = "Delete_Me_Lab.txt"
$dm_Path = "$tar_Dir\$dm_Dir"
$cur_Loc = Get-Location

#~ Create File for Detection Method
New-Item -ItemType Directory -Path $tar_dir -Name $dm_Dir -Force | %{$_.Attributes = "hidden"}
New-Item -ItemType File -Path $dm_Path -Name $dm_File -Force

#~ Remove Public Shortcuts (outside of defined exclusions)
Set-Location $tar_Dir
Get-ChildItem -Path "$tar_Dir" -name -Filter $tar_Filter -Exclude $tar_Exclusions | Remove-Item -Recurse -Confirm:$false -Force #-WhatIf
Set-Location $cur_Loc

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################