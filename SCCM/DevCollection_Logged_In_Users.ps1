#############################################################################################################################################
###~ Display Logged in Users on Device Collection Machines ##################################################################################
#
#~ 
#~ Created: 2016-12-12
#~ Modified: 2016-12-13
#
#~ References:
#~ Sourced from - 'Logged in Computers.ps1' - Thomas Lewis - 2016-07-15, and modified for Orchestrator Use and Report creation
#
#############################################################################################################################################

#############################################################################################################################################
###~ Assign Variables and Functions #########################################################################################################
#############################################################################################################################################

Import-Module "\\...\...\AdminConsole\bin\ConfigurationManager\ConfigurationManager.psd1"

#~ Assign Variables
$cmSite = "xxx:" #SCCM SiteName
$date = (get-date).ToString("yyyy-MM-dd@HHmm")
$inFile = "Device_Collections.txt" #File to Read from
$inDst = "E:\Logged-In" #File Path
$inPath = "$inDst\$inFile"
$curLocation = Get-Location
$ErrorActionPreference = "SilentlyContinue" #Suppressing the error messages caused when no users are logged in

#~ Assign Functions
function outFile{
    $outFile = "$dcName - User Status - $date.txt"
    $outDst = "E:\Logged-In"
    $global:outPath = "$outDst\$outFile"
}

function noUser{
    Write-Output "$compName is not in use" `n | Out-File $outPath -Append
}

function yesUser{
    Write-Output $compName $userName `n | Out-File $outPath -Append
}

#############################################################################################################################################
###~ Read In Devoce Collections from $inPath Create. List User status and Output to $outPath ################################################
#############################################################################################################################################

#Connect to SCCM
Set-Location $cmSite

# Create an array of the computers in the $inPath
$dcs = Get-Content $inPath
$dcs | foreach {
    $dcName = $_
    outFile
    $comps = Get-CMdevice -CollectionName $dcName | Select -ExpandProperty Name
    $comps | Foreach {
        $compName = $_
        $userName =  Query User /server:$_
        outFile
        If([string]::IsNullOrWhiteSpace($userName)){noUser}
        Else{yesUser}
    }
}
Set-Location $curLocation

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
