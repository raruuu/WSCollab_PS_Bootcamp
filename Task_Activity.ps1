$global:RootPath = split-path -parent $MyInvocation.MyCommand.Definition 
$json = Get-Content "$RootPath\config.json" -Raw | ConvertFrom-Json 
$CreateCSV = Import-Csv -Path "$RootPath\create.csv"
Start-Transcript -Path "$RootPath\Create_localtime_$(Get-Date -Format "MMddyyyyHHmm").txt" | Out-Null
Write-Output "`n`n------------------BEGIN-------------------------"
Write-Output "$(Get-Date -Format "HH:mm")[Log]: Starting init"
Write-Output "$(Get-Date -Format "HH:mm")[Log]: Transforming data" 
    $PurposeItem = $CreateCSV | select -ExpandProperty Purpose
    $ArrayMembersItem = ($CreateCSV | select -ExpandProperty Members) -split (',')
    $Name = $((($CreateCSV | select -ExpandProperty Name).TrimEnd()).TrimStart()) -replace '[\W]', '' 
Write-Output "$(Get-Date -Format "HH:mm")[Log]: Assembling output" 
    $AssembledObj = [PSCustomObject]@{Name = $Name
        DisplayName  = $json.DisplayNamePrefix + $Name
        PrimarySmtpAddress  = $json.AliasPrefix + $Name.ToLower() + "@" + $json.DomainName
        Description = "`n Created at: " + $env:COMPUTERNAME + "`n Created by: " + $env:USERNAME + "`n Created on: "  + ($(Get-Date)) + "`n`n=========`n" + $PurposeItem }
Write-Output "`n------------------OUTPUT-------------------------" 
$(Write-Host "Name:" -foregroundcolor Cyan),$AssembledObj.Name
$(Write-Host "DisplayName:" -foregroundcolor Cyan),$AssembledObj.DisplayName
$(Write-Host "PrimarySmtpAddress:" -foregroundcolor Cyan),$AssembledObj.PrimarySmtpAddress 
$(Write-Host "Description:" -foregroundcolor Cyan),$AssembledObj.Description 
$(Write-Host "Members:" -foregroundcolor Cyan),$ArrayMembersItem 
"`n`n------------------END-------------------------"
Stop-Transcript | Out-Null