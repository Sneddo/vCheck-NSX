# Start of Settings
# Desired SSO State [true/false]
$nsxDesiredSSOconnected = "true"
# End of Settings

# Desired VC State [true/false]
$nsxDesiredVCconnected = "true"

# Get real SSO Connection State
$nsxSSO = Get-NsxManagerSsoConfig
$nsxSSOserver = (($nsxSSO.ssoLookupServiceUrl).split('/')[2]).split(':')[0]
$nsxSSOconnected = $nsxSSO.connected

# Get real VC Connection state
$nsxVC = Get-NsxManagerVcenterConfig
$nsxVCserver = $nsxVC.ipaddress
$nsxVCconnected = $nsxVC.connected

# If the connection states don't match
if ($nsxSSOconnected -ne $nsxDesiredSSOconnected -or $nsxVCconnected -ne $nsxDesiredVCconnected)

{
    $NsxManagerConnectionTable = New-Object system.Data.DataTable "NSX Manager SSO and vCenter Connnection States"

    # Define Columns
    $cols = @()
    $cols += New-Object system.Data.DataColumn "Target Server",([string])
    $cols += New-Object system.Data.DataColumn Connected,([string])
        
    #Add the Columns
    foreach ($col in $cols) {$NsxManagerConnectionTable.columns.add($col)}

    #----------------------------------------
    # Populate a row in the Table for SSO
    $row = $NsxManagerConnectionTable.NewRow()

    # Enter data in the row for SSO Server
    $row."Target Server" = "SSO: " + $nsxSSOserver
    $row.Connected = $nsxSSOconnected
                    
    # Add the row to the table
    $NsxManagerConnectionTable.Rows.Add($row)
    #----------------------------------------
    
    # Populate a row in the Table for vCenter
    $row = $NsxManagerConnectionTable.NewRow()

    # Enter data in the row for VC Server
    $row."Target Server" = "vCenter: " + $nsxVCserver
    $row.Connected = $nsxVCconnected
                    
    # Add the row to the table
    $NsxManagerConnectionTable.Rows.Add($row)
    #----------------------------------------
 
    # Display the Backup Frequency Table
    $NsxManagerConnectionTable | Select-Object "Target Server",Connected
}

# Plugin Outputs
$PluginCategory = "NSX"
$Title = "NSX Manager SSO and VC Connection State"
$Header = "NSX Manager SSO and VC Connection State"
$Comments = "NSX Manager SSO and/or vCenter Connection not in desired State"
$Display = "Table"
$Author = "Dave Hocking"
$PluginVersion = 0.1


