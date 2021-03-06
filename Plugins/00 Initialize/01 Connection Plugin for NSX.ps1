# Start of Settings
# Enter the FQDN of the NSX Manager
$nsxmgr = ""
# End of Settings

<#

    NOTES ON SECURE CREDENTIAL STORAGE
    Use the following to create a credential interactively, then store it as an XML file
    
    $newPScreds = Get-Credential -message "Enter the NSX manager admin credentials here:"
    $newPScreds | Export-Clixml nsxmgrCreds.xml

    Once you have the file, move it into the root of the "15 NSX" plugins folder
    ..\Plugins\15 NSX\nsxMgrCreds.xml - overwriting the blank file that's there

#>

# Check for credentials needed to run vCheck-NSX
$creds = Import-Clixml "$(Split-Path $MyInvocation.ScriptName)\Plugins\15 NSX\nsxmgrCreds.xml"
if (!$creds)
{
    write-warning "No credentials were stored for PowerNSX to use. Please README and create the credentials file."
    break
}

# Check for PowerNSX presence (version 2.x), and link to installer if missing
$nsxModuleCheck = $null
$nsxModuleCheck = Get-Module -ListAvailable | Where-Object { $psitem.Name -eq 'PowerNSX' -and $psitem.version -like '2.*' }

if (!$nsxModuleCheck)
{
   Write-Warning "PowerNSX Installation not detected, attempting installation"
   $Branch="v2";$url="https://raw.githubusercontent.com/vmware/powernsx/$Branch/PowerNSXInstaller.ps1"; try { $wc = new-object Net.WebClient;$scr = try { $wc.DownloadString($url)} catch { if ( $_.exception.innerexception -match "(407)") { $wc.proxy.credentials = Get-Credential -Message "Proxy Authentication Required"; $wc.DownloadString($url) } else { throw $_ }}; $scr | iex } catch { throw $_ }
}

Connect-NsxServer -Server $nsxmgr -Credential $creds -DisableVIautoconnect

$Title = "Connection settings for NSX"
$Author = "Dave Hocking"
$PluginVersion = 0.2
$Header = "Connection Settings"
$Comments = "Connection Plugin for connecting to NSX"
$Display = "None"
$PluginCategory = "NSX"
