
function getNowProcess{
Get-Process | Select-Object `
    Name, `
    Company | sort -Unique Name
    }


function fullQuery {
Get-Process | Select-Object `
    Name, `
    Id, `
    CPU, `
    StartTime, `
    Path, `
    Company, `
    Description, `
    Product, `
    FileVersion, `
    MainWindowHandle, `
    Responding, `
    Threads.Count, `
    Handles, `
    PrivateMemorySize64, `
    VirtualMemorySize64, `
    WorkingSet64 | Select -First 1 | fl
    }


function monitorPath($path){
$logPath = "C:\AVLogs\behavior_log.json"
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $path
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

Register-ObjectEvent $watcher "Created" -Action {
    $event = $Event.SourceEventArgs
    $log = @{
        Timestamp = (Get-Date).ToString("s")
        Action = "FileCreated"
        FilePath = $event.FullPath
        Name = $event.Name
    } | ConvertTo-Json -Compress
    Add-Content -Path $logPath -Value $log
    # Send to local AI model for verification (e.g., via REST call)
}

}