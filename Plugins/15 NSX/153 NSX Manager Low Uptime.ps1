# Start of Settings
# Desired minimum uptime (Hours)
$desiredMinUptime = 48
# End of Settings


# NSX Manager Uptime
$nsxMgrSummary = Get-NsxManagerSystemSummary
$nsxUptimeString = $nsxMgrSummary.uptime

# Split out the NSX Uptime string, using -split instead of .split as this allows multi-char regex splitting
$nsxUptimeSplits = $nsxUptimeString -split ",\ "

# Detect Uptime in minutes only
if (($nsxUptimeSplits).count -eq 1)
{
    # Split on " " and get the first part as the value
    $nsxUptimeMins = (($nsxUptimeSplits[0]).split(" "))[0]

    # Calculate the Hours
    $nsxUptime = $nsxUptimeMins / 60
}

# Detect Uptime in hours and minutes
if (($nsxUptimeSplits).count -eq 2)
{
    # Split the last item on " " and get the first part as the value
    $nsxUptimeMins = (($nsxUptimeSplits[-1]).split(" "))[0]

    # Split the first item on " " and get the first part as the value
    [int]$nsxUptimeHrs = (($nsxUptimeSplits[0]).split(" "))[0]

    # Calculate the Hours
    $nsxUptime = ($nsxUptimeMins / 60) + [int]$nsxUptimeHrs 
}

# Detect Uptime in days, hours and minutes
if (($nsxUptimeSplits).count -eq 3)
{
    # Split the last item on " " and get the first part as the value
    $nsxUptimeMins = (($nsxUptimeSplits[-1]).split(" "))[0]

    # Split the second item on " " and get the first part as the value
    [int]$nsxUptimeHrs = (($nsxUptimeSplits[1]).split(" "))[0]

    # Split the first item on " " and get the first part as the value
    [int]$nsxUptimeDays = (($nsxUptimeSplits[0]).split(" "))[0]

    # Calculate the Hours
    $nsxUptime = (($nsxUptimeMins / 60) + [int]$nsxUptimeHrs) + ([int]$nsxUptimeDays * 24)
}


# If the uptime doesn't match the desired quantity
if ($nsxUptime -lt $desiredMinUptime)

{
    $NsxManagerUptimeTable = New-Object system.Data.DataTable "NSX Manager Uptime"

    # Define Columns
    $cols = @()
    $cols += New-Object system.Data.DataColumn Name,([string])
    $cols += New-Object system.Data.DataColumn Uptime`(Hr`),([int])
        
    #Add the Columns
    foreach ($col in $cols) {$NsxManagerUptimeTable.columns.add($col)}

    # Populate a row in the Table
    $row = $NsxManagerUptimeTable.NewRow()

    # Enter data in the row
    $row.Name = $nsxMgrSummary.hostName
    $row."Uptime`(hr`)" = $nsxUptime
                    
    # Add the row to the table
    $NsxManagerUptimeTable.Rows.Add($row)
 
    # Display the Backup Frequency Table
    $NsxManagerUptimeTable | Select-Object Name,Uptime`(Hr`)
}

# Plugin Outputs
$PluginCategory = "NSX"
$Title = "NSX Manager Low Uptime"
$Header = "NSX Manager Low Uptime"
$Comments = "NSX Manager has not met the minium uptime value of $($desiredMinUptime) hours"
$Display = "Table"
$Author = "Dave Hocking"
$PluginVersion = 0.1


