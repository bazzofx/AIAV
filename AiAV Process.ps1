# Path to the whitelist file
$wd = $PSScriptRoot
$whitelistPath = "$wd\whitelist.csv"
$logPath = "$wd\process_log.txt"

#Sub Functions ----------------------- Start
function AddtoLog($msg){Add-Content -Path $logPath -Value $msg
}
function suspend-process($id){
Start-Process "$wd\pssuspend64.exe" -ArgumentList "$id -accepteula"
}
function resume-process($id){
Start-Process "$wd\pssuspend64.exe" -ArgumentList "-r $id -accepteula"
}
#Sub Functions ----------------------- END

function buildBaseLine($seconds) {
if($seconds -eq $null -or $seconds -eq ""){Write-Host "Building System baseline for 180 seconds"; $seconds = 180}
$totalSeconds = $seconds
$whiteListCheckArray = @() # Keep track of the secureString to be whitelisted
$processArray = @()   # Contain the whitelist process information to be exported
    while ($totalSeconds -ge 0) {
        $processList = Get-Process |Select-Object Name,Company,Path,Description,Product

        foreach ($x in $processList) {
            Try{
                $fileHash = (Get-FileHash -Path $x.path -Algorithm SHA256 -ErrorAction Stop).Hash}
            Catch{}
            $secureString = "$($x.Name) - $($x.Company) - $($x.Description) - $($x.Product) - $($x.Path) - $($fileHash)"
            $psCustomObject = [PSCustomObject]@{
                Name         = $x.Name
                Company      = $x.Company
                Path         = $x.Path
                Description  = $x.Description
                Product      = $x.Product
                Sha256       = $fileHash
                SecureString = $secureString
            }
            if ($secureString -notin $whiteListCheckArray -and $secureString -notin $whitelistPath) {
                $processArray += $psCustomObject
                $whiteListCheckArray += $secureString
                $logEntry = "{0} - {1} - {2}" -f (Get-Date), $proc.Name, $proc.Company
                AddtoLog -msg $logEntry
                Write-host "[Added] $($x.Name) - $($x.Path):$($fileHash)" -ForegroundColor Green
            }
        } #cls forEac

        Write-Host "Building baseline... $totalSeconds seconds remaining" -ForegroundColor Cyan
        Start-Sleep -Seconds 1
        $totalSeconds--
    }#cls While
    Write-Host "Exporting Baseline" -ForegroundColor Cyan
    $processArray | Export-Csv -Path $whitelistPath -Append -NoTypeInformation -Encoding UTF8

}
#buildBaseLine -seconds 60 

