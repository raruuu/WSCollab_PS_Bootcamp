function ReadDL {
    Try {
        Write-Host "$(Get-Date -Format "HH:mm")[Log]: Reading Contents"
         function CheckUpdateCSV {
            $UpdateCSV = Import-Csv -Path "$RootPath\update.csv"
            if ($($UpdateCSV.Name.Count) -gt 0) {
                
            }else{
                Write-Host "`n------------------OUTPUT-------------------------"
                Write-Host "$(Get-Date -Format "HH:mm")[Log]: CSV is empty (~_^)" -foregroundcolor Yellow
    
                #popup method 2
                Write-Host "$(Get-Date -Format "HH:mm")[Debug]: Attempting to update [update.csv]"
                $UpdateCSVResult = [System.Windows.MessageBox]::Show("Empty CSV. Do you want to update [update.csv] file?","$($json.ToolName) $($json.ToolVersion)",$YesNoButton,$QButton)
    
                If($UpdateCSVResult -eq "Yes")
                {
                    Invoke-Item "$RootPath\update.csv"
                    Start-Sleep -s 15
                    Write-Host "`n$(Get-Date -Format "HH:mm")[Debug]: Checking again [update.csv]"
                    [System.Windows.MessageBox]::Show("Checking again [update.csv]","$($json.ToolName) $($json.ToolVersion)",$OKButton,$WarningIcon)
                    CheckCreateCSV
                }else{
                    [System.Windows.MessageBox]::Show("Goodbye!.","$($json.ToolName) $($json.ToolVersion)",$OKButton,$WarningIcon)
                }
       
            }
        }
        CheckUpdateCSV
        foreach($c in $UpdateCSV){

        $NoCharsItemName = $(($($c.Name).TrimEnd()).TrimStart())  -replace '[\W]', '' 
        $AssembledObj2 = [PSCustomObject]@{
        Name =  $NoCharsItemName
        EmailAddress = $c.EmailAddress
        }
        
        try{
                   
                Add-DistributionGroupMember -Identity $AssembledObj2.Name -Member $AssembledObj2.EmailAddress | Out-Null
                Write-Host "`n$(Get-Date -Format "HH:mm")[Log]: Object update success. Allowing 20 seconds replication"
                Start-Sleep -s 10
                Write-Host "`n$(Get-Date -Format "HH:mm")[Log]: Object update success."
                Write-Host "`n------------------OUTPUT-------------------------"
                [System.Windows.MessageBox]::Show("Object update success.","$($json.ToolName) $($json.ToolVersion)",$OKButton,$InfoIcon)

                }catch{
                    Write-Host "`n$(Get-Date -Format "HH:mm")[Error]: Object update failed" 
                    Get-Kill -Mode "Hard"
                }
     }
     }
     
     Catch {
        Get-Kill -Mode "Hard"
     }
}
