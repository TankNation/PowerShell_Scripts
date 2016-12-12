#############################################################################################################################################
###~ SSL Certificate Expiration Check and Notify ############################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-12-08
#~ Modified: 2016-12-12
#
#~ References:
#~ Sourced from - https://iamoffthebus.wordpress.com/2014/02/04/powershell-to-get-remote-websites-ssl-certificate-expiration/
#~ and modified for Email and cleaner outputs
#
#~ Notes:
#~ Write-Hosts commented out to work in Orchestrator otherwise; "Cannot invoke this function because the current host does not implement it."
#~ Can uncomment if running locally.
#
#############################################################################################################################################

#############################################################################################################################################
###~ Assigning Variables and Functions  #####################################################################################################
#############################################################################################################################################

#~ Assign Variables
$minimumCertAgeDays = 91
$timeoutMilliseconds = 10000
$urls = @(
"https://www.site1.com",
"https://www.site2.com",
"https://www.site3.com",
"https://www.site4.com",
"https://www.site5.com",
"https://www.site6.com")

 #~ Declare Functions
 function emailNotifyFail{
    $from = "email@email.com"
    $to = @("email@email.com")
    $cc =@(
    "email@email.com",
    "email@email.com",
    "email@email.com")
    $smtp = "smtp.email.com"
    $subject = "SSL Certificate Expiring Notice - $url"
    $global:body = "Cert for site $url expires in $certExpiresIn days [on $expiration].
    `nCheck details:
    Certificate Name: $certName
    Certificate Public Key: $certPublicKeyString
    Certificate Serial Number: $certSerialNumber
    Certificate Thumbprint: $certThumbprint
    Certificate Issuer: $certIssuer
    Certificate Effective Date: $certEffectiveDate
    Certificate Expiration Date: $expiration"
    Send-MailMessage -from $from -to $to -Cc $cc -subject $subject -body $body -smtpserver $smtp
} #Email Alert Settings and Configuration

function localNotifyPass{
#    Write-Host "Cert for site $url expires in $certExpiresIn days [on $expiration]`n" -ForegroundColor Green
} #PowerShell Notifications on Pass

function localNotifyFail{
#    Write-Host "$body `n`nThreshold is $minimumCertAgeDays days.`n" -ForegroundColor Yellow
} #PowerShell Notifications on Fail

function certProperties{
     [datetime]$global:expiration = $req.ServicePoint.Certificate.GetExpirationDateString()
     [int]$global:certExpiresIn = ($expiration - $(get-date)).Days
     $global:certName = $req.ServicePoint.Certificate.GetName()
     $global:certPublicKeyString = $req.ServicePoint.Certificate.GetPublicKeyString()
     $global:certSerialNumber = $req.ServicePoint.Certificate.GetSerialNumberString()
     $global:certThumbprint = $req.ServicePoint.Certificate.GetCertHashString()
     $global:certEffectiveDate = $req.ServicePoint.Certificate.GetEffectiveDateString()
     $global:certIssuer = $req.ServicePoint.Certificate.GetIssuerName()
} #Decalre Certificate Properties

function urlCheck{
    Write-Host "Checking $url" -ForegroundColor Green
    $global:req = [Net.HttpWebRequest]::Create($url)
    $req.Timeout = $timeoutMilliseconds
    try {$req.GetResponse() |Out-Null}
    catch {#Write-Host "Exception while checking URL $url`: $_" -ForegroundColor Red
    }
} #URL Checks and Error Handling

function cleanUp{
    Remove-Variable req -Scope Script
    Remove-Variable expiration -Scope Script
    Remove-Variable certExpiresIn -Scope Script
} #Remove stored Variables in Loop

#############################################################################################################################################
###~ Get HTTP Response on URLs, find Expiring Certs, and send notification Emails ###########################################################
#############################################################################################################################################

#~ Disabling Cert Validation Check. This is what makes this whole thing work with invalid certs...
 [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

foreach ($url in $urls){
    urlCheck
    certProperties
    If ($certExpiresIn -gt $minimumCertAgeDays){localNotifyPass}
    Else{emailNotifyFail; localNotifyFail}
    cleanUp
}

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
