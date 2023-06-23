<#
.SYNOPSIS
	Gathers information on a network interface on specified computers in Microsoft Active 
	Directory.
.DESCRIPTION
	Gathers information on a network interface on specified computers in Microsoft Active 
	Directory. The computer accounts processed are filtered by IPEnabled and DHCP Disabled.
	Only computers using a Static IP Address are processed.
	
	Creates one text file and one CSV file, by default, in the folder where the script is 
	run.
	The CSV file is named DNSInfo.csv and the other is named ComputerNames.txt.
	
	Optionally, can specify the output folder.
	
	Process each computer gathering the following information to put in the DNSInfo.csv 
	file:
		DNSHostName
		InterfaceName
		MACAddress
		IPAddress
		IPSubnet
		DefaultIPGateway
		DNSServerSearchOrder
		DNSDomainSuffixSearchOrder

	The ComputerNames.txt file contains the DNSHostName of the computers that were 
	processed. 
	
	The user running the script must be a member of Domain Admins.
	
	The script has been tested with PowerShell versions 3, 4, 5, and 5.1.
	The script has been tested with Microsoft Windows Server 2008 R2 (with PowerShell V3), 
	2012, 2012 R2, 2016, 2019 and Windows 10.
.PARAMETER Dev
	Clears errors at the beginning of the script.
	Outputs all errors to a text file at the end of the script.
	
	This is used when the script developer requests more troubleshooting data.
	The text file is placed in the same folder from where the script is run.
	
	This parameter is disabled by default.
.PARAMETER Folder
	Specifies the optional output folder to save the output reports. 
.PARAMETER Log
	Generates a log file for troubleshooting.
.PARAMETER Name
	Specifies the Name of the target computer.
	
	Accepts input from the pipeline.
.PARAMETER ScriptInfo
	Outputs information about the script to a text file.
	The text file is placed in the same folder from where the script is run.
	
	This parameter is disabled by default.
	This parameter has an alias of SI.
.PARAMETER SmtpServer
	Specifies the optional email server to send the output report. 
.PARAMETER SmtpPort
	Specifies the SMTP port. 
	The default is 25.
.PARAMETER UseSSL
	Specifies whether to use SSL for the SmtpServer.
	The default is False.
.PARAMETER From
	Specifies the username for the From email address.
	If SmtpServer is used, this is a required parameter.
.PARAMETER To
	Specifies the username for the To email address.
	If SmtpServer is used, this is a required parameter.
.EXAMPLE
	Get-ADComputer -Filter * | .\Get-DNSInfo.ps1

.EXAMPLE
	"Win10_1","Win10_2" | .\Get-DNSInfo.ps1

.EXAMPLE
	Get-AdComputer -filter {OperatingSystem -like "*window*"} | 
	.\Get-DNSInfo.ps1 -Folder \\FileServer\ShareName
	
	Output file will be saved in the path \\FileServer\ShareName
.EXAMPLE
	Get-AdComputer -filter {OperatingSystem -like "*window*"} 
	-SearchBase "ou=SQLServers,dc=domain,dc=tld" 
	-SearchScope Subtree 
	-properties Name -EA 0 | 
	Sort Name | 
	.\Get-DNSInfo.ps1
.EXAMPLE
	Get-AdComputer -filter {OperatingSystem -like "*window*"} 
	-properties Name -EA 0 | Sort Name | .\Get-DNSInfo.ps1
	
	Processes only computers with "window" in the OperatingSystem property
.EXAMPLE
	Get-AdComputer -filter {OperatingSystem -like "*window*" -and OperatingSystem 
	-like "*server*"} -properties Name -EA 0 | Sort Name | .\Get-DNSInfo.ps1
	
	Processes only computers with "window" and "server" in the OperatingSystem property.
	This catches operating systems like Windows 2000 Server and Windows Server 2003.
.EXAMPLE
	Get-Content "C:\webster\computernames.txt" | .\Get-DNSInfo.ps1
	
	computernames.txt is a plain text file that contains a list of computer names.
	
	For example:
	
	LABCA
	LABDC1
	LABDC2
	LABFS
	LABIGEL
	LABMGMTPC
	LABSQL1

.EXAMPLE
	Get-ADComputer -Filter * | .\Get-DNSInfo.ps1 
	-SmtpServer mail.domain.tld
	-From XDAdmin@domain.tld 
	-To ITGroup@domain.tld	

	The script will use the email server mail.domain.tld, sending from XDAdmin@domain.tld, 
	sending to ITGroup@domain.tld.

	The script will use the default SMTP port 25 and will not use SSL.

	If the current user's credentials are not valid to send email, 
	the user will be prompted to enter valid credentials.
.EXAMPLE
	Get-ADComputer -Filter * | .\Get-DNSInfo.ps1
	-SmtpServer mailrelay.domain.tld
	-From Anonymous@domain.tld 
	-To ITGroup@domain.tld	

	***SENDING UNAUTHENTICATED EMAIL***

	The script will use the email server mailrelay.domain.tld, sending from 
	anonymous@domain.tld, sending to ITGroup@domain.tld.

	To send unauthenticated email using an email relay server requires the From email account 
	to use the name Anonymous.

	The script will use the default SMTP port 25 and will not use SSL.
	
	***GMAIL/G SUITE SMTP RELAY***
	https://support.google.com/a/answer/2956491?hl=en
	https://support.google.com/a/answer/176600?hl=en

	To send email using a Gmail or g-suite account, you may have to turn ON
	the "Less secure app access" option on your account.
	***GMAIL/G SUITE SMTP RELAY***

	The script will generate an anonymous secure password for the anonymous@domain.tld 
	account.
.EXAMPLE
	Get-ADComputer -Filter * | .\Get-DNSInfo.ps1
	-SmtpServer labaddomain-com.mail.protection.outlook.com
	-UseSSL
	-From SomeEmailAddress@labaddomain.com 
	-To ITGroupDL@labaddomain.com	

	***OFFICE 365 Example***

	https://docs.microsoft.com/en-us/exchange/mail-flow-best-practices/how-to-set-up-a-multifunction-device-or-application-to-send-email-using-office-3
	
	This uses Option 2 from the above link.
	
	***OFFICE 365 Example***

	The script will use the email server labaddomain-com.mail.protection.outlook.com, 
	sending from SomeEmailAddress@labaddomain.com, sending to ITGroupDL@labaddomain.com.

	The script will use the default SMTP port 25 and will use SSL.
