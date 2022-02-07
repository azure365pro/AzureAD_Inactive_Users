<#
.SYNOPSIS
.\AzureAD_Inactive_Users.ps1
.DESCRIPTION 
PowerShell script to Export Users list as per the last logon days specified. if users hasn't logged on for 90 days.
You can specify 90 to get a inactive users list . Script is suitable for small environment which doesn't require pagination
.PARAMETER LastLogonDays
The Amount of days where users never logged on. 10,20,30,60,90 - Default is Set to 30
.PARAMETER $CSVFileName
To rename the CSV File export or Store in a Different location
.EXAMPLE
.\AzureAD_Inactive_Users.ps1 -LastLogonDays 60
.EXAMPLE
.\AzureAD_Inactive_Users.ps1 -LastLogonDays 90 -CSVFileName AzureAD_Last_Logon.csv
.EXAMPLE
.\AzureAD_Inactive_Users.ps1 -LastLogonDays 30 -CSVFileName C:\Scripts\AzureAD_Inactive_Users.csv
.LINK
https://www.azure365pro.com
.NOTES
Written by: Satheshwaran Manoharan
Find me on:
* My Blog:	https://Azure365Pro.com
* LinkedIn:	https://www.linkedin.com/in/satheshwaran/
* Github:	https://github.com/azure365pro
Change Log:
V1.0, 06/02/2022 - Initial version
#>
param(
    [Parameter( Mandatory=$false)]
    [int]$LastLogonDays="30",
    [Parameter( Mandatory=$false)]
    [string]$CSVFileName = "AzureAD_Last_Logon.csv"
)

$ApplicationID    = "a8816f94-1c1e-42da-a690-ac5d075ce4d6"
$DirectoryID      = "2549c50e-e478-40d8-82cf-fa4efb5d1426"
$ClientSecret     = "Pa47Q~-SR6xH8ZgqwejFaKYHusEhSbf-z3IGu"

$Body = @{    
Grant_Type    = "client_credentials"
Scope         = "https://graph.microsoft.com/.default"
client_Id     = $ApplicationID
Client_Secret = $ClientSecret
} 

$ConnectGraph = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$DirectoryID/oauth2/v2.0/token" -Method POST -Body $Body

$token = $ConnectGraph.access_token

$Days = (get-date).adddays(-$LastLogonDays)
$GraphDays = $Days.ToString("yyyy-MM-ddTHH:mm:ssZ")

$LoginUrl = "https://graph.microsoft.com/beta/users?filter=signInActivity/lastSignInDateTime le $GraphDays"
$ExpiredUsers = (Invoke-RestMethod -Headers @{Authorization = "Bearer $($token)"} -Uri $LoginUrl -Method Get).value
$ExpiredUsers | FT DisplayName,Mail,userType,userPrincipalName,JobTitle,accountEnabled,department,companyName,onPremisesDistinguishedName,onPremisesDomainName,onPremisesSyncEnabled,createdDateTime
$ExpiredUsers | Select-Object DisplayName,Mail,userType,userPrincipalName,JobTitle,accountEnabled,department,companyName,onPremisesDistinguishedName,onPremisesDomainName,onPremisesSyncEnabled,createdDateTime`
| Export-Csv $CSVFileName
$ExpiredUsers.count