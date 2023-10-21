try {
    #--init
    $global:ErrorActionPreference = "Stop"
    $global:RootPath = split-path -parent $MyInvocation.MyCommand.Definition
    $global:json = Get-Content "$RootPath\config.json" -Raw | ConvertFrom-Json 
    
    #---init>gui-util
        Add-Type -AssemblyName System.Windows.Forms,System.Drawing
        Add-Type -AssemblyName PresentationCore,PresentationFramework
        $global:YesNoButton = [System.Windows.MessageBoxButton]::YesNo
        $global:OKButton = [System.Windows.MessageBoxButton]::OK
        $global:InfoIcon = [System.Windows.MessageBoxImage]::Information
        $global:WarningIcon = [System.Windows.MessageBoxImage]::Warning
        $global:ErrorIcon = [System.Windows.MessageBoxImage]::Error
        $global:QButton = [System.Windows.MessageBoxImage]::Question
        $objIcon = New-Object system.drawing.icon ("$RootPath\tms.ico")
        $GifFile_CompBackground= (Get-Item -Path "$RootPath\gftoolbox.gif")
        $boxobj = [System.Windows.Forms.TextBox]

        function ShowScreen {
                $lblMainMenu.Show()
                $shpDivider.Show()
                $btnUserCheck.Show()
                $btnRead.Show()
                $btnUpdate.Show()
                $btnDelete.Show()
        }
    
    function global:Get-Kill {
        param (
            $Mode
        )
        if ($Mode -eq "Hard") {
            $e = $_.Exception.GetType().FullName
            $line = $_.InvocationInfo.ScriptLineNumber
            $msg = $_.Exception.Message
            Write-Output "$(Get-Date -Format "HH:mm")[Error]: Initialization failed at line [$line] due [$e] `n`nwith details `n`n[$msg]`n"
            Write-Output "`n`n------------------END ROOT-------------------------"
            Stop-Transcript | Out-Null
            ClearUserCheckCSV
            ClearUpdateCSV
            DisConTEAMS
            exit
        }else{
            Write-Output "`n`n------------------END ROOT-------------------------"
            Stop-Transcript | Out-Null
            ClearUserCheckCSV
            ClearUpdateCSV
            DisConTEAMS
            exit
        }
        
    }
    
    function global:ClearUserCheckCSV {
        Remove-Item -Path "$RootPath\UserCheck.csv"
        New-Item $RootPath\UserCheck.csv -ItemType File | Out-Null
        Set-Content $RootPath\UserCheck.csv 'Identity'    
    }

     function global:ClearUpdateCSV {
        Remove-Item -Path "$RootPath\update.csv"
        New-Item $RootPath\update.csv -ItemType File | Out-Null
        Set-Content $RootPath\update.csv 'Name,EmailAddress'    
    }

    function SetToolMode {
        param (
            $Mode
        )
        If($Mode -eq "Enabled")
        {
            $btnUserCheck.enabled = $true
            $btnRead.enabled = $true
            $btnUpdate.enabled = $true
            $btnDelete.enabled = $true
        }else{
            #$btnUserCheck.enabled = $false
            #$btnRead.enabled = $false
            #$btnUpdate.enabled = $false
            #$btnDelete.enabled = $false
        }
    }

    #---init>m365 Util
    function global:ConTEAMS {

        try {
            Connect-ExchangeOnline | Out-Null
            Write-Host "$(Get-Date -Format "HH:mm")[Log]: Teams connected success"
        }
        catch {
            Write-Host "$(Get-Date -Format "HH:mm")[Error]: Teams connected failed"
            Get-Kill -Mode "Hard"
        }
        
    }
    function global:DisConTEAMS {

        try {
            Disconnect-ExchangeOnline -Confirm:$false | Out-Null
            Write-Host "$(Get-Date -Format "HH:mm")[Log]: Teams disconnected success"
        }
        catch {
            Write-Host "$(Get-Date -Format "HH:mm")[Error]: Teams disconnected  failed"
        }
        
    }

    function global:GetDL {
        param (
            $Identity
        )
        try {
            Get-DistributionGroup -Identity $Identity 
        }
        catch {
        }

        return
        
    }

    function ReadBox {
       
        $form1 = New-Object System.Windows.Forms.Form -Property @{
        ClientSize = '300,100'
        Text = "Check User"
        StartPosition = 'CenterScreen'
        BackColor = $json.ToolUIBackColor
        Icon = $objIcon
        }

        $form1.Controls.Add($box_search)
        $form1.Controls.Add($btnSearch) 
        $form1.ShowDialog()
        $form1.Dispose()
        
    }

    Start-Transcript -Path "$RootPath\Toolbox_localtime_$(Get-Date -Format "MMddyyyyHHmm").txt" | Out-Null
    
    Write-Output "`n`n------------------BEGIN ROOT-------------------------"
    Write-Output "$(Get-Date -Format "HH:mm")[Log]: Form init success"
    
    $ConResult = [System.Windows.MessageBox]::Show("Do you want to connect to MSTEAMS?","$($json.ToolName) $($json.ToolVersion)",$YesNoButton,$QButton)
    
    If($ConResult -eq "Yes")
    {
        ConTEAMS | Out-Null
        $TEAMSStatus = "(Online)"
    }else{
        $TEAMSStatus = "(Offline)"
        Write-Host "$(Get-Date -Format "HH:mm")[Log]: Teams connection skipped. Viewing Interface Only"
    }



    #--form
    $IMG_CompBackground = [System.Drawing.Image]::fromfile($GifFile_CompBackground)
    $Gif_CompBackground = New-Object Windows.Forms.picturebox -Property @{
        Location = New-Object System.Drawing.Point(200,80)
        #Autosize = $true
        Image = $IMG_CompBackground
        SizeMode = "Zoom"
        Size = New-Object System.Drawing.Size(250,250)
    }
    #---form-assembly
    $form = New-Object Windows.Forms.Form -Property @{
        Size = New-Object System.Drawing.Size(485,460)
        Text = "$($json.ToolName) $($json.ToolVersion)"
        StartPosition = 'CenterScreen'
        BackColor = $json.ToolUIBackColor
        FormBorderStyle = 'Fixed3D'
        Icon = $objIcon
    }
    $btnStart = New-Object System.Windows.Forms.Button -Property @{
        Location = New-Object System.Drawing.Point(160,240)
        Size = New-Object System.Drawing.Size(125,50)
        ForeColor = $json.ToolUILabelColor
        BackColor = $json.ToolUIBtnColor
        Text = 'START'      
    }

    $shpDivider = New-Object System.Windows.Forms.Label -Property @{
        Location = New-Object System.Drawing.Point(30,50)
        Size = New-Object System.Drawing.Size(400,2)
        Text = ""
        BorderStyle = 'Fixed3D'
    }
    $lblMainMenu = New-Object System.Windows.Forms.Label -Property @{
        Location = New-Object System.Drawing.Point(30,30)
        Size = New-Object System.Drawing.Size(280,20)
        Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9,[System.Drawing.FontStyle]::Bold)
        Text = "Group Management Tools $TEAMSStatus"
    }
    $btnUserCheck = New-Object System.Windows.Forms.Button -Property @{
        Location = New-Object System.Drawing.Point(30,140)
        Size = New-Object System.Drawing.Size(125,50)
        ForeColor = $json.ToolUILabelColor
        BackColor = $json.ToolUIBtnColor
        Text = 'Check User Bulk'      
    }

    $btnUserCheck.Add_Click({
        Write-Host "$(Get-Date -Format "HH:mm")[Log]: Check User selected"
        Import-Module "$RootPath\UserCheck.ps1" -Force
        Write-Host "$(Get-Date -Format "HH:mm")[Log]: CHECK function imported"
        CheckTeamsEffMode
        Write-Host "`n`n$(Get-Date -Format "HH:mm")[Log]: CHECK function completed"
        [System.Windows.MessageBox]::Show("CHECK function completed","$($json.ToolName) $($json.ToolVersion)",$OKButton,$InfoIcon)
    })

    $btnRead = New-Object System.Windows.Forms.Button -Property @{
        Location = New-Object System.Drawing.Point(30,70)
        Size = New-Object System.Drawing.Size(125,50)
        ForeColor = $json.ToolUILabelColor
        BackColor = $json.ToolUIBtnColor
        Text = 'Check User'      
    }

        $box_search = New-Object $boxobj
        $box_search.Size = New-Object System.Drawing.Size(280,30)
        $box_search.Location = New-Object System.Drawing.Size(10,20)
   
        $btnSearch = New-Object System.Windows.Forms.Button -Property @{
        Location = New-Object System.Drawing.Point(165,50)
        Size = New-Object System.Drawing.Size(125,30)
        ForeColor = $json.ToolUILabelColor
        BackColor = $json.ToolUIBtnColor
        Text = 'Search'     
        }
            
        $btnSearch.Add_Click({
        Import-Module "$RootPath\read.ps1" -Force
        $global:UserID = $box_search.text
        ReadUserTeamsEffMode
        Write-Host "`n`n$(Get-Date -Format "HH:mm")[Log]: READ function completed"
        [System.Windows.MessageBox]::Show("READ function completed","$($json.ToolName) $($json.ToolVersion)",$OKButton,$InfoIcon)

        $box_search.Hide()
        $btnSearch.Hide()
        $form1.Dispose()
        })   


    $btnRead.Add_Click({
        Write-Host "$(Get-Date -Format "HH:mm")[Log]: READ selected"
        ReadBox
        

    })

    $btnUpdate = New-Object System.Windows.Forms.Button -Property @{
        Location = New-Object System.Drawing.Point(30,210)
        Size = New-Object System.Drawing.Size(125,50)
        ForeColor = $json.ToolUILabelColor
        BackColor = $json.ToolUIBtnColor
        Text = 'Enable Teams Voice'      
    }


    $btnUpdate.Add_Click({
        Write-Host "$(Get-Date -Format "HH:mm")[Log]: UPDATE selected"
        Import-Module "$RootPath\update.ps1" -Force
        Write-Host "$(Get-Date -Format "HH:mm")[Log]: UPDATE function imported"
        UpdateDL
        Write-Host "`n`n$(Get-Date -Format "HH:mm")[Log]: UPDATE function completed"
        [System.Windows.MessageBox]::Show("UPDATE function completed","$($json.ToolName) $($json.ToolVersion)",$OKButton,$InfoIcon)
    })


    $btnDelete = New-Object System.Windows.Forms.Button -Property @{
        Location = New-Object System.Drawing.Point(30,280)
        Size = New-Object System.Drawing.Size(125,50)
        ForeColor = $json.ToolUILabelColor
        BackColor = $json.ToolUIBtnColor
        Text = 'Offboard Teams User'      
    }

    If($ConResult -eq "Yes")
    {
        SetToolMode -Mode "Enabled"
    }else{
        SetToolMode -Mode "Disabled"
    }

    #---form-render
    $form.Controls.Add($shpDivider)
    $form.Controls.Add($lblMainMenu)
    $form.Controls.Add($btnUserCheck)
    $form.Controls.Add($btnRead)
    $form.Controls.Add($btnUpdate)
    $form.Controls.Add($btnDelete)
    $form.Controls.Add($Gif_CompBackground)
    $Gif_CompBackground.SendToBack()
    $form.ShowDialog() | Out-Null
    
    Write-Host "$(Get-Date -Format "HH:mm")[Log]: Form closed"
    
    Get-Kill 
}
catch {
    Get-Kill -Mode "Hard"
}