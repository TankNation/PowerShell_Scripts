#############################################################################################################################################
###~ Administrator Compliance Check - Not for Baseline Script but visual representation #####################################################
#
#~ Brian Tancredi
#~ Created: 2017-01-09
#~ Modified: 2017-01-09
#
#~ References:
#~ https://kareembehery.wordpress.com/2016/04/04/dcm-in-sccm-2012-members-in-local-admin-group-compliance/
#
#############################################################################################################################################

#############################################################################################################################################
###~ Assigning Variables and Functions ######################################################################################################
#############################################################################################################################################
 
$useraffinity = gwmi -Namespace root\ccm\policy\machine -Class ccm_useraffinity
$local_Admins = net localgroup administrators | where {$_ -AND $_ -notmatch “command completed successfully”} | select -skip 4
$ok_Admins = @(
"administrator",
”domain\Domain Admins”
)#~ Acceptable Administrators
$adminusers = $true

function NonCompliant_No_Admin{
    $present = 0
    Write-Host "`nChecking presence of Compliant Administrators on $env:COMPUTERNAME ...." -ForegroundColor White -BackgroundColor Black
    foreach ($admin in $ok_Admins){
        If (($local_Admins -contains $admin)){
            Write-Host "Account present: $admin" -ForegroundColor Green
            $present = $present + 1
        }
        Else{
            Write-Host "Account absent: $admin" -ForegroundColor Yellow         
        }
    }
    If ($present -ge 1){
        Write-Host "`nTotal of approved Administrator accounts present: $present`n" -ForegroundColor Green -BackgroundColor Black
    }
    Else{
        $Script:adminusers = $false
        Write-Host "`nNo approved Administrator accounts are present`n" -ForegroundColor Red -BackgroundColor Black
    }
}#~ Function checks the Administrator Group contains an approved member

function NonCompliant_Extra_Admin{
    $extra = 0
    Write-Host "`nChecking current Administrator accounts on $env:COMPUTERNAME ...." -ForegroundColor White -BackgroundColor Black
    foreach ($admin in $local_Admins){
        If (!($ok_Admins -contains $admin)){
            Write-Host "Unapproved: $admin" -ForegroundColor Red
            $extra = $extra + 1
        }
        Else{
            Write-Host "Approved: $admin" -ForegroundColor Green
        }
    }
    If ($extra -ge 1){
        $Script:adminusers = $false
        Write-Host "`nTotal of non-approved Administrator accounts present: $extra`n" -ForegroundColor Red -BackgroundColor Black
    }
    Else{
        Write-Host "`nAll present Administrator accounts are approved`n" -ForegroundColor Green -BackgroundColor Black
    }
}#~ Function compares the Administrator Group to array of compliant Administrators

function Compliance{
    If ($adminusers -eq $false){
        write-host "$env:COMPUTERNAME is Non-Compliant" -ForegroundColor Yellow
    }
    Else{
        write-host "$env:COMPUTERNAME is Compliant" -ForegroundColor Green
    }
}#~ Function displays Workstation Compliance

#############################################################################################################################################
###~ Run Checks against approved local Administrator list and current local Administrators to determine compliance ##########################
#############################################################################################################################################

#foreach ($useraff in $useraffinity){$ok_Admins += $useraff.ConsoleUser}

New-Object PSObject -Property @{
    Computername = $env:COMPUTERNAME
    Group = “Administrators”
    Members = $local_Admins
} | out-null

#~ Checking that the Administrator Group contains an approved member
NonCompliant_No_Admin
#~ Comparing the Administrator Group against compliant Administrators
NonCompliant_Extra_Admin
#~ Display workstation compliance
Compliance

PAUSE
#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
