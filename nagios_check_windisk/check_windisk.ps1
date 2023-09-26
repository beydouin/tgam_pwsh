<#
.Synopsis
   This script reports back drive usage
.DESCRIPTION
   This script will report back drive usage on a specific drive
.EXAMPLE
   command[check_drive]=/usr/lib/nagios/plugins/check_nrpe -H $HOSTADDRESS$ -c check_drive -a $ARG1$ $ARG2$ $ARG3$
.EXAMPLE
define service {
    use                     generic-service
    host_name               your_windows_host
    service_description     Check Drive Usage
    check_command           check_nrpe!check_drive!C:!80!90
}

.NOTES
   Drop this script in the plugins directory on windows
#>

param (
    [string]$driveLetter,
    [int]$warningThreshold,
    [int]$criticalThreshold
)

# Nagios Exit Codes
$OK = 0
$WARNING = 1
$CRITICAL = 2
$UNKNOWN = 3

# Get drive information
$driveInfo = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $driveLetter }

if ($driveInfo) {
    $driveFreeSpace = $driveInfo.FreeSpace
    $driveTotalSpace = $driveInfo.Size
    $driveUsagePercentage = ($driveTotalSpace - $driveFreeSpace) / $driveTotalSpace * 100

    # Check drive usage and return appropriate Nagios status
    if ($driveUsagePercentage -ge $criticalThreshold) {
        Write-Host "CRITICAL: Drive usage is $($driveUsagePercentage)% - $driveLetter"
        exit $CRITICAL
    } elseif ($driveUsagePercentage -ge $warningThreshold) {
        Write-Host "WARNING: Drive usage is $($driveUsagePercentage)% - $driveLetter"
        exit $WARNING
    } else {
        Write-Host "OK: Drive usage is $($driveUsagePercentage)% - $driveLetter"
        exit $OK
    }
} else {
    Write-Host "UNKNOWN: Unable to retrieve drive information for $driveLetter"
    exit $UNKNOWN
}