<#
.SYNOPSIS
   CSV export of groups for SailPoint ingest
.DESCRIPTION
  This script generates the export file 'teams_users.csv' for SailPoint ingest.
  Exported CSV contains custom column headers and appended values for access reviews.
  The output can be used for SailPoint ingest in environments that do not have
  the SailPoint M365 Connector.
.REQUIREMENTS
  Active powershell connection to Exchange Online
.OUTPUTS
  teams_users.csv
  Update $GroupCSV Path for your output drop
.NOTES
  Version:        1.0
  Author:         Bill Beehner
  Website:        https://www.bouncethebox.com
  Parler:         @bouncethebox
  Twitter:        @bouncethebox
  Contact:        bounce@bouncethebox.com
  Creation Date:  102156EFEB21
  Purpose/Change: Initial/First Release
#>
Connect-ExchangeOnline
Write-Host -ForegroundColor Green "Loading all Microsoft 365 Groups in the Tenant..."
$Groups = Get-UnifiedGroup -ResultSize Unlimited
$GroupCSV = @()
Foreach ($Group in $Groups)
{
 
$Members = @()
$Owners = @()
$Members += Get-UnifiedGroupLinks -Identity $Group.Identity -LinkType Members -ResultSize Unlimited
$Owners += Get-UnifiedGroupLinks -Identity $Group.Identity -LinkType Owners -ResultSize Unlimited
Foreach ($objMember in $Members)
{
$GroupCSV += New-Object -TypeName PSObject -Property @{
UserID = $objMember.PrimarySMTPAddress
App = "Microsoft Teams"
Access = "$($Group.DisplayName) - Member"
}
}
Foreach ($objOwner in $Owners)
{
$GroupCSV += New-Object -TypeName PSObject -Property @{
UserID = $objOwner.PrimarySMTPAddress
App = "Microsoft Teams"
Access = "$($Group.DisplayName) - Owner"
}
}
} 
Write-Host -ForegroundColor Green "`nCreating and exporting teams_users.csv file for SailPoint ingest. ¯\_(ツ)_/¯ "
$GroupCSV | Select-Object UserID, App, Access | Export-Csv D:\scripts\teams_users.csv -NoTypeInformation -force
