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
$insert_Start_Location = "<ControllablePreferences>"
$insert_End_Location = "</ControllablePreferences>"
$xml_End_Location = "</AnyConnectPreferences>"


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
        $test_Non_Compliant = $get_Content | %{$_ -match $non_Compliant_Text}
        $test_Compliant = $get_Content | %{$_ -match $compliant_Text}
        $test_Start_Location = $get_Content | %{$_ -match $insert_Start_Location}

        #~ Replace Non-Compliant Text in XML if Present
        If ($test_Non_Compliant -contains $non_Compliant_Text){
            $get_Content | % { $_.Replace($non_Compliant_Text, $compliant_Text)} | Set-Content $xml_Path
        }
        #~ Compliant Text in XML is Present (Do Nothing)
        ElseIf ($test_compliant -contains $compliant_Text){}
        #~ Place Compliant Text in XML if Not-Present
        Else { 
            If ($test_Start_Location -contains $insert_Start_Location){
                $get_Content | % { $_.Replace($insert_Start_Location, "$insert_Start_Location`n$compliant_Text")} | Set-Content $xml_Path
            }
            Else {
                $get_Content | % { $_.Replace($xml_End_Location, "$insert_Start_Location`n$compliant_Text`n$insert_End_Location`n$xml_End_Location")} | Set-Content $xml_Path
            }
        }
    }
}

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
