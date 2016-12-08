#############################################################################################################################################
###~ AllUser Desktop Shortcut Cleanup #######################################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-11-23
#~ Modified: 2016-12-08
#
#~ References:
#~ http://windowsitpro.com/powershell/q-how-do-i-read-content-file-windows-powershell
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
If ($myWindowsPrincipal.IsInRole($adminRole)){
   #~ We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   Clear-Host
   }
Else {
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
   Exit
   }

#############################################################################################################################################
###~ Public Folder Shortcuts (.lnk) Prompted Removal ########################################################################################
#############################################################################################################################################

#~ Declare Variables
$tar_Dir = "$env:PUBLIC\Desktop"
$tar_filter = "*.lnk"
$txt_File = ".\"+(($tar_dir | Out-String).Trim()).split('\')[1]+'.txt'

#~ Create List of Shortcuts
get-childitem $tar_Dir -name -Filter $tar_filter | Out-File $txt_File

#~ Read in, loop and prompt for Removal
$tar_data = Get-Content $txt_File
write-host $tar_data.count total lines read from file
$a = new-object -comobject wscript.shell
foreach ($line in $tar_data)
{
    $intAnswer = $a.popup("Do you wish to delete this shortcut: $line ?", 0, "Delete Shortcut",4)
If ($intAnswer -eq 6) 
    {
    Remove-Item -Path $tar_dir\$line -Recurse -Confirm:$false -Force #-WhatIf
    }
}
Remove-Item -Path $txt_File -Recurse -Confirm:$false -Force

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
