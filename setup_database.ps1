param(
    [string]$MysqlPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
    [string]$User = "root"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $MysqlPath)) {
    Write-Host "MySQL was not found at: $MysqlPath" -ForegroundColor Red
    Write-Host "Run again with -MysqlPath pointing to mysql.exe." -ForegroundColor Yellow
    Write-Host 'Example: .\setup_database.ps1 -MysqlPath "C:\xampp\mysql\bin\mysql.exe"'
    exit 1
}

$securePassword = Read-Host "Enter MySQL password for $User" -AsSecureString
$plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
)

$oldPassword = $env:MYSQL_PWD
$env:MYSQL_PWD = $plainPassword

$scripts = @(
    "database\01_create_database.sql",
    "database\02_create_accounts.sql",
    "database\03_create_fleet_tables.sql",
    "database\04_enhance_database.sql",
    "database\06_seed_data.sql"
)

try {
    foreach ($script in $scripts) {
        Write-Host "Loading $script..." -ForegroundColor Cyan
        Get-Content $script | & $MysqlPath -u $User
    }
    Write-Host "Database setup complete." -ForegroundColor Green
}
finally {
    if ($null -eq $oldPassword) {
        Remove-Item Env:\MYSQL_PWD -ErrorAction SilentlyContinue
    }
    else {
        $env:MYSQL_PWD = $oldPassword
    }
}
