#############################################################################################################################################
###~ MSI Product Code Lookup ################################################################################################################
#
#~ Brian Tancredi
#~ Created: 2016-10-27
#~ Modified: 2017-08-15
#
#############################################################################################################################################

#############################################################################################################################################
###~ GUI Stuff ##############################################################################################################################
#############################################################################################################################################

#~ From Control Adds
Function Load-Form{
    $Form.Controls.Add($InputTextBox)
    $Form.Controls.Add($InstructionsLabel)
    $Form.Controls.Add($SearchButton)
    $Form.Controls.Add($ExitButton)
    $Form.Controls.Add($ResultsListBox)
    $Form.Controls.Add($CopyButton)
    [void]$Form.ShowDialog()
    $Form.Dispose()
    $Form.Add_Shown({$Form.Activate()})
}#~ Loads GUI Form

#~ Search Button Refreshes
Function Load-SearchSearching{
    $SearchButton.Text = "Searching..."
    $SearchButton.BackColor = "#00A3E0"
    $SearchButton.ForeColor = "#000000"
    $SearchButton.Refresh()
}#~ Display Searching Status

Function Load-SearchFinished{
    $SearchButton.BackColor = "#78BE20"
    $SearchButton.Text = "Finished!"
    $SearchButton.ForeColor = "#000000"
    $SearchButton.Refresh()
    Start-Sleep -Milliseconds 500
    Load-SearchDefaults
}#~ Display Finished Status

Function Load-SearchDefaults{
    $SearchButton.Text = "Search"
    $SearchButton.BackColor = "#FFC627"
    $SearchButton.ForeColor = "#8C1D40"
    $SearchButton.Refresh()
}#~ Applies Default Status

#~ Copy Button Refreshes
Function Load-CopyCopying{
    $CopyButton.Text = "Copied!"
    $CopyButton.BackColor = "#78BE20"
    $CopyButton.ForeColor = "#000000"
    $CopyButton.Refresh()
}#~ Display Running Status

Function Load-CopyDefaults{
    $CopyButton.Text = "Copy"
    $CopyButton.BackColor = "#FFC627"
    $CopyButton.ForeColor = "#8C1D40"
    $CopyButton.Refresh()
}#~ Applies Default Status

#~ Exit Button Refreshes
Function Load-StatusExiting{
    $ExitButton.Text = "Exiting..."
    $ExitButton.BackColor = "#78BE20"
    $ExitButton.ForeColor = "#000000"
    $ExitButton.Refresh()
    $Form.Close()
    [System.Environment]::Exit(0)
}#~ Displays Exiting Status

#~ Result Box Refreshes
Function Clear-Results{
    [void]$ResultsListBox.Items.Clear()
    $ResultsListBox.Refresh()
}#~ Clears List Box Items

#############################################################################################################################################
###~ Assigning Variables and Declaring Functions  ###########################################################################################
#############################################################################################################################################

Function Search-Application{
    #~ Clear Error Provider
    $ErrorProvider.Clear()
    
    #~ Clear ListBox
    Clear-Results
    
    #~ Display Searching
    Load-SearchSearching

    #~ Query WMI for Application
    $Global:search_Results = Get-WmiObject Win32_Product -filter "Name Like '%$($InputTextBox.Text)%'" | Sort-Object Name
   
    #~ Display Results
    If ($search_Results){
        Foreach ($result in $search_Results){
            $application = $result.Name
            $version = $result.Version
            $vendor = $result.Vendor
            $msi = $result.IdentifyingNumber.ToUpper()
            $display = "$msi`t||   $application ($version)"

            #~ Display in ListBox
            $ResultsListBox.HorizontalScrollbar = $true
            $ResultsListBox.HorizontalExtent = 675
            [void]$ResultsListBox.Items.Add("$display")
            $ResultsListBox.Refresh()     
        }
    }
    Else{
        [void]$ResultsListBox.Items.Add("No Results Found. Try adjusting your search.")
        $ResultsListBox.Refresh()  
    }
    #~ Display Finished
    Load-SearchFinished
}#~ Searches for MSI code of input; Display Results

Function Copy-MSI{
    #~ MSI RegEx
    $msi_RegEx = [regex]"(({[-0-9A-Fa-f]{36})+?})"
    $selected = $ResultsListBox.SelectedItem -match $msi_RegEx

    If ($selected){
        #~ Clear Error Provider
        $ErrorProvider.Clear()

        #~ Display Copied
        Load-CopyCopying

        #~ Copy MSI Code to Clipboard
        $msi = $matches[1]
        Set-Clipboard -Value "$msi"

        #~ Display Copy
        Start-Sleep -Milliseconds 300
        Load-CopyDefaults
    }
    Else{
        #~ Set Error Provider
        $ErrorProvider.SetError($ResultsListBox, "No application selected.")
        $ErrorProvider.SetIconAlignment($ResultsListBox,[System.Windows.Forms.ErrorIconAlignment]::TopRight)
    }
}#~ Copies selected item's MSI code

#############################################################################################################################################
###~ Assigning Variables and Building Form ##################################################################################################
#############################################################################################################################################

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Windows.Forms.Application]::EnableVisualStyles()

$form_ico = "C:\Windows\System32\control.exe"

$Global:ErrorProvider = New-Object System.Windows.Forms.ErrorProvider

#~ Form Starting Points
$offset_W = "14"
$padding_Y = "42"

