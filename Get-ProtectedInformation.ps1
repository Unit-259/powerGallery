function Get-ProtectedInformation {
    param (
        [string]$Password,
        [string]$IPAddress = (Invoke-RestMethod -Uri "https://api64.ipify.org?format=json").ip
    )

    # Nested helper functions
    function Get-Geolocation {
        param($IP)
        try {
            $uri = "https://freegeoip.app/json/$IP"
            return Invoke-RestMethod -Uri $uri
        } catch {
            Write-Warning "Failed to get geolocation for IP: $IP"
            return $null
        }
    }

    function Resolve-Domains {
        param($IP)
        try {
            return [System.Net.Dns]::GetHostEntry($IP).Aliases
        } catch {
            return @()
        }
    }

    # Collect information
    $output = @()
    $geolocationInfo = Get-Geolocation -IP $IPAddress
    if ($geolocationInfo) {
        $output += "IP Address: $($geolocationInfo.ip)"
        $output += "Country: $($geolocationInfo.country_name)"
        $output += "Region: $($geolocationInfo.region_name)"
        $output += "City: $($geolocationInfo.city)"
        $output += "Latitude: $($geolocationInfo.latitude)"
        $output += "Longitude: $($geolocationInfo.longitude)"
        $output += ""

        $domains = Resolve-Domains -IP $IPAddress
        if ($domains) {
            $output += "Resolved Domains:"
            foreach ($domain in $domains) {
                $output += "  $domain"
            }
        } else {
            $output += "No Domains found for IP: $IPAddress"
        }
    } else {
        $output += "Failed to retrieve geolocation information for IP: $IPAddress"
    }

    # Convert the output array to a single string
    $infoString = $output -join "`n"

    # Encryption logic
    $MessageBytes = [System.Text.Encoding]::ASCII.GetBytes($infoString)
    $PasswordBytes = [System.Text.Encoding]::ASCII.GetBytes($Password)

    # Default Salt - Modify as needed
    [Byte[]]$SaltBytes = @(21,251,43,109,115,57,88,24,249,222,68,134,79,196,197,169)

    $MemoryStream = New-Object System.IO.MemoryStream
    $AES = [System.Security.Cryptography.Aes]::Create()
    $AES.KeySize = 256
    $AES.BlockSize = 128
    $Key = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($PasswordBytes, $SaltBytes, 1000, [System.Security.Cryptography.HashAlgorithmName]::SHA512)
    $AES.Key = $Key.GetBytes($AES.KeySize / 8)
    $AES.IV = $Key.GetBytes($AES.BlockSize / 8)
    $AES.Mode = [System.Security.Cryptography.CipherMode]::CBC

    $CryptoStream = New-Object System.Security.Cryptography.CryptoStream($MemoryStream, $AES.CreateEncryptor(), [System.Security.Cryptography.CryptoStreamMode]::Write)

    try {
        $CryptoStream.Write($MessageBytes, 0, $MessageBytes.Length)
        $CryptoStream.Close()
    } catch {
        Write-Warning "Error occurred while encoding string."
        return $null
    }

    # Convert the encrypted byte array to a hexadecimal string
    $EncryptedBytes = $MemoryStream.ToArray()
    $hexString = ($EncryptedBytes | ForEach-Object { $_.ToString("X2") }) -join ''
    return $hexString
}

# Example usage
$encryptedInfo = Get-ProtectedInformation -Password "YourPassword"
Write-Host "Encrypted Information in Hex: $encryptedInfo"
