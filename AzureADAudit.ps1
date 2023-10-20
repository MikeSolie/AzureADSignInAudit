#####################################
# AzureAD SignIn Audit              #
# Mike Solie                        #
# Version 1.1                       #
#                                   #
# Description                       #
# Connects to AzureAD and returns   #
# sign in data for the last 24      #
# hours. Has user functionality in  #
# terminal to connect and writeout  #
#####################################
# First time should be run in admin shell to install necessary modules

# Check AzureAD module installed
function CheckAzureADPreviewInstalled {
    # Check Module variable
    $getmodule = Get-Module -Name AzureADPreview -ListAvailable

    # if statement that checks if the module is installed prompts for user input
    if ($null -eq $getmodule) {
        Write-Host "[!] AzureADPreview module not installed"
        $install = Read-Host "[+] Would you like to install AzureAD Preview Module? (y/n)"
        
        # if user input is y, module is installed
        if ($install -eq 'y') {
            Write-Host "[+] Installing Module..."
            Install-Module -Name AzureADPreview
            Write-Host "[+] Installation Complete"
        }
        # if any other input other than y is provided
        else {
            Write-Host "[-] Exiting..."
            exit
        }
    }
    # if module is already installed
    else {
        Write-Host "[+] Initializing..."
        Start-Sleep -Seconds 3
    }
}

# Signin Audit function
function Get-SignInAudit {
    param (
        [Parameter(Mandatory=$true)]
        [DateTime]$date
    )
    # converts date to string format
    $date_string = $date.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")

    try {
        # calls and checks AzureAD funtion
        CheckAzureADPreviewInstalled
        Write-Host "[+] Fetching Data..."
        # variable storing command to pull audit
        $signInLogs = Get-AzureADAuditSignInLogs -Filter "createdDateTime gt $date_string"

        #check for logs
        if ($signInLogs.Count -eq 0) {
            Write-Host "[!] No logs found"
        }
        
        # checks if user would like output to CSV file
        $outfile = Read-Host "[+] Would you like to output this to a CSV? Enter 'y' to output CSV file? (y/n)"
        if ($outfile -eq 'y') {
            # user input for filepath
            $filepath = Read-Host "[+] Enter filepath for CSV file"
            # exports data to CSV
            $signInLogs | Select-Object CreatedDateTime, UserDisplayName, AppDisplayName, IpAddress, ClientAppUsed, @{Name = 'Status'; Expression = {if ($_.Status.ErrorCode -eq 0) {'Success'} else {'Failed'}}}, @{Name = 'DeviceOS'; Expression = {$_.DeviceDetail.OperatingSystem}}, @{Name = 'Location'; Expression = {$_.Location.City}} | Export-Csv -Path $filepath -NoTypeInformation
        }
        else {
            # outputs data to terminal
            $signInLogs | Select-Object CreatedDateTime, UserDisplayName, AppDisplayName, IpAddress, ClientAppUsed, @{Name = 'Status'; Expression = {if ($_.Status.ErrorCode -eq 0) {'Success'} else {'Failed'}}}, @{Name = 'DeviceOS'; Expression = {$_.DeviceDetail.OperatingSystem}}, @{Name = 'Location'; Expression = {$_.Location.City,$_.Location.State}} | Sort-Object CreatedDateTime |Format-Table
        }
    }
    catch {
        # error handling - connects to AzureAD
        Write-Host "[!] Not connected to AzureAD - $_"
        $userInput = Read-Host "[!] Do you want to connect to AzureAD? (y/n)" 

        if ($userInput -eq 'y') {
            # connects to AzureAD and reruns script
            Connect-AzureAD; Start-Sleep -Seconds 5; .\AzureAdLogs3.ps1
            
        }
        else {
            Write-Host "[-] Exiting..."
            exit
        }
    }
}

function main {
    $date = (Get-Date).AddDays(-1)
    Get-SignInAudit -date $date 
}
#--->
main # runs script
#<---
