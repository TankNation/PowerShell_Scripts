

$userWinNT = ((wmic computersystem get username /format:list | Out-String).Trim()).split('=')[1].split(' ') -replace "\W", '/'
Write-Host $userWinNT
$userFull = ((wmic computersystem get username /format:list | Out-String).Trim()).split('=')[1].split(' ')
Write-Host $userFull
$user = ((wmic computersystem get username /format:list | Out-String).Trim()).split('\')[1].split(' ')
Write-Host $user


$userOld = ([Security.Principal.WindowsIdentity]::GetCurrent()).Name.Replace("$env:UserDomain\","") # Doesn't work via Task Sequence
write-host $userOld
$domain = ([Security.Principal.WindowsIdentity]::GetCurrent()).Name.Replace("\$env:UserName","") # Doesn't work via Task Sequence
Write-Host $domain
#([adsi]”WinNT://./Hyper-V Administrators,group”).Add(“WinNT://$domain/$userOld,user”)