.EXAMPLE
	Get-ADComputer -Filter * | .\Get-DNSInfo.ps1
	-SmtpServer smtp.office365.com 
	-SmtpPort 587
	-UseSSL 
	-From Webster@CarlWebster.com 
	-To ITGroup@CarlWebster.com	

	The script will use the email server smtp.office365.com on port 587 using SSL, 
	sending from webster@carlwebster.com, sending to ITGroup@carlwebster.com.

	If the current user's credentials are not valid to send email, 
	the user will be prompted to enter valid credentials.
.EXAMPLE
	Get-ADComputer -Filter * | .\Get-DNSInfo.ps1
	-SmtpServer smtp.gmail.com 
	-SmtpPort 587
	-UseSSL 
	-From Webster@CarlWebster.com 
	-To ITGroup@CarlWebster.com	

	*** NOTE ***
	To send email using a Gmail or g-suite account, you may have to turn ON
	the "Less secure app access" option on your account.
	*** NOTE ***
	
	The script will use the email server smtp.gmail.com on port 587 using SSL, 
	sending from webster@gmail.com, sending to ITGroup@carlwebster.com.

	If the current user's credentials are not valid to send email, 
	the user will be prompted to enter valid credentials.
.INPUTS
	Accepts pipeline input with the property Name or a list of computer names.
.OUTPUTS
	No objects are output from this script.  This script creates two text files.
.NOTES
	NAME: Get-DNSInfo.ps1
	VERSION: 1.00
	AUTHOR: Carl Webster and Michael B. Smith
	LASTEDIT: August 6, 2020
#>


#region script change log	
#Created by Carl Webster and Michael B. Smith
#webster@carlwebster.com
#@carlwebster on Twitter
#https://www.CarlWebster.com
#
#michael@smithcons.com
#@essentialexch on Twitter
#https://www.essential.exchange/blog/
#
#Created on March 19, 2020
#
#Version 1.0 released to the community on 11-August-2020
#
#endregion


[CmdletBinding(SupportsShouldProcess = $False, ConfirmImpact = "None", DefaultParameterSetName = "") ]

Param(
	[parameter(
		Mandatory                       = $True,
		ValueFromPipeline               = $True,
		ValueFromPipelineByPropertyName = $True,
		Position                        = 0)] 
	[string[]]$Name,
	
	[parameter(Mandatory=$False)] 
	[Switch]$Dev=$False,
	
	[parameter(Mandatory=$False)] 
	[string]$Folder="",
	
	[parameter(Mandatory=$False)] 
	[Switch]$Log=$False,
	
	[parameter(Mandatory=$False)] 
	[Alias("SI")]
	[Switch]$ScriptInfo=$False,
	
	[parameter(Mandatory=$False)] 
	[string]$SmtpServer="",

	[parameter(Mandatory=$False)] 
	[int]$SmtpPort=25,

	[parameter(Mandatory=$False)] 
	[switch]$UseSSL=$False,

	[parameter(Mandatory=$False)] 
	[string]$From="",

	[parameter(Mandatory=$False)] 
	[string]$To=""

	)

