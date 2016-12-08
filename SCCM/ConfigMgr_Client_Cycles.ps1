#############################################################################################################################################
###~ Configuration Manager - Client Scan Triggers ###########################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-11-10
#~ Modified: 2016-11-10
#
#~ References:
#~ https://www.systemcenterdudes.com/configuration-manager-2012-client-command-list/
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
###~ Configuration Manager Client Scan Cycles ###############################################################################################
#############################################################################################################################################

$Server = $env:COMPUTERNAME

#~ Application Deployment Evaluation Cycle
Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000121}"
#~ Discovery Data Collection Cycle
#Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000003}"
#~ File Collection Cycle
#Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000010}"
#~ Hardware Inventory Cycle
#Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000001}"
#~ Machine Policy Retrieval Cycle
Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"
#~ Machine Policy Evaluation Cycle
Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000022}"
#~ Software Inventory Cycle
#Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000002}"
#~ Software Metering Usage Report Cycle
#Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000031}"
#~ Software Update Deployment Evaluation Cycle
#Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000114}"
#~ Software Update Scan Cycle
#Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000113}"
#~ State Message Refresh
#Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000111}"
#~ User Policy Retrieval Cycle
#Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000026}"
#~ User Policy Evaluation Cycle
#Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000027}"
#~ Windows Installers Source List Update Cycle
#Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000032}"

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
