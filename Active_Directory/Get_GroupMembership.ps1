#############################################################################################################################################
###~ List Domain Users Member Groups ########################################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-11-23
#~ Modified:
#
#############################################################################################################################################

#############################################################################################################################################
###~ Prompt for Search Domain and Username to Display Member Groups #########################################################################
#############################################################################################################################################

Import-Module ActiveDirectory
$outFile = "$env:HOMEPATH\Documents\GetADMem.txt"

Do{
    Clear-Host
    #~ Prompt for user input
    Do
    {
        Write-Host "`nSearching for User Group Memberships...`n" -ForegroundColor Black -BackgroundColor Yellow
        Write-Host "Select your Search Domain:" -ForegroundColor White -BackgroundColor Black
        Write-Host "1) " -ForegroundColor Yellow -BackgroundColor Black -NoNewLine 
        Write-Host "ASUAD.AD.ASU.EDU" -ForegroundColor White -BackgroundColor Black
        Write-Host "2) " -ForegroundColor Yellow -BackgroundColor Black -NoNewLine 
        Write-Host "ASURITE.AD.ASU.EDU" -ForegroundColor White -BackgroundColor Black
        Write-Host "3) " -ForegroundColor Yellow -BackgroundColor Black -NoNewLine 
        Write-Host "FULTON.AD.ASU.EDU" -ForegroundColor White -BackgroundColor Black
        Write-Host "Your selectection " -ForegroundColor White -BackgroundColor Black -NoNewLine 
        Write-Host "(1, 2, 3)"-ForegroundColor Yellow -BackgroundColor Black -NoNewLine
        Write-Host ":" -ForegroundColor White -BackgroundColor Black -NoNewLine
        $selection = Read-Host
        Clear-Host
        If ($selection -eq '1'){$search = "ASUAD.AD.ASU.EDU"}
        ElseIf ($selection -eq '2'){$search = "ASURITE.AD.ASU.EDU"}
        ElseIf ($selection -eq '3'){$search = "FULTON.AD.ASU.EDU"}
        Else{
            Write-Host "Invalid Selection" -ForegroundColor Red -BackgroundColor Yellow
            $search = "Invalid"
            }
    }
    While ($search -eq "Invalid" -or $search -eq $null)

    Write-Host "`nSearching for User Group Memberships...`n" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host "Select your Search Domain:" -ForegroundColor White -BackgroundColor Black -NoNewline
    Write-Host " $search"
    Write-Host "Enter the username:" -ForegroundColor White -BackgroundColor Black -NoNewLine
    Write-Host " " -NoNewLine
    $user = Read-Host
     
    Try
    {
        #~ Display Results and Prompt for runAgain
        Get-ADPrincipalGroupMembership $user -Server $search | select Name | sort Name | Out-File $outFile #pipe to Out-File to call back or Console shows blank returns
        Write-Host "`nDisplaying Results...`n"
        Get-Content $outFile
        Remove-Item $outFile -Force -Recurse
        Write-Host "Would you like to run Again" -ForegroundColor White -BackgroundColor Black -NoNewLine
        Write-Host " (Y/N)" -ForegroundColor Yellow -BackgroundColor Black -NoNewLine
        Write-Host "?:" -ForegroundColor White -BackgroundColor Black -NoNewLine 
        $runAgain = Read-Host
    }
    Catch
    {
        Write-Host "Invalid Search Criteria`n" -ForegroundColor Red -BackgroundColor Yellow
        Pause "`n"
        $runAgain = 'y'
    }
}While ($runAgain -eq 'Y')
Write-Host "`n"
Pause
Clear-Host

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################