
Function Configure-TimeZone{
    #~ Get current and Define desired Time Zones
    $current_TZ = ([System.TimeZoneInfo]::Local).Id
    $desired_TZ = "US Mountain Standard Time"

    #~ Set Time Zone if not desired
    If($current_TZ -ne $desired_TZ){
        Write-Host "Adjusting Time Zone to $desired_TZ" -ForegroundColor Yellow
        Set-TimeZone -Name $desired_TZ
    }
}#~ Configures systems set Time Zone

Configure-TimeZone