& {
    Get-CimInstance -ClassName Win32_PnPEntity | Where-Object { $_.DeviceID -like "*PCI*" } |
        Select-Object Caption, DeviceID, Status, Service, ClassGuid, PNPClass |
        Format-Table -AutoSize

    Get-CimInstance -ClassName Win32_Bus -Filter "DeviceID LIKE 'PCI%'" |
        ForEach-Object {
            $related = Get-CimAssociatedInstance -InputObject $_ -ResultClassName Win32_PnPEntity
            foreach ($device in $related) {
                [PSCustomObject]@{
                    DeviceID = $device.DeviceID
                    Location = $device.LocationInformation
                }
            }
        } | Format-Table -AutoSize

    $Availability = @{
        Name = 'Availability'
        Expression = {
            switch ([int]$_.Availability) {
                1  { 'Other' }
                2  { 'Unknown' }
                3  { 'Running/Full Power' }
                4  { 'Warning' }
                5  { 'In Test' }
                6  { 'Not Applicable' }
                7  { 'Power Off' }
                8  { 'Off Line' }
                9  { 'Off Duty' }
                10 { 'Degraded' }
                11 { 'Not Installed' }
                12 { 'Install Error' }
                13 { 'Power Save - Unknown' }
                14 { 'Power Save - Low Power Mode' }
                15 { 'Power Save - Standby' }
                16 { 'Power Cycle' }
                17 { 'Power Save - Warning' }
                18 { 'Paused' }
                19 { 'Not Ready' }
                20 { 'Not Configured' }
                21 { 'Quiesced' }
                default { "$_" }
            }
        }
    }

    $StatusInfo = @{
        Name = 'StatusInfo'
        Expression = {
            switch ([int]$_.StatusInfo) {
                1  { 'Other' }
                2  { 'Unknown' }
                3  { 'Enabled' }
                4  { 'Disabled' }
                5  { 'Not Applicable' }
                default { "$_" }
            }
        }
    }

    Get-CimInstance -ClassName Win32_Bus |
        Select-Object DeviceID, Status, BusNum, $StatusInfo, $Availability |
        Sort-Object -Property DeviceID |
        Format-Table -AutoSize

    Get-PnpDevice -PresentOnly |
        Select-Object Status, FriendlyName, InstanceId |
        Format-Table -GroupBy Status

    Get-CimInstance Win32_PnPEntity |
        Select-Object Status, Class, FriendlyName, InstanceId |
        Format-Table -GroupBy Status

    Get-WmiObject -Class Win32_PnpEntity -ComputerName localhost -Namespace Root\CIMV2 |
        Where-Object { $_.ConfigManagerErrorCode -gt 0 } |
        Select-Object ConfigManagerErrorCode, Errortext, Present, Status, StatusInfo, Caption |
        Format-List -GroupBy Status
} | Out-File -Width 4096 -Encoding UTF8 "$env:USERPROFILE\Desktop\PeriphVendeur_et_Erreurs.txt"

$script:link = $null

& {
    foreach ($f in @("$env:USERPROFILE\Desktop\PeriphVendeur_et_Erreurs.txt")) {
        if (Test-Path $f) {
            $script:link = curl -F "file=@$f" https://store1.gofile.io/uploadFile |
                ConvertFrom-Json |
                Select-Object -ExpandProperty data |
                Select-Object -ExpandProperty downloadPage
        }
    }
}

& {
    Clear-Host
    Start-Process $script:link
    Write-Host "`n Lien de téléchargement : $script:link`n" -ForegroundColor Green
}
