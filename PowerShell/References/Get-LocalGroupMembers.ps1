# ==============================================================================================
# 
# NAME: Get-LocalGroupMembers
# 
# AUTHOR: Ben Baird
# DATE  : 8/12/2011
# 
# COMMENT: 
# Given a machine name, retrieves a list of members in
# the specified group.
# ==============================================================================================

function Get-LocalGroupMembers
{
	param(
		[parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
		[Alias("Name")]
		[string]$ComputerName,
		[string]$GroupName = "Administrators"
	)
	
	begin {}
	
	process
	{
		# If the account name of the computer object was passed in, it will
		# end with a $. Get rid of it so it doesn't screw up the WMI query.
		$ComputerName = $ComputerName.Replace("`$", '')

		# Initialize an array to hold the results of our query.
		$arr = @()

		$wmi = Get-WmiObject -ComputerName $ComputerName -Query `
			"SELECT * FROM Win32_GroupUser WHERE GroupComponent=`"Win32_Group.Domain='$ComputerName',Name='$GroupName'`""

		# Parse out the username from each result and append it to the array.
		if ($wmi -ne $null)
		{
			foreach ($item in $wmi)
			{
				$arr += ($item.PartComponent.Substring($item.PartComponent.IndexOf(',') + 1).Replace('Name=', '').Replace("`"", ''))
			}
		}

		$hash = @{ComputerName=$ComputerName;Members=$arr}
		return $hash
	}
	
	end{}
}
