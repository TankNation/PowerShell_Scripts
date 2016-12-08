
#############################################################################################################################################
###~ LAPS - Prompted Permission Assignments #################################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-09-27
#~ Modified: 2016-09-29
#
#~ References:
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
###~ LAPS - Prompted Permission Assignments #################################################################################################
#############################################################################################################################################

#~ Import Modules
Import-Module ActiveDirectory
Import-Module AdmPwd.PS

#~ Assign Variables
$runStart = $True
Do{
    Clear-Host
    #~ Set Variables
    $targetOU = Read-Host "`nEnter Target OU DN"
    $targetGroup = Read-Host "Enter Security Group CN"
    $readPerm = Set-AdmPwdReadPasswordPermission -OrgUnit "$targetOU" -AllowedPrincipals "$targetGroup"
    $resetPerm = Set-AdmPwdResetPasswordPermission -OrgUnit "$targetOU" -AllowedPrincipals "$targetGroup"
    $selfPerm = Set-AdmPwdComputerSelfPermission -OrgUnit "$targetOU"
    $runAgain = $False

	Do{
		Clear-Host
		#~ User Selection for rights needed
		Write-Host "`nSelect Permission to apply:"
		Write-Host "`n1.) Read"
		Write-Host "2.) Reset"
		Write-Host "3.) Self"
		$userSelect = Read-Host "`nEnter 1, 2 or 3 for required permissions"
		#~ Assign Read Permissions
		If ($userSelect -eq '1'){
			$readPerm
			$runAgain = $False
			}
		#~ Assign Reset Permissions
		ElseIf ($userSelect -eq '2'){
			$resetPerm
			$runAgain = $False
			}
		#~ Assign SELF Permissions to OU
		ElseIf ($userSelect -eq '3'){
			$selfPerm
			$runAgain = $False
			}
		#~ Invalid Selection
		Else {
            Write-Host "`nInvalid Selection`n"
			$runAgain = $True
			}
		#~ Prompt for RunAgain (Same Targets)
		$runAgain = Read-Host "`nRun Again? Additional Permissions (Same OU/Group)(Y,N)?"
	}While ($runAgain -eq $True -or $runAgain -eq 'Y')

#~ Display ExtendedRightHolders on Targeted OU
Clear-Host
Write-Host "`nExtended Rights of $targetOU"
Find-AdmPwdExtendedrights -identity "$TargetOU" | Format-List

#~ Prompt for RunStart (New Targets)
$runStart = Read-Host "`nRun Again? From Start (New OU/Group)(Y,N)?"
}While ($runStart -eq 'Y')
Clear-Host

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################

#############################################################################################################################################
###~ TO DO ##################################################################################################################################
#
#~ Work on Dropdown list for OUs to pass selection to targetOU (Work below in before $targetOU declaration)
#~~ $searchOU = 'OU=Clients,DC=sandbox,DC=ets,DC=edu' 
#~~ Get-ADOrganizationalUnit -SearchBase $searchOU -filter * | select -ExpandProperty DistingushedName
#
############################################################################################################################################# 
