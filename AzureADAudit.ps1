#####################################
# AzureAD SignIn Audit              #
# Mike Solie                        #
# Version 1                         #
#                                   #
# Description                       #
# Connects to AzureAD and returns   #
# sign in data for the last 24      #
# hours. Has user functionality in  #
# terminal to connect and writeout  #
#####################################

# Signin Audit function
function SignInAudit {
    param (
        [Parameter(Mandatory=$true)]
        [DateTime]$date
    )
    $date_string = $date.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

    try {
        Write-Host "Fetching Data..."
        $signInLogs = Get-AzureADAuditSignInLogs -Filter "createdDateTime gt $date_string"

        #check for logs
        if ($signInLogs.Count -eq 0) {
            Write-Host "No logs found"
            return
        }

        $outfile = Read-Host "[+] Would you like to output this to a CSV? Enter 'y' to output CSV file? (y/n)"
        if ($outfile -eq 'y') {
            $filepath = Read-Host "[+] Enter filepath for CSV file"
            $signInLogs | Select-Object CreatedDateTime, UserDisplayName, AppDisplayName, IpAddress, ClientAppUsed, @{Name = 'Status'; Expression = {if ($_.Status.ErrorCode -eq 0) {'Success'} else {'Failed'}}}, @{Name = 'DeviceOS'; Expression = {$_.DeviceDetail.OperatingSystem}}, @{Name = 'Location'; Expression = {$_.Location.City}} | Export-Csv -Path $filepath -NoTypeInformation
        }
        else {
            $signInLogs | Select-Object CreatedDateTime, UserDisplayName, AppDisplayName, IpAddress, ClientAppUsed, @{Name = 'Status'; Expression = {if ($_.Status.ErrorCode -eq 0) {'Success'} else {'Failed'}}}, @{Name = 'DeviceOS'; Expression = {$_.DeviceDetail.OperatingSystem}}, @{Name = 'Location'; Expression = {$_.Location.City,$_.Location.State}} | Sort-Object CreatedDateTime |Format-Table
        }
    }
    catch {
        Write-Host "[!] Not connected to AzureAD...: $_"
        $userInput = Read-Host "[!] Do you want to connect to AzureAD? (y/n)" 

        if ($userInput -eq 'y') {
            Connect-AzureAD
        }
        else {
            Write-Host "Exiting..."
            exit
        }
    }
}

$date = (Get-Date).AddDays(-1)
SignInAudit -date $date
