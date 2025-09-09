# GetDNSInfo
Get DNS info
	Gathers information on a network interface on specified computers in Microsoft Active Directory. The computer accounts processed are filtered by IPEnabled and DHCP Disabled. Only computers using a Static IP Address are 
    processed.
	
	Creates one text file and one CSV file, by default, in the folder where the script is run.
	The CSV file is named DNSInfo.csv, and the other is named ComputerNames.txt.
	
	Optionally, can specify the output folder.
	
	Process each computer, gathering the following information to put in the DNSInfo.csv file:
		DNSHostName
		InterfaceName
		MACAddress
		IPAddress
		IPSubnet
		DefaultIPGateway
		DNSServerSearchOrder
		DNSDomainSuffixSearchOrder

	The ComputerNames.txt file contains the DNSHostName of the computers that were processed. 
	
	The user running the script must be a member of the Domain Admins group.
	
	The script has been tested with PowerShell versions 3, 4, 5, and 5.1.
	The script has been tested with Microsoft Windows Server 2008 R2 (with PowerShell V3), 
	2012, 2012 R2, 2016, 2019, and Windows 10.
