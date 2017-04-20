############################################################################
###~ Check For Missing Available Deployment Type Information
#~ Brian Tancredi
#~ Created: 2017-04-18
#~ Modified: 2017-04-20
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

############################################################################
###~ Check for Missing Available Deployment Type Information
############################################################################

#~ Get List of Available Applications
Try{
    $applications = gwmi -namespace root\ccm\clientsdk -query "select * from ccm_application"
}
Catch{
    exit 1
}
 
#~ Total # of Applications Available
$apps_Total = $applications.Length
 
#~ Check .__Path of each application to determine Missing Deployment Type MetaData
ForEach($app in $applications){
    $app_DT = [wmi] $app.__Path
 
    If($app_DT.AppDTs.Name.Length -eq 0){
        $count_MissingDTs++
    }
}
 
#~ Output Count for Compliance
Write-Host $count_MissingDTs

############################################################################
###~ END
############################################################################