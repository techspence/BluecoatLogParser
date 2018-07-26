# Bluecoat Log Parser
The Bluecoat Log Parser is a tool that will parse a given set of Bluecoat log files for a user entered URL (known as a destination in this module) and given a number of days to search, will parse the log files looking for that destination. It will then display IP, Date, Time, User and Computer.

The reason this tool exists is to be able to correlate Bluecoat Proxy logs with other network monitoring tools.

## Functions
```
LogPath       - This is the directory where your Bluecoat logs are located.
Day           - This is the number of days of log files you want to search.
Destination   - This is the URL that's being searched for.
```

## Credits
I really liked the way [@dafthack](https://github.com/dafthack) created the README for [MailSniper](https://github.com/dafthack/mailsniper), so I used that as somewhat of a boilerplate to create my README. Thanks!

## Example
```
Get-BluecoatLogInfo -LogPath "\\testserver1\d$\LogStore\" -Days 1 -Destination "github.com"
```

## Future Enhancements
1. Parse the log file using regex instead of position
2. Create a script to auto-generate a test log file, then run the tool to test 
