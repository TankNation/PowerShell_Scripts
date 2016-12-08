#############################################################################################################################################
###~ PC Configuration - Disable RDP #########################################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-11-21
#~ Modified: 
#
#~ References:
#~ http://networkerslog.blogspot.com/2013/09/how-to-enable-remote-desktop-remotely.html
#
#############################################################################################################################################

#############################################################################################################################################
###~ Assign Variables, Remove Permission, Disable Service and Firewall Rule #################################################################
#############################################################################################################################################

#~ Define Variables
$userFull = ((wmic computersystem get username /format:list | Out-String).Trim()).split('=')[1].split(' ')

#~ Add user to Remote Desktop User Group
net localgroup "Remote Desktop Users" "$userFull" /delete

#~ Enable RDP with Secure Authentication, and Enable Windows Firewall Rule
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 1
Set-NetFirewallRule -Name RemoteDesktop-UserMode-In-TCP -Enabled false
Set-NetFirewallRule -Name RemoteDesktop-UserMode-In-UDP -Enabled false

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
