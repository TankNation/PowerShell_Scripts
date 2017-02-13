#############################################################################################################################################
###~ Inventory of Computers OU ##############################################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-09-29
#~ Modified: 2016-09-29
#
#~ References:
#~ https://blogs.technet.microsoft.com/askds/2010/02/04/inventorying-computers-with-ad-powershell/
#~ https://technet.microsoft.com/en-us/library/ee617192.aspx
#
#############################################################################################################################################

#############################################################################################################################################
###~ Inventory Computers OU and Create CSV ##################################################################################################
#############################################################################################################################################

#~ Set Variables
#~ Define OU of SearchBase
$targetOU = "OU=Computers,DC=xxx,DC=xxx,DC=xxx"
#~ Define location of Out-File
$csvSave = "$env:HOMEPATH\Desktop\Computers_Inventory.CSV"

#~ Query ADComputers in SearchBase, Build Properties List, Export to CSV
Get-ADComputer -SearchBase $targetOU -Filter * -Property * | Select-Object Name, Description, OperatingSystem, LastLogonDate, ntSecurityDescriptor -ExpandProperty ntSecurityDescriptor| Sort-Object Name | Select Name, Description, OperatingSystem, LastLogonDate, owner | Export-CSV $csvSave -NoTypeInformation

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
