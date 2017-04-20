############################################################################
###~ Remediation For Missing Available Deployment Type Information
#~ Brian Tancredi
#~ Created: 2017-04-18
#~ Modified: 2017-04-19
#
#~ References:
#~ http://www.mssccmfaq.de/2013/03/15/fehlende-applications-im-software-center/
#~ https://social.technet.microsoft.com/Forums/en-US/e0bd29ad-adf5-4c33-a2f2-740df8cc6c32/applications-not-visible-in-software-center?forum=configmanagerapps
#
############################################################################

############################################################################
###~ Assign Variables and Declaring Functions
############################################################################

$ErrorActionPreference = "Stop"
[int]$count_MissingDTs = 0
$CIID_RegEx = "<ID>(.*?)<\/ID>"
$missing_Ids = @()

############################################################################
###~ Remediate Missing Available Deployment Type Information
############################################################################

Try{
    #~ Get List of Available Applications
    $applications = Get-WmiObject -namespace root\ccm\clientsdk -query "select * from ccm_application"
    
    #~ Total # of Applications Available
    $apps_Total = $Applications.Length
    
    #~ Check .__Path of each application to determine Missing Deployment Type
    ForEach($app in $applications){
        $app_DT = [wmi] $app.__Path

        If($app_DT.AppDTs.Name.Length -eq 0){
            #Write-Host $($app.Id)
            $missing_Ids += $app.Id
            $count_MissingDTs++
        }
    }
    
    #~ Remediate Missing Deployment Type if $count_MissingDTs > 0
    #Write-Host $count_MissingDTs
    If($count_MissingDTs -gt 0){
        ForEach($app_Id in $missing_Ids){
            $assignments = Get-WmiObject -query "select AssignmentName, AssignmentId, AssignedCIs from CCM_ApplicationCIAssignment" -namespace "ROOT\ccm\policy\Machine"
            
            If($assignments -ne $null){
                ForEach($assignment in $assignments){
                    $assigned_CI = ($assignment).AssignedCIs[0]
                    $assigned_CI_ID = [regex]::match($assigned_CI,$CIID_RegEx).Groups[1].Value
                    
                    #Write-Host "Processing Assignment $($assignment.AssignmentName) $($assignment.AssignmentId) $($assigned_CI_ID)"
                    $assigned_CI_Split = $assigned_CI_ID.Split("/")
                    #Write-Host $($assigned_CI_Split[0]+"/"+$assigned_CI_Split[1].replace("RequiredApplication", "Application"))
                    
                    If($($assigned_CI_Split[0]+"/"+$assigned_CI_Split[1].replace("RequiredApplication", "Application")) -eq $app_Id) {
                        #Write-Host "Processing Assignment $($assignment.AssignmentName) $($assignment.AssignmentId)"
                        $sched = ([wmi]"root\ccm\Policy\machine\ActualConfig:CCM_Scheduler_ScheduledMessage.ScheduledMessageID='$($assignment.AssignmentId)'");
                        $sched.Triggers = @('SimpleInterval;Minutes=1;MaxRandomDelayMinutes=0');
                        $null = $sched.Put()
                        sleep -Milliseconds 3000
                    } 
                    else{
                        #Write-Host "Skip assignment $($assignment.AssignmentName)"
                    }
                }
            }
            else{
                #Write-Host "$app_Id not found"
            }
        }
    }
} 
Catch{
    #Write-Host $_.Exception
    return $false
}
return $true

Remove-Variable missing_Ids

############################################################################
###~ END
############################################################################