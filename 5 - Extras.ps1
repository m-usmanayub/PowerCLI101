### Compare host DNS/NTP entries
Get-VMHost | Get-VMHostNetwork | Select-Object HostName,DnsAddress, @{n='NtpServers'; e={Get-VMHostNtpServer -VMHost "$($_.HostName)*"}}

### Get VMs by MAC address
Get-VM kr* | Get-NetworkAdapter | Where-Object {$_.MacAddress -eq '00:50:56:be:96:b5'} | Select-Object Parent, Name, MacAddress

#region ### Find VMs with drive media mounted

# How can I find media mounted on any of Kyle's VMs?
$kyrd | Get-CDDrive
$kyrd | Get-CDDrive | Select *
Get-VM kr* | Get-CDDrive | Select-Object Parent, HostDevice, IsoPath

# Bonus: Eject mounted media (i.e. ISO files) from those drives
# Note that this typically errors out on Linux VMs
Get-VM kr* | Get-CDDrive | Where-Object IsoPath -Like * | Set-CDDrive -NoMedia

#endregion

#region ### Data manipulation and reporting
Get-Datastore

# Adding a "calculated property" to your objects
Get-Datastore |
    Select-Object Name,
                  CapacityGB,
                  FreeSpaceGB,
                  @{n='UsedSpaceGB'; e={$_.CapacityGB - $_.UsedSpaceGB}}

# Sort the datastores, round the numbers, store in new variable $report
$report = Get-Datastore |
    Sort-Object   Name  |
    Select-Object Name,
                  @{n='CapacityGB';  e={[int]$_.CapacityGB}},
                  @{n='FreeSpaceGB'; e={[math]::Round($_.FreeSpaceGB, 1)}},
                  @{n='UsedSpaceGB'; e={[math]::Round(($_.CapacityGB - $_.UsedSpaceGB), 1)}}

# Save to a local CSV, then open it in your default CSV application
$report | Export-Csv ~\Desktop\datastore.csv -NoTypeInformation
Invoke-Item ~\Desktop\datastore.csv

#endregion