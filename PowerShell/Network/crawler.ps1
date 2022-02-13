############ These can be changed ########################
#Homepage to start the crawl - n.b. the / forwardslash matters....
$homepage = "http://www.theregister.co.uk/"

#Used as validation for relative links, this also stops the site crawling outside of this domain (by breaking the URL for anythign other #than $rawdomain)
$rawdomain = "theregister.co.uk"
$outputfile = "c:\scripts\listofURLs.txt"


#Depth to drill into the website, this is actually the amount of times to loop through the hashtable (While adding new entries as we go)
$loopnumber = 10
#write-host $loopnumber

 ############ End # These can be changed # End ############

#Arrays to contains the data
$UrlHash = @{}
$TempURLHash =@{}
$TempURLHash1 =@{}

#This does the raw crawl of $urls passed into it 
function global:FindURL($url){ 
	return @((invoke-webrequest -uri $url).links.href)
write-host $url
} 


#Add everything after 1st level to the hashtable
function CallFromTheHash ($HashURL) {
	FindUrl -url $HashURL Where-Object { -not $UrlHash[$_] } | ForEach-Object { $UrlHash[$_] = $_ } 

#Logging to screen
get-date
$UrlHash.count
write-host $HashURL
}


 #Add homepage to hashtable
$UrlHash[$homepage] = $homepage 
$UrlHash.count


 #Call funtion with $homepage and add results to hashtable
FindUrl -url $homepage Where-Object { -not $UrlHash[$_] } | ForEach-Object { $UrlHash[$_] = $_ } 



 #Loop through hashtable contents 
$i = 2
For(;$i -le $loopnumber; )
{

#clone the $urlhash hash table to another hashtable so we can loop through and pass to CallFromTheHash where it's added to $urlhash
$masterArray = $urlhash.keys
foreach ($halfurl in $masterArray) {
		$TempURLHash += @{$halfurl = $halfurl}
				   }

 #Add domain to urls in the hashtable
foreach ($newhalfurl in $tempURLHash.keys) {
		#Add domain to URL - validates that the crawl stays on the $rawdomain and all upper domains
		if(-not($newhalfurl.contains($rawdomain))){
		$fullhashurl = $homepage + $newhalfurl}
			CallFromTheHash $fullhashurl
		
					   }
#Hit the loop again - see $loopnumber for the loop count - this will dive another layer into the site, got as deep as you like.
Write-Host "Looping AGAIIIIINNNN" -ForegroundColor red -backgroundcolor DarkYellow
$i++
}

#Get contents of $urlhash and append it into $TempURLHas1 ready for logging
foreach ($urlfrag in $urlhash.keys) {
$fullurl = $urlfrag
$TempURLHash1 += @{$fullurl = $fullurl}
$TempURLHash1.count
}



 #Output of URL results
$TempURLHash1 | out-file -width 900 $outputfile