#~ Label Starting Points
$XL = "6"
$YL = "5"

#~ Button Sizes
$B_W = 100
$B_H = 25

#~ Instruction Label
$IL_W = 280
$IL_H = 20
$XIL = [int]$XL
$YIL = [int]$YL + 2

#~ Input TextBox
$ITB_W = 200
$ITB_H = 17
$XITB = [int]$XIL + $IL_W
$YITB = [int]$YIL 

#~ Search Button
$SB_W = $B_W
$SB_H = $B_H
$XSB = [int]$XIL + $IL_W + $ITB_W + 5
$YSB = [int]$YIL - 1

#~ Results ListBox
$RLB_W = [int]$XITB + $ITB_W - 6
$RLB_H = 140
$XRLB = [int]$XL
$YRLB = [int]$YIL + $IL_H + 7

#~ Copy Button
$CB_W = $B_W
$CB_H = $B_H
$XCB = [int]$XSB
$YCB = [int]$YSB + $SB_H + 2

#~ Exit Button
$EB_W = $B_W
$EB_H = $B_H
$XEB = [int]$XCB
$YEB = [int]$YCB + $CB_H + 2

#~ Form Sizes
#$RLB_H = [int]$B_H + $EB_H
$form_H = [int]$YRLB + $RLB_H + 35
$form_W = [int]$XSB + $SB_W + 15

#~ Create Form GUI
Add-Type -AssemblyName System.Windows.Forms

$Form = New-Object System.Windows.Forms.Form
$Form.Text = "MSI Product Code Lookup"
#$Form.TopMost = $true
$Form.Width = $form_W
$Form.Height = $form_H
#$Form.AutoSize = $true
$Form.ControlBox = $true
$Form.MaximizeBox = $false
$Form.MinimizeBox = $false
$Form.FormBorderStyle = "Fixed3D"
$Form.Font = "Arial,10"
$Form.BackColor = "#8C1D40"
If (Test-Path $form_ico){
    $Form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$form_ico")
}

#~ Keys to Check All (F1); Check Common (F2); Check Clear (F3)
$Form.KeyPreview = $true
$Form.Add_KeyDown({If ($_.KeyCode -eq "Enter"){Search-Application}})
$Form.Add_KeyDown({If ($_.KeyCode -eq "Escape"){Load-StatusExiting}})

#~ Instructions Label
$InstructionsLabel = New-Object System.Windows.Forms.Label
$InstructionsLabel.Text = "Enter an application name (or part of one):"
#$InstructionsLabel.TextAlign = "MiddleRight"
#$InstructionsLabel.AutoSize = $true
$InstructionsLabel.Width = $IL_W
$InstructionsLabel.Height = $IL_H
$InstructionsLabel.Location = New-Object System.Drawing.Point($XIL,$YIL)
$InstructionsLabel.Font = "Arial,10"
$InstructionsLabel.ForeColor = "#FFC627"

#~ Input TextBox
$InputTextBox = New-Object System.Windows.Forms.TextBox
$InputTextBox.Width = $ITB_W
$InputTextBox.Height = $ITB_H
$InputTextBox.Location = New-Object System.Drawing.Point($XITB,$YITB)
$InputTextBox.Font = "Arial,10"

#~ Results ListBox
$ResultsListBox = New-Object System.Windows.Forms.ListBox
$ResultsListBox.Width = $RLB_W
$ResultsListBox.Height = $RLB_H
$ResultsListBox.Location = New-Object System.Drawing.Point($XRLB,$YRLB)
$ResultsListBox.Font = "Arial,8"
$ResultsListBox.ScrollAlwaysVisible = $false

#~ Search Button
$SearchButton = New-Object System.Windows.Forms.Button
$SearchButton.Text = "Search"
$SearchButton.Width = $SB_W
$SearchButton.Height = $SB_H
$SearchButton.Location = New-Object System.Drawing.Point($XSB,$YSB)
$SearchButton.Font = "Arial,10"
$SearchButton.BackColor = "#FFC627"
$SearchButton.ForeColor = "#8C1D40"
$SearchButton.Add_Click({Search-Application})

#~ Copy Button
$CopyButton = New-Object System.Windows.Forms.Button
$CopyButton.Text = "Copy"
$CopyButton.Width = $CB_W
$CopyButton.Height = $CB_H
$CopyButton.Location = New-Object System.Drawing.Point($XCB,$YCB)
$CopyButton.Font = "Arial,10"
$CopyButton.BackColor = "#FFC627"
$CopyButton.ForeColor = "#8C1D40"
$CopyButton.Add_Click({Copy-MSI})

#~ Exit Button
$ExitButton = New-Object System.Windows.Forms.Button
$ExitButton.Text = "Exit"
$ExitButton.Width = $EB_W
$ExitButton.Height = $EB_H
$ExitButton.Location = New-Object System.Drawing.Point($XEB,$YEB)
$ExitButton.Font = "Arial,10"
$ExitButton.BackColor = "#FFC627"
$ExitButton.ForeColor = "#8C1D40"
$ExitButton.Add_Click({Load-StatusExiting})

#############################################################################################################################################
###~ Run Script - Display Form and Handle Selections ########################################################################################
#############################################################################################################################################

#~ Display GUI
Load-Form

#############################################################################################################################################
#~ END ######################################################################################################################################
#############################################################################################################################################