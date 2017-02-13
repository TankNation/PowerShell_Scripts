#############################################################################################################################################
###~ Security Identifier (SID) Lookup #######################################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-10-28
#~ Modified: 2016-09-29
#
#~ References:
#~ https://community.spiceworks.com/how_to/2776-powershell-sid-to-user-and-user-to-sid
#
#############################################################################################################################################

#Prompt for user selection
#Loop back here if runAgain -eq "y"
Do {
    Clear-Host
    #Loop back here if $invalid -eq "True"
    Do {
	    Write-Host "`nSelect your inquiry..." -ForegroundColor Yellow
        Write-Host "`n1) Domain User to SID" -ForegroundColor Green
        Write-Host "This will give you a Domain User's SID" -ForegroundColor Gray
        Write-Host "`n2) SID to Domain User" -ForegroundColor Green
        Write-Host "This will allow you to enter a SID and find the Domain User" -ForegroundColor Gray
        Write-Host "`n3) Local User to SID" -ForegroundColor Green
        Write-Host "This will give you a Local User's SID" -ForegroundColor Gray
        $select = Read-Host -Prompt "`nSelect 1, 2 or 3"

        if ($select -eq '1')
        {
            #Domain User to SID
            #This will give you a Domain User's SID
            $dom = Read-Host -Prompt "`nEnter Domain"
            $domUser = Read-Host -Prompt "Enter Username"
            $objUser = New-Object System.Security.Principal.NTAccount("$dom", "$domUser") 
            $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier]) 
            Write-Host `n"Here is the SID for ""$dom\$domUser"" :" $strSID.Value -ForegroundColor Green
            $Global:invalid = "False"
        }
        ElseIf ($select -eq '2')
        {
            #SID to Domain User
            #This will allow you to enter a SID and find the Domain User
            $domSID = Read-Host -Prompt "`nEnter SID"
            $objSID = New-Object System.Security.Principal.SecurityIdentifier("$domSID") 
            $objUser = $objSID.Translate( [System.Security.Principal.NTAccount]) 
            Write-Host "`nHere is the Identity associated with SID ""$domSID"":" $objUser.Value -ForegroundColor Green
            $Global:invalid = "False"
        }
        ElseIf ($select -eq '3')
        {
            #LOCAL USER to SID
            #This will give you a Local User's SID
            $locUser = Read-Host -Prompt "`nEnter Username"
            $objUser = New-Object System.Security.Principal.NTAccount("$locUser")
            $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier]) 
            Write-Host "`nHere is the SID for ""$env:computername\$locUser"":" $strSID.Value -ForegroundColor Green
            $Global:invalid = "False"
        }
        Else
        {
            #Invalid Selection
            Clear-Host
            Write-Host "`nInvalid Selection" -ForegroundColor Red -BackgroundColor Yellow
            $Global:invalid = "True"
            PAUSE
		    Clear-Host
        }
    }While ($invalid -eq "True")
    Write-Host `n
    PAUSE
#    Clear-Host
    #Prompt for Run Again
    $runStart = Read-Host "`nRun Again? From Start (Y,N)?"
}While ($runStart -eq "Y")
Clear-Host
EXIT

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################
