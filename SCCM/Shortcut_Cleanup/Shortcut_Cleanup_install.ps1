#############################################################################################################################################
###~ AllUser Desktop Shortcut Cleanup #######################################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-11-23
#~ Modified:
#
#~ References:
#~ http://windowsitpro.com/powershell/q-how-do-i-read-content-file-windows-powershell
#~ https://social.technet.microsoft.com/Forums/scriptcenter/en-US/57550bdc-550d-49a2-9551-ad739b27263b/powershell-yesno-popup?forum=ITCG
#
#############################################################################################################################################

#############################################################################################################################################
###~ Public Folder Shortcuts (.lnk) Prompted Removal ########################################################################################
#############################################################################################################################################

#~ Declare Variables
$tar_Dir = "$env:PUBLIC\Desktop"
$tar_Filter = "*.lnk"
$txt_File = ".\"+(($tar_Dir | Out-String).Trim()).split('\')[1]+'.txt'
$dm_Dir = "Delete_Me"
$dm_File = "Delete_Me.txt"
$dm_Path = "$tar_Dir\$dm_Dir"

#~ Create File for Detection Method
New-Item -ItemType Directory -Path $tar_Dir -Name $dm_Dir -Force | %{$_.Attributes = "hidden"}
New-Item -ItemType File -Path $dm_Path -Name $dm_File -Force

#~ Create List of Shortcuts
Get-ChildItem $tar_Dir -name -Filter $tar_Filter | Out-File $txt_File

#~ Read in, loop and prompt for Removal
$tar_Data = Get-Content $txt_File
write-host $tar_Data.count total lines read from file
$a = new-object -comobject wscript.shell
foreach ($line in $tar_Data)
{
    $intAnswer = $a.popup("Do you wish to delete this shortcut: $line ?", 0, "Delete Shortcut",4)
    If ($intAnswer -eq 6){Remove-Item -Path $tar_Dir\$line -Recurse -Confirm:$false -Force}
}

Remove-Item -Path $txt_File -Recurse -Confirm:$false -Force

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
