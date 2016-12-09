#############################################################################################################################################
###~ SSL Certificate Expiration Check and Notify ############################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-12-08
#~ Modified: 2016-12-09
#
#~ References:
#~ Sourced from - https://iamoffthebus.wordpress.com/2014/02/04/powershell-to-get-remote-websites-ssl-certificate-expiration/
#~ and modified for Email and cleaner outputs
#
#~ Notes:
#~ Write-Hosts commented out to work in Orchestrator otherwise; "Cannot invoke this function because the current host does not implement it."
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
 function emailNotice{
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
    Cert issuer: $certIssuer
    Certificate Effective Date: $certEffectiveDate
    Certificate Expiration Date: $expiration"
    Send-MailMessage -from $from -to $to -Cc $cc -subject $subject -body $body -smtpserver $smtp
} #Email Alert Settings and Configuration

function localNoticePass{
#    Write-Host "Cert for site $url expires in $certExpiresIn days [on $expiration]`n" -ForegroundColor Green
} #PowerShell Notifications on Pass

function localNoticeFail{
#    Write-Host "$body `n`nThreshold is $minimumCertAgeDays days.`n" -ForegroundColor Yellow
} #PowerShell Notifications on Fail

#############################################################################################################################################
###~ Get HTTP Response on URLs, find Expiring Certs, and send notification Emails ###########################################################
#############################################################################################################################################

#~ Disabling Cert Validation Check. This is what makes this whole thing work with invalid certs...
 [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

foreach ($url in $urls){
#    Write-Host "Checking $url`n" -ForegroundColor Green
    $req = [Net.HttpWebRequest]::Create($url)
    $req.Timeout = $timeoutMilliseconds
    try {$req.GetResponse() |Out-Null}
    catch {#Write-Host "Exception while checking URL $url`: $_" -ForegroundColor Red
    }
    [datetime]$expiration = $req.ServicePoint.Certificate.GetExpirationDateString()
    [int]$certExpiresIn = ($expiration - $(get-date)).Days
    $certName = $req.ServicePoint.Certificate.GetName()
    $certPublicKeyString = $req.ServicePoint.Certificate.GetPublicKeyString()
    $certSerialNumber = $req.ServicePoint.Certificate.GetSerialNumberString()
    $certThumbprint = $req.ServicePoint.Certificate.GetCertHashString()
    $certEffectiveDate = $req.ServicePoint.Certificate.GetEffectiveDateString()
    $certIssuer = $req.ServicePoint.Certificate.GetIssuerName()
    If ($certExpiresIn -gt $minimumCertAgeDays){localNoticePass}
    Else {emailNotice; localNoticeFail}
    Remove-Variable req
    Remove-Variable expiration
    Remove-Variable certExpiresIn
}

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
