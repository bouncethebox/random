<#
.SYNOPSIS
  CSV export of groups for SailPoint 
.DESCRIPTION
  This script generates the export file 'teams_groups.csv' for SailPoint ingest.
  Exported CSV contains custom column headers and appended values.
  The output can be used for SailPoint ingest in environments that do not have
  the SailPoint M365 Connector.
.REQUIREMENTS
  Active powershell connection to Exchange Online
.OUTPUTS
  teams_groups.csv
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
# Process Groups
$GroupsCSV = @()
Write-Host -ForegroundColor Green "Processing Microsoft 365 Groups..."
foreach ($Group in $Groups)
{
     
    # Get  members
    Write-Host -ForegroundColor Yellow -NoNewline "㋡"
    $Members = Get-UnifiedGroupLinks -Identity $Group.Identity -LinkType Members -ResultSize Unlimited
     
    foreach ($Member in $Members)
    {
    $GroupsCSV +=   [pscustomobject]@{
                    Access = "$($Group.DisplayName) - Member"
                    UserID = $Member.PrimarySMTPAddress
                    Description = "Production Microsoft 365 Group that grants user access to Teams.  Members of this group have normal access within the Team site $Group. For more information, contact $Owners”
                    }          
    }
    # Get  owners
    $Owners = Get-UnifiedGroupLinks -Identity $Group.Identity -LinkType Owners -ResultSize Unlimited
     
    foreach ($Owner in $Owners)
    {
             
$GroupsCSV +=   [pscustomobject]@{
                    Access = "$($Group.DisplayName) - Owner"
                    UserID = $Owner.PrimarySMTPAddress
                    Description = "Production Office 365 Group that grants owner access to Teams.  Members of this group have owner access within the Team site $Group. - For more information contact $Owners.”
                    }
    }       
}
# Export to CSV
Write-Host -ForegroundColor Green "`nCreating and exporting teams_groups.csv file for SailPoint ingest.  Done. ¯\_(ツ)_/¯ "
$GroupsCSV | Select Access,UserID,Description | Export-Csv -NoTypeInformation -Path d:\scripts\teams_groups.csv
