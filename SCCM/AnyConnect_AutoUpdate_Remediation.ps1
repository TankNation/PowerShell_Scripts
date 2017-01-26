#############################################################################################################################################
###~ Configure Cisco AnyConnect VPN Profiles to Check for Updates on Connecting #############################################################
#
#~ Brian Tancredi
#~ Created: 2017-01-25
#~ Modified: 2017-01-25
#
#~ References:
#~ http://stackoverflow.com/questions/16428559/powershell-script-to-update-xml-file-content
#
#############################################################################################################################################

#############################################################################################################################################
###~ Assign Variables and Declaring Functions ###############################################################################################
#############################################################################################################################################

#~ Define Variables
$user_Path = "$env:HomeDrive\users"
$xml_Pref = "preferences.xml"
$non_Compliant_Text = "<AutoUpdate>false</AutoUpdate>"
$compliant_Text = "<AutoUpdate>true</AutoUpdate>"

function targetXML{
    $cisco_Path = "$user_Path\$user\AppData\Local\Cisco\Cisco AnyConnect Secure Mobility Client"
    $Script:xml_Path = "$cisco_Path\$xml_Pref"
} #~ Assigning path variables based on $user

#############################################################################################################################################
###~ Rewrite XML Preference File to AutoUpdate AnyConnect Client ############################################################################
#############################################################################################################################################

$users = Get-ChildItem "$user_Path" -Name
foreach ($user in $users){
    targetXML
    If (Test-Path $xml_Path){
        $get_Content = Get-Content $xml_Path
        $test_Content = $get_Content | %{$_ -match $non_Compliant_Text}
        If ($test_Content -contains $non_Compliant_Text){
            #~ Replace text in XML
            $get_Content | % { $_.Replace($non_Compliant_Text, $compliant_Text)} | Set-Content $xml_Path
        }
    }
}

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
