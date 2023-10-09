# AzureAD SignIn Audit Script

The SignInAudit PowerShell script is designed to retrieve Azure Active Directory (AzureAD) sign-in logs for a specified date. It provides options to output the logs to the console or export them to a CSV file.

## Usage

`.\SignInAudit.ps1`

The script will retrieve the logs for the last 24 hours. 

## Getting Started

Ensure that the AzureAD module is installed. If not, it can be installed using this command from and admin PowerShell:
`Install-Module -Name AzureADPreview`

## Output Options 

If logs are found, you will be prompted to choose between displaying them in the console or exporting them to a CSV file.

To output to a CSV file, enter y and provide the desired file path.
To display in the console, simply press Enter.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