function startMonitor{
#Import WhiteList


$monitorTime = 10
$initialTime = $monitorTime

Write-Host "Starting to Monitoring Computer" -ForegroundColor Cyan
#While ($monitorTime -ge 0){
While ($true){
$processList = Get-Process |Select-Object Name,Company,Path,Description,Product,Id,secureString
$whiteList = Import-Csv $whitelistPath
$secureStringList = $whiteList.secureString
   
    foreach ($proc in $processList) {
    $Id = $proc.Id
     Try{
        $fileHash = (Get-FileHash -Path $x.path -Algorithm SHA256 -ErrorAction Stop).Hash}
      Catch{}
    $secureString = "$($proc.Name) - $($proc.Company) - $($proc.Description) - $($proc.Product) - $($proc.Path) - $($fileHash)"
    #Write-Host $secureString -ForegroundColor Gray
        Write-Host $secureString -ForegroundColor Cyan

        if($secureString -notin $secureStringList){
        Write-Host "⚠ Suspicious Process Detected!!!" -ForegroundColor Yellow
        Write-Host "$Id $($proc.Name) - $($proc.Path)" -ForegroundColor Yellow
        $logEntry = "{0} - [Suspicious Process Detected] {1} - {2}" -f (Get-Date), $proc.Name, $proc.Company
        AddtoLog -msg $logEntry
        suspend-process -id $Id
        $ans = Read-Host "Resume process?"
            if($ans -eq "yes"){
            resume-process -id $Id
            Write-Host "✅ Process Resumed" -ForegroundColor Green
            Write-Host "$($proc.Name) Added to whitelist" -ForegroundColor Green
            $logEntry = "{0} - [Added to Whitelist] {1} - {2}" -f (Get-Date), $proc.Name, $proc.Company

            $psCustomObject = [PSCustomObject]@{
                    Name         = $proc.Name
                    Company      = $proc.Company
                    Path         = $proc.Path
                    Description  = $proc.Description
                    Product      = $proc.Product
                    Sha256       = $fileHash
                    SecureString = $secureString
                }

            $psCustomObject | Export-Csv -Path $whitelistPath -Append -NoTypeInformation -Encoding UTF8 -Force
            }else {
            Write-Host "[QUARANTINE] - $($proc.Name) - Not allowed to run - Suspended" -ForegroundColor Yellow
            $logEntry = "{0} - [TERMINATED] {1} - {2}" -f (Get-Date), $proc.Name, $proc.Company
            #Kill process next
            }
        }#cls if


    }#cls forEach


$monitorTime--
Write-Host "Monitoring Computer... $monitorTime / $initialTime" -ForegroundColor Gray
}#cls While
# if(($proc.Name -and $proc.Company) -notin 
}
function startMonitorUI {
    Add-Type -AssemblyName System.Windows.Forms  # Enable popup message boxes

    $monitorTime = 10
    $initialTime = $monitorTime

    # Import WhiteList
    $whiteList = @()

    Write-Host "Starting to Monitor Computer..." -ForegroundColor Cyan

    while ($monitorTime -ge 0) {
        $processList = Get-Process | Select-Object Name, Company, Path, Description, Product, Id
        $whiteList = Import-Csv $whitelistPath
        $secureStringList = $whiteList.SecureString
        foreach ($proc in $processList) {
            $Id = $proc.Id
            $secureString = "$($proc.Name) - $($proc.Company) - $($proc.Description) - $($proc.Product) - $($proc.Path)"

            if ($secureString -notin $secureStringList) {
                Write-Host "⚠ Suspicious Process Detected!!!" -ForegroundColor Yellow
                Write-Host "$Id $($proc.Name) - $($proc.Path)" -ForegroundColor Yellow

                $logEntry = "{0} - [Suspicious Process Detected] {1} - {2}" -f (Get-Date), $proc.Name, $proc.Company
                AddtoLog -msg $logEntry

                suspend-process -id $Id

                # Show popup dialog
                $msg = "Process Suspended:`n$($proc.Name)`nCompany: $($proc.Company)`nPath: $($proc.Path)`n`nResume this process?"
                $popup = [System.Windows.Forms.MessageBox]::Show($msg, "AI Antivirus Alert", "YesNo", "Warning")

                if ($popup -eq 'Yes') {
                    resume-process -id $Id
                    Write-Host "✅ Process Resumed" -ForegroundColor Green
                    Write-Host "$($proc.Name) Added to whitelist" -ForegroundColor Green

                    $logEntry = "{0} - [Added to Whitelist] {1} - {2}" -f (Get-Date), $proc.Name, $proc.Company
                    AddtoLog -msg $logEntry

                    $psCustomObject = [PSCustomObject]@{
                        Name         = $proc.Name
                        Company      = $proc.Company
                        Path         = $proc.Path
                        Description  = $proc.Description
                        Product      = $proc.Product
                        Sha256       = $fileHash
                        SecureString = $secureString
                    }

                    $psCustomObject | Export-Csv -Path $whitelistPath -Append -NoTypeInformation -Encoding UTF8 -Force
                } else {
                    Write-Host "❌ $($proc.Name) Process Terminated!" -ForegroundColor Red
                    $logEntry = "{0} - [TERMINATED] {1} - {2}" -f (Get-Date), $proc.Name, $proc.Company
                    AddtoLog -msg $logEntry
                    Stop-Process -Id $Id -Force
                }
            }
        }

        $monitorTime--
        Write-Host "Monitoring Computer... $monitorTime / $initialTime" -ForegroundColor Gray
        Start-Sleep -Seconds 5
    }
}
#startMonitor