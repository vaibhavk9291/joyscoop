<#
.SYNOPSIS
    Automates iOS Distribution Certificate setup on Windows for GitHub Actions.
.DESCRIPTION
    Step 1: Run to generate a Certificate Signing Request (CSR) on Windows without a Mac.
    Step 2: Upload CSR to developer.apple.com to download distribution.cer.
    Step 3: Run again to convert distribution.cer into ios_distribution.p12 and print the GitHub Actions secret.
#>

param(
    [ValidateSet("GenerateCSR", "ConvertToP12")]
    [string]$Action = "GenerateCSR",

    [string]$Email = "vaibhavkale625@gmail.com",
    [string]$Name = "Vaibhav Kale",
    [string]$P12Password = "Joyscoop2026!"
)

$OpenSSLPath = "C:\Program Files\Git\usr\bin\openssl.exe"
if (-not (Test-Path $OpenSSLPath)) {
    $found = Get-Command openssl -ErrorAction SilentlyContinue
    if ($found) {
        $OpenSSLPath = $found.Source
    } else {
        Write-Error "OpenSSL not found. Please install Git for Windows or OpenSSL."
        exit 1
    }
}

$CurrentDir = Get-Location

if ($Action -eq "GenerateCSR") {
    Write-Host "=== STEP 1: Generating iOS CSR on Windows ===" -ForegroundColor Cyan
    $KeyFile = Join-Path $CurrentDir "ios_distribution.key"
    $CsrFile = Join-Path $CurrentDir "CertificateSigningRequest.certSigningRequest"

    & $OpenSSLPath req -nodes -newkey rsa:2048 -keyout "$KeyFile" -out "$CsrFile" -subj "/CN=$Name/emailAddress=$Email"

    if (Test-Path $CsrFile) {
        Write-Host "`n✓ CSR Generated successfully!" -ForegroundColor Green
        Write-Host "File created: $CsrFile"
        Write-Host "Key created:  $KeyFile"
        Write-Host "`nNEXT STEPS:" -ForegroundColor Yellow
        Write-Host "1. Go to https://developer.apple.com/account/resources/certificates/list"
        Write-Host "2. Click '+' -> Select 'Apple Distribution' -> Click Continue."
        Write-Host "3. Upload '$CsrFile'."
        Write-Host "4. Download the certificate (it will be named 'distribution.cer')."
        Write-Host "5. Move 'distribution.cer' into this project folder ($CurrentDir)."
        Write-Host "6. Run this script again with: powershell -ExecutionPolicy Bypass -File scripts\setup_ios_signing_windows.ps1 -Action ConvertToP12"
    } else {
        Write-Error "Failed to generate CSR."
    }
} elseif ($Action -eq "ConvertToP12") {
    Write-Host "=== STEP 2: Converting distribution.cer to .p12 ===" -ForegroundColor Cyan
    $CerFile = Join-Path $CurrentDir "distribution.cer"
    $KeyFile = Join-Path $CurrentDir "ios_distribution.key"
    $PemFile = Join-Path $CurrentDir "distribution.pem"
    $P12File = Join-Path $CurrentDir "ios_distribution.p12"

    if (-not (Test-Path $CerFile)) {
        Write-Error "Cannot find 'distribution.cer' in $CurrentDir. Please download it from developer.apple.com and place it here."
        exit 1
    }
    if (-not (Test-Path $KeyFile)) {
        Write-Error "Cannot find 'ios_distribution.key' in $CurrentDir. Did you run -Action GenerateCSR first?"
        exit 1
    }

    # 1. Convert CER (DER) to PEM
    & $OpenSSLPath x509 -inform DER -in "$CerFile" -out "$PemFile"

    # 2. Combine PEM and private key into PKCS#12 (.p12)
    & $OpenSSLPath pkcs12 -export -inkey "$KeyFile" -in "$PemFile" -out "$P12File" -passout "pass:$P12Password"

    if (Test-Path $P12File) {
        Write-Host "`n✓ Created $P12File successfully!" -ForegroundColor Green
        $Base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($P12File))

        Write-Host "`n========================================================" -ForegroundColor Cyan
        Write-Host "  COPY THIS VALUE FOR GITHUB SECRET: BUILD_CERTIFICATE_BASE64" -ForegroundColor Yellow
        Write-Host "========================================================" -ForegroundColor Cyan
        Write-Host $Base64
        Write-Host "========================================================" -ForegroundColor Cyan
        Write-Host "  COPY THIS VALUE FOR GITHUB SECRET: P12_PASSWORD" -ForegroundColor Yellow
        Write-Host "========================================================" -ForegroundColor Cyan
        Write-Host $P12Password
        Write-Host "========================================================`n" -ForegroundColor Cyan

        # Cleanup intermediate PEM
        if (Test-Path $PemFile) { Remove-Item $PemFile }
    } else {
        Write-Error "Failed to generate .p12 file."
    }
}
