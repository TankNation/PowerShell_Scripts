#############################################################################################################################################
###~ Check Compliance for Cisco AnyConnect VPN Profiles to Check for AutoUpdates on Connecting ##############################################
#
#~ Brian Tancredi
#~ Created: 2017-01-25
#~ Modified: 2017-01-26
#
#~ References:
#
#############################################################################################################################################

#############################################################################################################################################
###~ Assign Variables and Declaring Functions ###############################################################################################
#############################################################################################################################################

#~ Define Variables
$user_Path = "$env:HomeDrive\users"
$xml_Pref = "preferences.xml"
$non_Compliant = $false
$compliant_Text = "<AutoUpdate>true</AutoUpdate>"

function targetXML{
    $cisco_Path = "$user_Path\$user\AppData\Local\Cisco\Cisco AnyConnect Secure Mobility Client"
    $Script:xml_Path = "$cisco_Path\$xml_Pref"
} #~ Assigning path variables based on $user

#############################################################################################################################################
###~ Check Compliance of AutoUpdate #########################################################################################################
#############################################################################################################################################

$users = Get-ChildItem "$user_Path" -Name
foreach ($user in $users){
    targetXML
    If (Test-Path $xml_Path){
        $get_Content = Get-Content $xml_Path
        $test_Content = $get_Content | %{$_ -match $compliant_Text}
        If ($test_Content -notcontains $compliant_Text){
            #~ Flag Non-Compliant
            $non_Compliant = $true
        }
    }
}
#~ Display Compliance / False (Compliant) or True (Non-Compliant)
Write-Host $non_Compliant

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
