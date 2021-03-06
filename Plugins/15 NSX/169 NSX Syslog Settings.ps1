# Needs expanding to check for correct Syslog Settings on controllers
<#
Query Controller Syslog Exporter
GET https://NSX-Manager-IP-Address/api/2.0/vdn/controller/controllerId/syslog
Response Body:
<controllerSyslogServer>
<syslogServer>10.135.14.236</syslogServer>
<port>514</port>
<protocol>UDP</protocol>
<level>INFO</level>
</controllerSyslogServer>
#>

# Start of Settings
# Desired Syslog Server
$desiredSyslogServer = ""
# End of Settings

# Reset flag
$displaySyslogtable = $false

# NSX Manager Syslog Server
$nsxMgrSyslogSettings = Get-NsxManagerSyslogServer
$nsxMgrSyslogServer = $nsxMgrSyslogSettings.Syslogserver


# Check for the presence of the desired Syslog server in the string above
if ($nsxMgrSyslogServer -ne $desiredSyslogServer)
{
    $displaySyslogtable = $true
}

# If the DisplaySyslogtable flag has been set, generate one
if ($displaySyslogtable -eq $true)

{
    $NsxManagerSyslogtable = New-Object system.Data.DataTable "NSX Manager Syslog Server"

    # Define Columns
    $cols = @()
    $cols += New-Object system.Data.DataColumn "Specified Server",([string])
    $cols += New-Object system.Data.DataColumn Configured,([string])
        
    #Add the Columns
    foreach ($col in $cols) {$NsxManagerSyslogtable.columns.add($col)}

    # Populate a row in the Table
    $row = $NsxManagerSyslogtable.NewRow()

    # Enter data in the row
    $row."Specified Server" = $desiredSyslogServer
    $row.Configured = @($nsxMgrSyslogServer).Contains($desiredSyslogServer)
                    
    # Add the row to the table
    $NsxManagerSyslogtable.Rows.Add($row)
         
    # Display the Backup Frequency Table
    $NsxManagerSyslogtable | Select-Object "Specified Server",Configured
}

# Plugin Outputs
$PluginCategory = "NSX"
$Title = "NSX Manager Syslog Server Setting"
$Header = "NSX Manager Syslog Server Setting"
$Comments = "NSX Manager has not been configured with the correct Syslog Server Settings"
$Display = "Table"
$Author = "Dave Hocking"
$PluginVersion = 0.1


