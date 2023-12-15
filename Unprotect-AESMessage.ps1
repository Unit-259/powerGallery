function Unprotect-AESMessage {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Message, # Hexadecimal string
        [Parameter(Mandatory=$true)]
        [String]$Password,
        [Parameter(Mandatory=$false)]
        [Byte[]]$Salt,
        [Parameter()]
        [ValidateSet("MD5","SHA1","SHA256","SHA384","SHA512")]
        [String]$HashAlgorithm = "SHA512"
    )

    # Convert Hexadecimal string to Byte array
    $MessageBytes = -split ($Message -replace "..", '0x$& ') | ForEach-Object { [convert]::ToInt32($_, 16) }
    $PasswordBytes = [System.Text.Encoding]::ASCII.GetBytes($Password)

    # Salt must have at least 8 Bytes!
    [Byte[]]$SaltBytes = @(21,251,43,109,115,57,88,24,249,222,68,134,79,196,197,169)
    if ($Salt -and $Salt.Count -ge 8) {
        $SaltBytes = $Salt
    }

    $MemoryStream = New-Object System.IO.MemoryStream
    $AES = [System.Security.Cryptography.Aes]::Create()
    $AES.KeySize = 256
    $AES.BlockSize = 128
    $Key = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($PasswordBytes, $SaltBytes, 1000, [System.Security.Cryptography.HashAlgorithmName]::$HashAlgorithm)
    $AES.Key = $Key.GetBytes($AES.KeySize / 8)
    $AES.IV = $Key.GetBytes($AES.BlockSize / 8)
    $AES.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $CryptoStream = New-Object System.Security.Cryptography.CryptoStream($MemoryStream, $AES.CreateDecryptor(), [System.Security.Cryptography.CryptoStreamMode]::Write)

    try {
        $CryptoStream.Write($MessageBytes, 0, $MessageBytes.Length)
        $CryptoStream.Close()
    } catch [Exception] {
        $Result = "Error occurred while decoding string. Password, Salt, or HashAlgorithm incorrect?"
        return $Result
    }

    $DecryptedBytes = $MemoryStream.ToArray()
    $Result = [System.Text.Encoding]::UTF8.GetString($DecryptedBytes)
    return $Result
}
