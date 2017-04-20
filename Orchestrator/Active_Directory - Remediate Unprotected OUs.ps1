#############################################################################################################################################
###~ Remediate - Unprotected Organizatial Units in Active Directory #########################################################################
#
#~ Brian Tancredi
#~ Created: 2017-04-07
#~ Modified: 2017-04-07
#
#~ References:
#~ https://
#
#############################################################################################################################################

#############################################################################################################################################
###~ Assigning Variables  ###################################################################################################################
#############################################################################################################################################

Import-Module ActiveDirectory

#~ Unprotected OUs
$unprotected_OUs = Get-ADOrganizationalUnit -filter * -Properties ProtectedFromAccidentalDeletion | where {$_.ProtectedFromAccidentalDeletion -eq $false}

#~ Report of Unprotected OUs (to Publish)
$report_Before =  $unprotected_OUs | Sort $_.Name | Select-Object @{Name="OU Name";Expression={$_.Name}},@{Name="OU DN";Expression={$_.DistinguishedName}},@{Name="OU Protected";Expression={$_.ProtectedFromAccidentalDeletion}} | FL | Out-String

#~ Counters (to Publish)
$x_Count = ($unprotected_OUs.ProtectedFromAccidentalDeletion -eq $false).Count
$s_Count = 0
$e_Count = 0

#~ Build Credentials
$username = "*****"
$secpasswd = ConvertTo-SecureString "*****" -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username,$secpasswd

#############################################################################################################################################
###~ Remediation: Protect and log each unprotected OU #######################################################################################
#############################################################################################################################################

#~ String equals Report
$string = Write-Output "The following OU's have been modified and are now protected from accidental deletion.`n" | Out-String

#~ Loop through each OU and set flag to True. Log work done to String.
$ErrorActionPreference = "Stop"
ForEach($OU in $unprotected_OUs){
    $dN = $OU.DistinguishedName
    Try{
        $OU | Set-ADObject -ProtectedFromAccidentalDeletion $true
        $string += Write-Output "Successfully protected: $dN" | Out-String
        $s_Count++
    }
    Catch [Microsoft.ActiveDirectory.Management.ADException]{
        $string += Write-Output "Error: $($error[0])" | Out-String
        $e_Count++
    }
    Catch{
        $string += Write-Output "Error: Unable to protect $dN" | Out-String
        $e_Count++
    }
}

#~ Report Variable (to Publish)
$report_After = $string
Remove-Variable string

#~ Determine if email needs to be sent (to Publish)
if($s_Count -gt 0 -or $e_Count -gt 0){$to_Report = $true}
else{$to_Report = $false}

#~ Count Unprotected OUs at End (to Publish)
$unprotected_OUs_End = Get-ADOrganizationalUnit -filter * -Properties ProtectedFromAccidentalDeletion | where {$_.ProtectedFromAccidentalDeletion -eq $false}
$y_Count = ($unprotected_OUs_End.ProtectedFromAccidentalDeletion -eq $false).Count

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################


#$Error[0].Exception.GetType().fullname