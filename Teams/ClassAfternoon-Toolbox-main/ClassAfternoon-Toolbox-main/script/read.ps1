function ReadUserTeamsEffMode {
    Try {
        Write-Host "$(Get-Date -Format "HH:mm")[Log]: Check User's Teams Upgrade Effective Mode"
       # $file = Import-Csv -Path "$RootPath\create.csv"
       # foreach($c in $file){
        $NoCharsItem = $(($($global:UserID).TrimEnd()).TrimStart())  -replace '[\W]', '' 
        $AssembledObj1 = [PSCustomObject]@{Name = $NoCharsItem}

        $Output = Get-DistributionGroup -Identity $AssembledObj1.Name | Select DisplayName, PrimarySMTP*, Alias, GroupType | fl | out-string
        $OutputMember =  Get-DistributionGroupMember -Identity $AssembledObj1.Name
        $OutputMemberStr = $OutputMember | Select Name,PrimarySMTP*,RecipientType* | fl | out-string
       

           if ($Output.Length -gt 0) {
              $countOutput = $OutputMember.count
              Write-Host "`n------------------OUTPUT-------------------------`n`nDetails:`n$Output`n`nMembers:`n$OutputMemberStr"
              [System.Windows.MessageBox]::Show("Object replication success. `n`nDetails:`n$Output`n`nMembers:`n$OutputMemberStr","$($json.ToolName) $($json.ToolVersion)",$OKButton,$InfoIcon)
           }
      #  }
     }
     
     Catch {
        Get-Kill -Mode "Hard"
     }
}