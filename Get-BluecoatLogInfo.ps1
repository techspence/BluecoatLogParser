<#
  .SYNOPSIS
	This module will parse a given set of Bluecoat log files for a user entered URL (known as a destination in this module) and given a number of days to search, will parse the log files looking for that destination. It will then display IP, Date, Time, User and Computer.

    Bluecoat Log Parser: Get-BluecoatLogInfo
    Author: Spencer Alessi (@techspence)
    License: MIT License
    Required Dependencies: None
    Optional Dependencies: None
    Assumptions: This module is heavily based on parsing Bluecoat logs. Specifically logs that have space as delimiters.
  
  .DESCRIPTION
    This module will parse a given set of Bluecoat log files for a user entered URL (known as a destination in this module) and given a number of days to search, will parse the log files looking for that destination. It will then display IP, Date, Time, User and Computer.

  .PARAMETER LogPath
    This is the directory where your Bluecoat logs are located.
  
  .PARAMETER Days
    This is the number of days of log files you want to search.
  
  .PARAMETER Destination
    This is the URL that's being searched for.
  
  .EXAMPLE
	Get-BluecoatLogInfo -LogPath "\\testserver1\d$\LogStore\" -Days 1 -Destination "github.com"
 #>
 
function Get-BluecoatLogInfo {

    
  param 
  (
    [parameter(Position = 0, Mandatory = $true)]
    $LogPath = "",
 
    [parameter(Position = 1, Mandatory = $true)]
    $Days = "",  

    [parameter(Position = 2, Mandatory = $true)]
    $Destination = ""
  )

# Map the network drive where the log files are located
New-PSDrive -name "B" -PSProvider FileSystem -Root $LogPath
# Go there
b:

# Get the most recent log files. *Note: This could take some time if you're searching many days
$LogFiles = Get-ChildItem -Path $LogPath -Filter *.log | ? { $_.LastWriteTime -gt (Get-Date).AddDays(-$Days) }

# Find the "destination" aka the URL. *Note: This could take some time if you're searching many days
$DestinationList = Get-Content $LogFiles | Select-String -Pattern $Destination

$Output = @()

$DestinationList | ForEach-Object {

    # if line has pattern that matches search criteria (e.g. somewebsite.com)
    # grab the date, time and ipaddress
    $CurrentLine = $_

    if ($CurrentLine -match $Destination) {
        $SingleLines = $CurrentLine.line.Split(" ")

        $Date = $SingleLines[0]
        $Time = $SingleLines[1]
        $IP = $SingleLines[3]

        # Computer Name
        $ComputerHostName = [System.Net.Dns]::GetHostEntry($IP).HostName

        # Username
        $UserName = Get-ADComputer -Filter {DNSHostName -like $ComputerHostName} -Properties * | Select-Object Description
        
        # remove "," from Get-ADComputer object, take the last name and find the full employee name
        $UserName = $UserName.Description -replace '[,]'
        $FirstName = $UserName.Split(" ")[1]
        $LastName = $UserName.Split(" ")[0]
        $FullName = "$FirstName $LastName"

        $Output += new-object psobject -Property @{
            ip = $IP
            date = $Date
            time = $Time
            computer = $ComputerHostName
            user = $FullName
        }
        
    } Else {
        # nothing for now
    }
}


$Output | Sort-Object time -Descending | Get-Unique -AsString | Format-Table ip,date,time,user,computer
$Unique = $Output | Get-Unique -AsString| measure

Write-Host "Total non-unique hits :"$Output.Count
Write-Host "Total *unique* hits for '$Destination' :"$Unique.Count

# Go home
cd ~

# Disconnect the network drive
Remove-PSDrive B


}