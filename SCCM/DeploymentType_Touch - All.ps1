#############################################################################################################################################
###~ Touch All SCCM Application Deployment Type Languages (Includes Retired) ################################################################
#
#~ Brian Tancredi
#~ Created: 2016-12-20
#~ Modified: 2016-12-21
#
#~ References:
#~ https://technet.microsoft.com/en-us/library/jj850086
#~ https://technet.microsoft.com/en-us/library/jj822008
#~ http://thedesktopteam.com/raphael/sccm-2012-retire-application/
#
#############################################################################################################################################

#############################################################################################################################################
###~ Connect to Site Location and Assign Variables ##########################################################################################
#############################################################################################################################################

Import-Module "\\encm2\SMS_FSE\AdminConsole\bin\ConfigurationManager\ConfigurationManager.psd1"
Set-Location FSE:

$server = "servername"
$siteCode = "sitecode"
$namepsace = "Root\SMS\Site_$siteCode"
$language = "English"

#############################################################################################################################################
#~ Run Loop for DeploymentTypes in Each Application to change Language ######################################################################
#############################################################################################################################################

#~ Gets all SCCM Applications including Retired
$applications_All = Get-CMApplication -Name "*"
#~ Gets all Retired SCCM Applications
$retired_applications_All = gwmi -computername $server -Namespace $namepsace -class SMS_ApplicationLatest -filter "IsExpired = 'true'"

#~ Reactivate Retired Applications
Foreach ($retired_application in $retired_applications_All){
    $retired_application_Name = $retired_application.LocalizedDisplayName
    $retired_application.SetIsExpired($false) | Out-Null
}

#~ Touch All Applications
Foreach ($application in $applications_All){
    $application_Name = $application.LocalizedDisplayName
    $deploymentType_All = Get-CmDeploymentType –ApplicationName $application_Name
    Foreach ($deploymentType in $deploymentType_All){
        $deploymentType_Name = $deploymentType.LocalizedDisplayName
        Set-CMDeploymentType -ApplicationName $application_Name -DeploymentTypeName $deploymentType_Name -Language $language
    }
}
#~ Re-Retire Retired Applications
Foreach ($retired_application in $retired_applications_All){
    $retired_application.SetIsExpired($true) | Out-Null
}

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
