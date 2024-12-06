# Install IIS
Write-Host "Installing IIS"
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# Create a test webpage in the default IIS directory
$WebRoot = "C:\inetpub\wwwroot"
$TestPagePath = Join-Path $WebRoot "index.html"

Write-Host "Creating a test webpage"
@"
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to IIS</title>
</head>
<body>
    <h1>Success! IIS is working and your test page is live.</h1>
</body>
</html>
"@ | Out-File -FilePath $TestPagePath -Encoding UTF8

# Verify IIS is running
Write-Host "Ensuring IIS service is running"
Start-Service -Name W3SVC
Set-Service -Name W3SVC -StartupType Automatic

Write-Host "IIS installation and test page setup complete"