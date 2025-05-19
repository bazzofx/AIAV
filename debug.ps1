clear
$whiteList = Import-Csv $whitelistPath
$secureStringList = $whiteList.secureString
$processList = get-process | Where-Object{$_.processName -like "ai"}
        foreach ($proc in $processList) {
            Try{
                $fileHash = (Get-FileHash -Path $x.path -Algorithm SHA256 -ErrorAction Stop).Hash
                }
            Catch{}   
                $secureString = "$($proc.Name) - $($proc.Company) - $($proc.Description) - $($proc.Product) - $($proc.Path) - $($fileHash)"
if($secureString -notin $secureStringList){"no"}
else{"yes"}

                }