Begin
{
	Function UserIsaDomainAdmin
	{
		#function adapted from sample code provided by Thomas Vuylsteke
		$IsDA = $False
		$name = $env:username
		Write-Verbose "$(Get-Date): TokenGroups - Checking groups for $name"

		$root = [ADSI]""
		$filter = "(sAMAccountName=$name)"
		$props = @("distinguishedName")
		$Searcher = new-Object System.DirectoryServices.DirectorySearcher($root,$filter,$props)
		$account = $Searcher.FindOne().properties.distinguishedname

		$user = [ADSI]"LDAP://$Account"
		$user.GetInfoEx(@("tokengroups"),0)
		$groups = $user.Get("tokengroups")

		$grp = [ADSI] ( 'WinNT://' + $env:userdnsdomain + '/Domain Admins,group' )
		$sid = New-Object System.Security.Principal.SecurityIdentifier( $grp.objectSid.Item( 0 ), 0 )
		
		ForEach($group in $groups)
		{     
			$ID = New-Object System.Security.Principal.SecurityIdentifier($group,0)       
			If($ID.Equals($sid))
			{
				$IsDA = $True
				Break
			}     
		}

		Return $IsDA
	}
	
     Function parsePath
    {
        Param(
            [string] $path
        )

        ## path looks like this:
        ## '\\EX2016\root\cimv2:Win32_NetworkAdapter.DeviceID="16"'
        ## i'm sure regex could do this - but this was easy

        $path   = $path.SubString( 2 ) ## strip off leading \\
        $index  = $path.IndexOf( '\' ) ## find end of server name
        $server = $path.SubString( 0, $index )  ## store server name
        $path   = $path.SubString( $index + 1 ) ## strip off server name and terminating \
        $index  = $path.IndexOf( ':' ) ## find end of WMI namespace
        $nSpace = $path.SubString( 0, $index )  ## store WMI namespace
        $path   = $path.SubString( $index + 1 ) ## strip off WMI namespace and terminating :
        $index  = $path.IndexOf( '.' ) ## find end of WMI class
        $class  = $path.SubString( 0, $index )  ## store WMI class
        $path   = $path.SubString( $index + 1 ) ## strip off WMI class and terminating .
        $filter = $path ## all that's left

        $server, $nSpace, $class, $filter
    }

	Set-StrictMode -Version Latest
	$PSDefaultParameterValues = @{"*:Verbose"=$True}
	
	$AmIReallyDA = UserIsADomainAdmin
	If($AmIReallyDA -eq $False)
	{
		Write-Error "
		`n`n
		`t`t
		$env:username is not a Domain Admin.
		`n`n
		`t`t
		Script cannot continue.
		`n`n"
		Exit
	}
	Else
	{
		Write-Verbose "$(Get-Date): $env:username has Domain Admin rights"
	}
	
	If(![String]::IsNullOrEmpty($SmtpServer) -and [String]::IsNullOrEmpty($From) -and [String]::IsNullOrEmpty($To))
	{
		Write-Error "
		`n`n
		`t`t
		You specified an SmtpServer but did not include a From or To email address.
		`n`n
		`t`t
		Script cannot continue.
		`n`n"
		Exit
	}
	If(![String]::IsNullOrEmpty($SmtpServer) -and [String]::IsNullOrEmpty($From) -and ![String]::IsNullOrEmpty($To))
	{
		Write-Error "
		`n`n
		`t`t
		You specified an SmtpServer and a To email address but did not include a From email address.
		`n`n
		`t`t
		Script cannot continue.
		`n`n"
		Exit
	}
	If(![String]::IsNullOrEmpty($SmtpServer) -and [String]::IsNullOrEmpty($To) -and ![String]::IsNullOrEmpty($From))
	{
		Write-Error "
		`n`n
		`t`t
		You specified an SmtpServer and a From email address but did not include a To email address.
		`n`n
		`t`t
		Script cannot continue.
		`n`n"
		Exit
	}
	If(![String]::IsNullOrEmpty($From) -and ![String]::IsNullOrEmpty($To) -and [String]::IsNullOrEmpty($SmtpServer))
	{
		Write-Error "
		`n`n
		`t`t
		You specified From and To email addresses but did not include the SmtpServer.
		`n`n
		`t`t
		Script cannot continue.
		`n`n"
		Exit
	}
	If(![String]::IsNullOrEmpty($From) -and [String]::IsNullOrEmpty($SmtpServer))
	{
		Write-Error "
		`n`n
		`t`t
		You specified a From email address but did not include the SmtpServer.
		`n`n
		`t`t
		Script cannot continue.
		`n`n"
		Exit
	}
	If(![String]::IsNullOrEmpty($To) -and [String]::IsNullOrEmpty($SmtpServer))
	{
		Write-Error "
		`n`n
		`t`t
		You specified a To email address but did not include the SmtpServer.
		`n`n
		`t`t
		Script cannot continue.
		`n`n"
		Exit
	}
    Write-Verbose "$(Get-Date): Setting up script"

    If($Folder -ne "")
    {
	    Write-Verbose "$(Get-Date): Testing folder path"
	    #does it exist
	    If(Test-Path $Folder -EA 0)
	    {
		    #it exists, now check to see if it is a folder and not a file
		    If(Test-Path $Folder -pathType Container -EA 0)
		    {
			    #it exists and it is a folder
			    Write-Verbose "$(Get-Date): Folder path $Folder exists and is a folder"
		    }
		    Else
		    {
			    #it exists but it is a file not a folder
			    Write-Error "
				`n`n
				`t`t
				Folder $Folder is a file, not a folder.
				`n`n
				`t`t
				Script cannot continue.
				`n`n
				"
			    Exit
		    }
	    }
	    Else
	    {
		    #does not exist
		    Write-Error "
			`n`n
			`t`t
			Folder $Folder does not exist.
			`n`n
			`t`t
			Script cannot continue.
			`n`n
			"
		    Exit
	    }
    }

    If($Folder -eq "")
    {
	    $Script:pwdpath = $pwd.Path
    }
    Else
    {
	    $Script:pwdpath = $Folder
    }

	If($Script:pwdpath.EndsWith("\"))
	{
		#remove the trailing \
		$Script:pwdpath = $Script:pwdpath.SubString(0, ($Script:pwdpath.Length - 1))
	}

	If($Log) 
	{
		#start transcript logging
		$Script:LogPath = "$($Script:pwdpath)\GetDNSInfoScriptTranscript_$(Get-Date -f yyyy-MM-dd_HHmm).txt"
		
		try 
		{
			Start-Transcript -Path $Script:LogPath -Force -Verbose:$false | Out-Null
			Write-Verbose "$(Get-Date): Transcript/log started at $Script:LogPath"
			$Script:StartLog = $true
		} 
		catch 
		{
			Write-Verbose "$(Get-Date): Transcript/log failed at $Script:LogPath"
			$Script:StartLog = $false
		}
	}

	If($Dev)
	{
		$Error.Clear()
		$Script:DevErrorFile = "$($Script:pwdpath)\GetDNSInfoScriptErrors_$(Get-Date -f yyyy-MM-dd_HHmm).txt"
	}

	$DNSFileCSV = "$($Script:pwdpath)\DNSInfo.csv" 
	$Script:DNSInfoCSV = New-Object System.Collections.ArrayList	

    $ComputerNamesFile = "$($Script:pwdpath)\ComputerNames.txt"
    Out-File -FilePath $ComputerNamesFile -InputObject $Null 4>$Null
	
	[string]$Script:Title = "Computer DNS Info"
	[string]$Script:RunningOS = (Get-WmiObject -class Win32_OperatingSystem -EA 0).Caption

    $startTime = Get-Date

	Write-Verbose "$(Get-Date): "
	Write-Verbose "$(Get-Date): "
	Write-Verbose "$(Get-Date): Dev                : $($Dev)"
	Write-Verbose "$(Get-Date): Folder             : $($Script:pwdpath)"
	Write-Verbose "$(Get-Date): From               : $($From)"
	Write-Verbose "$(Get-Date): Log                : $($Log)"
	Write-Verbose "$(Get-Date): DNSFileCSV         : $($DNSFileCSV)"
	Write-Verbose "$(Get-Date): ScriptInfo         : $($ScriptInfo)"
	Write-Verbose "$(Get-Date): Smtp Port          : $($SmtpPort)"
	Write-Verbose "$(Get-Date): Smtp Server        : $($SmtpServer)"
	Write-Verbose "$(Get-Date): Title              : $($Script:Title)"
	Write-Verbose "$(Get-Date): To                 : $($To)"
	Write-Verbose "$(Get-Date): Use SSL            : $($UseSSL)"
	Write-Verbose "$(Get-Date): "
	Write-Verbose "$(Get-Date): OS Detected        : $($Script:RunningOS)"
	Write-Verbose "$(Get-Date): PoSH version       : $($Host.Version)"
	Write-Verbose "$(Get-Date): PSCulture          : $($PSCulture)"
	Write-Verbose "$(Get-Date): PSUICulture        : $($PSUICulture)"
	Write-Verbose "$(Get-Date): "
	Write-Verbose "$(Get-Date): Script start       : $($Script:StartTime)"
	Write-Verbose "$(Get-Date): "
	Write-Verbose "$(Get-Date): "

	#region email Function
	Function SendEmail
	{
		Param([array]$Attachments)
		Write-Verbose "$(Get-Date): Prepare to email"

		$emailAttachment = $Attachments
		$emailSubject = $Script:Title
	$emailBody = @"
Hello, <br />
<br />
$Script:Title is attached.

"@ 

		If($Dev)
		{
			Out-File -FilePath $Script:DevErrorFile -InputObject $error 4>$Null
		}

		$error.Clear()
		
		If($From -Like "anonymous@*")
		{
			#https://serverfault.com/questions/543052/sending-unauthenticated-mail-through-ms-exchange-with-powershell-windows-server
			$anonUsername = "anonymous"
			$anonPassword = ConvertTo-SecureString -String "anonymous" -AsPlainText -Force
			$anonCredentials = New-Object System.Management.Automation.PSCredential($anonUsername,$anonPassword)

			If($UseSSL)
			{
				Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
				-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To `
				-UseSSL -credential $anonCredentials *>$Null 
			}
			Else
			{
				Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
				-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To `
				-credential $anonCredentials *>$Null 
			}
			
			If($?)
			{
				Write-Verbose "$(Get-Date): Email successfully sent using anonymous credentials"
			}
			ElseIf(!$?)
			{
				$e = $error[0]

				Write-Verbose "$(Get-Date): Email was not sent:"
				Write-Warning "$(Get-Date): Exception: $e.Exception" 
			}
		}
		Else
		{
			If($UseSSL)
			{
				Write-Verbose "$(Get-Date): Trying to send email using current user's credentials with SSL"
				Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
				-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To `
				-UseSSL *>$Null
			}
			Else
			{
				Write-Verbose "$(Get-Date): Trying to send email using current user's credentials without SSL"
				Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
				-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To *>$Null
			}

			If(!$?)
			{
				$e = $error[0]
				
				#error 5.7.57 is O365 and error 5.7.0 is gmail
				If($null -ne $e.Exception -and $e.Exception.ToString().Contains("5.7"))
				{
					#The server response was: 5.7.xx SMTP; Client was not authenticated to send anonymous mail during MAIL FROM
					Write-Verbose "$(Get-Date): Current user's credentials failed. Ask for usable credentials."

					If($Dev)
					{
						Out-File -FilePath $Script:DevErrorFile -InputObject $error -Append 4>$Null
					}

					$error.Clear()

					$emailCredentials = Get-Credential -UserName $From -Message "Enter the password to send email"

					If($UseSSL)
					{
						Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
						-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To `
						-UseSSL -credential $emailCredentials *>$Null 
					}
					Else
					{
						Send-MailMessage -Attachments $emailAttachment -Body $emailBody -BodyAsHtml -From $From `
						-Port $SmtpPort -SmtpServer $SmtpServer -Subject $emailSubject -To $To `
						-credential $emailCredentials *>$Null 
					}

					If($?)
					{
						Write-Verbose "$(Get-Date): Email successfully sent using new credentials"
					}
					ElseIf(!$?)
					{
						$e = $error[0]

						Write-Verbose "$(Get-Date): Email was not sent:"
						Write-Warning "$(Get-Date): Exception: $e.Exception" 
					}
				}
				Else
				{
					Write-Verbose "$(Get-Date): Email was not sent:"
					Write-Warning "$(Get-Date): Exception: $e.Exception" 
				}
			}
		}
	}
	#endregion

	Function ProcessComputer
	{
		Param
		(
		[String] $Name
		)

		$ComputerName = $Name.Trim()
		Write-Verbose "$(Get-Date): Processing computer $($ComputerName)"
		$TestResult = Test-NetConnection -ComputerName $ComputerName -Port 139 -EA 0 3>$Null 4>$Null

		If(($TestResult.PingSucceeded -eq $true) -or ($TestResult.PingSucceeded -eq $False -and $TestResult.TcpTestSucceeded -eq $True))
		{
			If($TestResult.TcpTestSucceeded)
			{
				$parameters = @{}
				$parameters.Class        = 'Win32_NetworkAdapterSetting'
				$parameters.ErrorAction  = 'SilentlyContinue'
				$parameters.ComputerName = $computername

				try
				{
					$nicSettings = Get-WMIObject @parameters

					foreach( $nic in $nicSettings )
					{
						$server, $namespace, $class, $filter = parsePath $nic.Element

						$wmiParams              = @{}
						$wmiParams.Namespace    = $namespace
						$wmiParams.ComputerName = $server
						$wmiParams.Class        = $class
						$wmiParams.Filter       = $filter

						$item = Get-WMIObject @wmiParams

						If( $item.AdapterType -eq 'Ethernet 802.3' )
						{
							$server, $namespace, $class, $filter = parsePath $nic.Setting

							$wmiParams              = @{}
							$wmiParams.Namespace    = $namespace
							$wmiParams.ComputerName = $server
							$wmiParams.Class        = $class
							$wmiParams.Filter       = $filter

							$itemConfig = Get-WMIObject @wmiParams
							If( $itemConfig.IPEnabled -eq $false )
							{
								Continue
							}

							If( $itemConfig.DHCPEnabled -eq $true )
							{
								Continue
							}

							Out-File -FilePath $ComputerNamesFile -Append -InputObject "$($itemConfig.DNSHostName) successfully processed" 4>$Null 
							
							$obj1 = [PSCustomObject] @{
								DNSHostName                = $itemConfig.DNSHostName
								InterfaceName              = $item.NetConnectionId
								MACAddress                 = "$($itemConfig.MACAddress)"
								IPAddress                  = "$($itemConfig.IPAddress)"
								IPSubnet                   = "$($itemConfig.IPSubnet)"
								DefaultIPGateway           = "$($itemConfig.DefaultIPGateway)"
								DNSServerSearchOrder       = "$($itemConfig.DNSServerSearchOrder)"
								DNSDomainSuffixSearchOrder = "$($itemConfig.DNSDomainSuffixSearchOrder)"
							}
							$null = $Script:DNSInfoCSV.Add($obj1)
						}
					}
				}
				
				catch
				{
					Write-Verbose "$(Get-Date): `tComputer $Computer is not accessible"
					Out-File -FilePath $ComputerNamesFile -Append -InputObject "Computer $Computer was not accessible" 4>$Null
				}
			}
		}
		Else
		{
			If($TestResult.PingSucceeded -eq $False -and $Null -eq $TestResult.RemoteAddress)
			{
				Write-Verbose "$(Get-Date): `tComputer $ComputerName was not found in DNS"
				Out-File -FilePath $ComputerNamesFile -Append -InputObject "Computer $Computer was not found in DNS" 4>$Null
			}
			Else
			{
				Write-Verbose "$(Get-Date): `tComputer $Computer is not online"
				Out-File -FilePath $ComputerNamesFile -Append -InputObject "Computer $Computer was not online" 4>$Null
			}
		}
	}
}

Process
{
    If($Name -is [array])
    {
        ForEach($Computer in $Name)
        {
			ProcessComputer $Computer
        }
    }
    Else
    {
		ProcessComputer $Name
    }
}

End
{
	$Script:DNSInfoCSV = $Script:DNSInfoCSV | Sort-Object DNSHostName
	
	$Script:DNSInfoCSV | Export-CSV -Force -Encoding ASCII -NoTypeInformation -Path $DNSFileCSV *> $Null

	$emailattachments = @()
    If(Test-Path "$($DNSFileCSV)")
    {
	    Write-Verbose "$(Get-Date): $($DNSFileCSV) is ready for use"
		If(![System.String]::IsNullOrEmpty( $SmtpServer ))
		{
			$emailattachments += $DNSFileCSV
		}
	}

    If(Test-Path "$($ComputerNamesFile)")
    {
	    Write-Verbose "$(Get-Date): $($ComputerNamesFile) is ready for use"
		If(![System.String]::IsNullOrEmpty( $SmtpServer ))
		{
			$emailattachments += $ComputerNamesFile
		}
	}

	If(![System.String]::IsNullOrEmpty( $SmtpServer ))
	{
		SendEmail $emailattachments
	}
	
	Write-Verbose "$(Get-Date): Script has completed"
	Write-Verbose "$(Get-Date): "

    Write-Verbose "$(Get-Date): Script started: $($StartTime)"
    Write-Verbose "$(Get-Date): Script ended: $(Get-Date)"
    $runtime = $(Get-Date) - $StartTime
    $Str = [string]::format("{0} days, {1} hours, {2} minutes, {3}.{4} seconds", `
	    $runtime.Days, `
	    $runtime.Hours, `
	    $runtime.Minutes, `
	    $runtime.Seconds,
	    $runtime.Milliseconds)
    Write-Verbose "$(Get-Date): Elapsed time: $($Str)"

	If($Dev)
	{
		If($SmtpServer -eq "")
		{
			Out-File -FilePath $Script:DevErrorFile -InputObject $error 4>$Null
		}
		Else
		{
			Out-File -FilePath $Script:DevErrorFile -InputObject $error -Append 4>$Null
		}
	}

	If($ScriptInfo)
	{
		$SIFile = "$Script:pwdpath\GetDNSInfoScriptInfo_$(Get-Date -f yyyy-MM-dd_HHmm).txt"
		Out-File -FilePath $SIFile -InputObject "" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Dev                : $($Dev)" 4>$Null
		If($Dev)
		{
			Out-File -FilePath $SIFile -Append -InputObject "DevErrorFile       : $($Script:DevErrorFile)" 4>$Null
		}
		Out-File -FilePath $SIFile -Append -InputObject "DNSFileCSV         : $($DNSFileCSV)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Folder             : $($Folder)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "From               : $($From)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Log                : $($Log)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Script Info        : $($ScriptInfo)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Smtp Port          : $($SmtpPort)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Smtp Server        : $($SmtpServer)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Title              : $($Script:Title)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "To                 : $($To)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Use SSL            : $($UseSSL)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "OS Detected        : $($Script:RunningOS)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "PoSH version       : $($Host.Version)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "PSCulture          : $($PSCulture)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "PSUICulture        : $($PSUICulture)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Script start       : $($Script:StartTime)" 4>$Null
		Out-File -FilePath $SIFile -Append -InputObject "Elapsed time       : $($Str)" 4>$Null
	}

	#stop transcript logging
	If($Log -eq $True) 
	{
		If($Script:StartLog -eq $true) 
		{
			try 
			{
				Stop-Transcript | Out-Null
				Write-Verbose "$(Get-Date): $Script:LogPath is ready for use"
			} 
			catch 
			{
				Write-Verbose "$(Get-Date): Transcript/log stop failed"
			}
		}
	}

	$runtime = $Null
	$Str = $Null
}

# SIG # Begin signature block
# MIIf8QYJKoZIhvcNAQcCoIIf4jCCH94CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbJ9AEmGy7qWVtQcOT3pr7Vyw
# iHagghtYMIIDtzCCAp+gAwIBAgIQDOfg5RfYRv6P5WD8G/AwOTANBgkqhkiG9w0B
# AQUFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMDYxMTEwMDAwMDAwWhcNMzExMTEwMDAwMDAwWjBlMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3Qg
# Q0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCtDhXO5EOAXLGH87dg
# +XESpa7cJpSIqvTO9SA5KFhgDPiA2qkVlTJhPLWxKISKityfCgyDF3qPkKyK53lT
# XDGEKvYPmDI2dsze3Tyoou9q+yHyUmHfnyDXH+Kx2f4YZNISW1/5WBg1vEfNoTb5
# a3/UsDg+wRvDjDPZ2C8Y/igPs6eD1sNuRMBhNZYW/lmci3Zt1/GiSw0r/wty2p5g
# 0I6QNcZ4VYcgoc/lbQrISXwxmDNsIumH0DJaoroTghHtORedmTpyoeb6pNnVFzF1
# roV9Iq4/AUaG9ih5yLHa5FcXxH4cDrC0kqZWs72yl+2qp/C3xag/lRbQ/6GW6whf
# GHdPAgMBAAGjYzBhMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB0G
# A1UdDgQWBBRF66Kv9JLLgjEtUYunpyGd823IDzAfBgNVHSMEGDAWgBRF66Kv9JLL
# gjEtUYunpyGd823IDzANBgkqhkiG9w0BAQUFAAOCAQEAog683+Lt8ONyc3pklL/3
# cmbYMuRCdWKuh+vy1dneVrOfzM4UKLkNl2BcEkxY5NM9g0lFWJc1aRqoR+pWxnmr
# EthngYTffwk8lOa4JiwgvT2zKIn3X/8i4peEH+ll74fg38FnSbNd67IJKusm7Xi+
# fT8r87cmNW1fiQG2SVufAQWbqz0lwcy2f8Lxb4bG+mRo64EtlOtCt/qMHt1i8b5Q
# Z7dsvfPxH2sMNgcWfzd8qVttevESRmCD1ycEvkvOl77DZypoEd+A5wwzZr8TDRRu
# 838fYxAe+o0bJW1sj6W3YQGx0qMmoRBxna3iw/nDmVG3KwcIzi7mULKn+gpFL6Lw
# 8jCCBSYwggQOoAMCAQICEAZY+tvHeDVvdG/HsafuSKwwDQYJKoZIhvcNAQELBQAw
# cjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQ
# d3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVk
# IElEIENvZGUgU2lnbmluZyBDQTAeFw0xOTEwMTUwMDAwMDBaFw0yMDEyMDQxMjAw
# MDBaMGMxCzAJBgNVBAYTAlVTMRIwEAYDVQQIEwlUZW5uZXNzZWUxEjAQBgNVBAcT
# CVR1bGxhaG9tYTEVMBMGA1UEChMMQ2FybCBXZWJzdGVyMRUwEwYDVQQDEwxDYXJs
# IFdlYnN0ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDCib5DeGTG
# 3J70a2CA8i9n+dPsDklvWpkUTAuZesMTdgYYYKJTsaaNY/UEAHlJukWzaoFQUJc8
# cf5mUa48zGHKjIsFRJtv1YjaeoJzdLBWiqSaI6m3Ttkj8YqvAVj7U3wDNc30gWgU
# eJwPQs2+Ge6tVHRx7/Knzu12RkJ/fEUwoqwHyL5ezfBHfIf3AiukAxRMKrsqGMPI
# 20y/mc8oiwTuyCG9vieR9+V+iq+ATGgxxb+TOzRoxyFsYOcqnGv3iHqNr74y+rfC
# /HfkieCRmkwh0ss4EVnKIJMefWIlkH3HPirYn+4wmeTKQZmtIq0oEbJlXsSryOXW
# i/NjGfe2xXENAgMBAAGjggHFMIIBwTAfBgNVHSMEGDAWgBRaxLl7KgqjpepxA8Bg
# +S32ZXUOWDAdBgNVHQ4EFgQUqRd4UyWyhbxwBUPJhcJf/q5IdaQwDgYDVR0PAQH/
# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGA1UdHwRwMG4wNaAzoDGGL2h0
# dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMDWg
# M6Axhi9odHRwOi8vY3JsNC5kaWdpY2VydC5jb20vc2hhMi1hc3N1cmVkLWNzLWcx
# LmNybDBMBgNVHSAERTBDMDcGCWCGSAGG/WwDATAqMCgGCCsGAQUFBwIBFhxodHRw
# czovL3d3dy5kaWdpY2VydC5jb20vQ1BTMAgGBmeBDAEEATCBhAYIKwYBBQUHAQEE
# eDB2MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wTgYIKwYB
# BQUHMAKGQmh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFNIQTJB
# c3N1cmVkSURDb2RlU2lnbmluZ0NBLmNydDAMBgNVHRMBAf8EAjAAMA0GCSqGSIb3
# DQEBCwUAA4IBAQBMkLEdY3RRV97ghwUHUZlBdZ9dFFjBx6WB3rAGTeS2UaGlZuwj
# 2zigbOf8TAJGXiT4pBIZ17X01rpbopIeGGW6pNEUIQQlqaXHQUsY8kbjwVVSdQki
# c1ZwNJoGdgsE50yxPYq687+LR1rgViKuhkTN79ffM5kuqofxoGByxgbinRbC3PQp
# H3U6c1UhBRYAku/l7ev0dFvibUlRgV4B6RjQBylZ09+rcXeT+GKib13Ma6bjcKTq
# qsf9PgQ6P5/JNnWdy19r10SFlsReHElnnSJeRLAptk9P7CRU5/cMkI7CYAR0GWdn
# e1/Kdz6FwvSJl0DYr1p0utdyLRVpgHKG30bTMIIFMDCCBBigAwIBAgIQBAkYG1/V
# u2Z1U0O1b5VQCDANBgkqhkiG9w0BAQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UE
# ChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYD
# VQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcNMTMxMDIyMTIwMDAw
# WhcNMjgxMDIyMTIwMDAwWjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdp
# Q2VydCBTSEEyIEFzc3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEA+NOzHH8OEa9ndwfTCzFJGc/Q+0WZsTrbRPV/
# 5aid2zLXcep2nQUut4/6kkPApfmJ1DcZ17aq8JyGpdglrA55KDp+6dFn08b7KSfH
# 03sjlOSRI5aQd4L5oYQjZhJUM1B0sSgmuyRpwsJS8hRniolF1C2ho+mILCCVrhxK
# hwjfDPXiTWAYvqrEsq5wMWYzcT6scKKrzn/pfMuSoeU7MRzP6vIK5Fe7SrXpdOYr
# /mzLfnQ5Ng2Q7+S1TqSp6moKq4TzrGdOtcT3jNEgJSPrCGQ+UpbB8g8S9MWOD8Gi
# 6CxR93O8vYWxYoNzQYIH5DiLanMg0A9kczyen6Yzqf0Z3yWT0QIDAQABo4IBzTCC
# AckwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAww
# CgYIKwYBBQUHAwMweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8v
# b2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6
# MHgwOqA4oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3Vy
# ZWRJRFJvb3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwTwYDVR0gBEgwRjA4BgpghkgBhv1s
# AAIEMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMw
# CgYIYIZIAYb9bAMwHQYDVR0OBBYEFFrEuXsqCqOl6nEDwGD5LfZldQ5YMB8GA1Ud
# IwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMA0GCSqGSIb3DQEBCwUAA4IBAQA+
# 7A1aJLPzItEVyCx8JSl2qB1dHC06GsTvMGHXfgtg/cM9D8Svi/3vKt8gVTew4fbR
# knUPUbRupY5a4l4kgU4QpO4/cY5jDhNLrddfRHnzNhQGivecRk5c/5CxGwcOkRX7
# uq+1UcKNJK4kxscnKqEpKBo6cSgCPC6Ro8AlEeKcFEehemhor5unXCBc2XGxDI+7
# qPjFEmifz0DLQESlE/DmZAwlCEIysjaKJAL+L3J+HNdJRZboWR3p+nRka7LrZkPa
# s7CM1ekN3fYBIM6ZMWM9CBoYs4GbT8aTEAb8B4H6i9r5gkn3Ym6hU/oSlBiFLpKR
# 6mhsRDKyZqHnGKSaZFHvMIIGajCCBVKgAwIBAgIQAwGaAjr/WLFr1tXq5hfwZjAN
# BgkqhkiG9w0BAQUFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQg
# SW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2Vy
# dCBBc3N1cmVkIElEIENBLTEwHhcNMTQxMDIyMDAwMDAwWhcNMjQxMDIyMDAwMDAw
# WjBHMQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGlnaUNlcnQxJTAjBgNVBAMTHERp
# Z2lDZXJ0IFRpbWVzdGFtcCBSZXNwb25kZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IB
# DwAwggEKAoIBAQCjZF38fLPggjXg4PbGKuZJdTvMbuBTqZ8fZFnmfGt/a4ydVfiS
# 457VWmNbAklQ2YPOb2bu3cuF6V+l+dSHdIhEOxnJ5fWRn8YUOawk6qhLLJGJzF4o
# 9GS2ULf1ErNzlgpno75hn67z/RJ4dQ6mWxT9RSOOhkRVfRiGBYxVh3lIRvfKDo2n
# 3k5f4qi2LVkCYYhhchhoubh87ubnNC8xd4EwH7s2AY3vJ+P3mvBMMWSN4+v6GYeo
# fs/sjAw2W3rBerh4x8kGLkYQyI3oBGDbvHN0+k7Y/qpA8bLOcEaD6dpAoVk62RUJ
# V5lWMJPzyWHM0AjMa+xiQpGsAsDvpPCJEY93AgMBAAGjggM1MIIDMTAOBgNVHQ8B
# Af8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDCC
# Ab8GA1UdIASCAbYwggGyMIIBoQYJYIZIAYb9bAcBMIIBkjAoBggrBgEFBQcCARYc
# aHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCCAWQGCCsGAQUFBwICMIIBVh6C
# AVIAQQBuAHkAIAB1AHMAZQAgAG8AZgAgAHQAaABpAHMAIABDAGUAcgB0AGkAZgBp
# AGMAYQB0AGUAIABjAG8AbgBzAHQAaQB0AHUAdABlAHMAIABhAGMAYwBlAHAAdABh
# AG4AYwBlACAAbwBmACAAdABoAGUAIABEAGkAZwBpAEMAZQByAHQAIABDAFAALwBD
# AFAAUwAgAGEAbgBkACAAdABoAGUAIABSAGUAbAB5AGkAbgBnACAAUABhAHIAdAB5
# ACAAQQBnAHIAZQBlAG0AZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkAbQBpAHQAIABs
# AGkAYQBiAGkAbABpAHQAeQAgAGEAbgBkACAAYQByAGUAIABpAG4AYwBvAHIAcABv
# AHIAYQB0AGUAZAAgAGgAZQByAGUAaQBuACAAYgB5ACAAcgBlAGYAZQByAGUAbgBj
# AGUALjALBglghkgBhv1sAxUwHwYDVR0jBBgwFoAUFQASKxOYspkH7R7for5XDStn
# As0wHQYDVR0OBBYEFGFaTSS2STKdSip5GoNL9B6Jwcp9MH0GA1UdHwR2MHQwOKA2
# oDSGMmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRENB
# LTEuY3JsMDigNqA0hjJodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRB
# c3N1cmVkSURDQS0xLmNybDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0
# dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2Vy
# dHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0EtMS5jcnQwDQYJKoZI
# hvcNAQEFBQADggEBAJ0lfhszTbImgVybhs4jIA+Ah+WI//+x1GosMe06FxlxF82p
# G7xaFjkAneNshORaQPveBgGMN/qbsZ0kfv4gpFetW7easGAm6mlXIV00Lx9xsIOU
# GQVrNZAQoHuXx/Y/5+IRQaa9YtnwJz04HShvOlIJ8OxwYtNiS7Dgc6aSwNOOMdgv
# 420XEwbu5AO2FKvzj0OncZ0h3RTKFV2SQdr5D4HRmXQNJsQOfxu19aDxxncGKBXp
# 2JPlVRbwuwqrHNtcSCdmyKOLChzlldquxC5ZoGHd2vNtomHpigtt7BIYvfdVVEAD
# kitrwlHCCkivsNRu4PQUCjob4489yq9qjXvc2EQwggbNMIIFtaADAgECAhAG/fkD
# lgOt6gAK6z8nu7obMA0GCSqGSIb3DQEBBQUAMGUxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAi
# BgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0wNjExMTAwMDAw
# MDBaFw0yMTExMTAwMDAwMDBaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERp
# Z2lDZXJ0IEFzc3VyZWQgSUQgQ0EtMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
# AQoCggEBAOiCLZn5ysJClaWAc0Bw0p5WVFypxNJBBo/JM/xNRZFcgZ/tLJz4Flnf
# nrUkFcKYubR3SdyJxArar8tea+2tsHEx6886QAxGTZPsi3o2CAOrDDT+GEmC/sfH
# MUiAfB6iD5IOUMnGh+s2P9gww/+m9/uizW9zI/6sVgWQ8DIhFonGcIj5BZd9o8dD
# 3QLoOz3tsUGj7T++25VIxO4es/K8DCuZ0MZdEkKB4YNugnM/JksUkK5ZZgrEjb7S
# zgaurYRvSISbT0C58Uzyr5j79s5AXVz2qPEvr+yJIvJrGGWxwXOt1/HYzx4KdFxC
# uGh+t9V3CidWfA9ipD8yFGCV/QcEogkCAwEAAaOCA3owggN2MA4GA1UdDwEB/wQE
# AwIBhjA7BgNVHSUENDAyBggrBgEFBQcDAQYIKwYBBQUHAwIGCCsGAQUFBwMDBggr
# BgEFBQcDBAYIKwYBBQUHAwgwggHSBgNVHSAEggHJMIIBxTCCAbQGCmCGSAGG/WwA
# AQQwggGkMDoGCCsGAQUFBwIBFi5odHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9zc2wt
# Y3BzLXJlcG9zaXRvcnkuaHRtMIIBZAYIKwYBBQUHAgIwggFWHoIBUgBBAG4AeQAg
# AHUAcwBlACAAbwBmACAAdABoAGkAcwAgAEMAZQByAHQAaQBmAGkAYwBhAHQAZQAg
# AGMAbwBuAHMAdABpAHQAdQB0AGUAcwAgAGEAYwBjAGUAcAB0AGEAbgBjAGUAIABv
# AGYAIAB0AGgAZQAgAEQAaQBnAGkAQwBlAHIAdAAgAEMAUAAvAEMAUABTACAAYQBu
# AGQAIAB0AGgAZQAgAFIAZQBsAHkAaQBuAGcAIABQAGEAcgB0AHkAIABBAGcAcgBl
# AGUAbQBlAG4AdAAgAHcAaABpAGMAaAAgAGwAaQBtAGkAdAAgAGwAaQBhAGIAaQBs
# AGkAdAB5ACAAYQBuAGQAIABhAHIAZQAgAGkAbgBjAG8AcgBwAG8AcgBhAHQAZQBk
# ACAAaABlAHIAZQBpAG4AIABiAHkAIAByAGUAZgBlAHIAZQBuAGMAZQAuMAsGCWCG
# SAGG/WwDFTASBgNVHRMBAf8ECDAGAQH/AgEAMHkGCCsGAQUFBwEBBG0wazAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290
# Q0EuY3J0MIGBBgNVHR8EejB4MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3Js
# NC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMB0GA1Ud
# DgQWBBQVABIrE5iymQftHt+ivlcNK2cCzTAfBgNVHSMEGDAWgBRF66Kv9JLLgjEt
# UYunpyGd823IDzANBgkqhkiG9w0BAQUFAAOCAQEARlA+ybcoJKc4HbZbKa9Sz1Lp
# MUerVlx71Q0LQbPv7HUfdDjyslxhopyVw1Dkgrkj0bo6hnKtOHisdV0XFzRyR4WU
# VtHruzaEd8wkpfMEGVWp5+Pnq2LN+4stkMLA0rWUvV5PsQXSDj0aqRRbpoYxYqio
# M+SbOafE9c4deHaUJXPkKqvPnHZL7V/CSxbkS3BMAIke/MV5vEwSV/5f4R68Al2o
# /vsHOE8Nxl2RuQ9nRc3Wg+3nkg2NsWmMT/tZ4CMP0qquAHzunEIOz5HXJ7cW7g/D
# vXwKoO4sCFWFIrjrGBpN/CohrUkxg0eVd3HcsRtLSxwQnHcUwZ1PL1qVCCkQJjGC
# BAMwggP/AgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
# bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0
# IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0ECEAZY+tvHeDVvdG/Hsafu
# SKwwCQYFKw4DAhoFAKBAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMCMGCSqG
# SIb3DQEJBDEWBBTTQPNt8FShF0btUkYO0IEBsXRbLDANBgkqhkiG9w0BAQEFAASC
# AQAdkZvGNnaf6+qgzS/S+JWe+eAFbTXWgNcpcOwY1NPzxzjjG+6ohN3aIHofj+z5
# uB3Ux/opYjLFPEeaGTbDJNTjZcAFoS5qq7qA5dn1ooPnx/tIZuNMCgq3mL59F1C9
# OLfSD5Ne88iuJvjgJbPgDBDoJhxwX2UNpQ60EcTQQcxZAKEeoOnsrCGp4D1k9x7Z
# /X0feNpBIWVoWVbcm51piW5t+Fri3kGTRKnQZrOmGn+Iw27vRASQ2oDRGAvh8lid
# Nyo0tTT4exjPbvv5XXD8rKgBzoNiPsVREWOcC2mfk67DqFUpW/tZ1oX3gKaMdXyy
# CX+aJfHJNb/pVe4aWMhb9nJuoYICDzCCAgsGCSqGSIb3DQEJBjGCAfwwggH4AgEB
# MHYwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgQXNzdXJlZCBJ
# RCBDQS0xAhADAZoCOv9YsWvW1ermF/BmMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0B
# CQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMDEwMzExMjU1MjNaMCMG
# CSqGSIb3DQEJBDEWBBTcTTXzqWyPUnx0UiyyeusE59GmeTANBgkqhkiG9w0BAQEF
# AASCAQBdqb54QPd3EIgNzWRPsC47RVJRQn1t+TGd+v15PDJnYFYrjClhX230t7X3
# b8hlnenGIKPCbchTOh5sN7owk1Zh77JOqzwAeUfe5MfSidrh/fqDEmd+RSrbyXxs
# Vaisdj3Q4UHGoj7FsQNpVQLJy+FV3auewFAJXEWd0kK+09C/A7OC+X2mDv/sQwVp
# E4/ok8Ql8++HSOG5eeQeewJN2ssXAlJdX7UuyOatMwQrCD3BB8uJUnQysLz257gP
# x69WsDCyFWNbV+EQtvsn0aD0U+rI2epUijPX1mPzI0GLpFCfD4r9l5H8oZIg4rZB
# itaxW85uHEQ4ddLt106nfuRivvjX
# SIG # End signature block
