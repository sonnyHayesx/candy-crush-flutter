# Run from any directory: powershell -ExecutionPolicy Bypass -File tool/build_test_apk.ps1
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot

Push-Location -LiteralPath $projectRoot
try {
    # OneDrive can mark generated directories read-only. Gradle cannot replace
    # those directories even though PowerShell's Remove-Item -Force can.
    $buildPath = Join-Path $projectRoot 'build'
    if (Test-Path -LiteralPath $buildPath) {
        $items = @((Get-Item -LiteralPath $buildPath -Force))
        $items += @(Get-ChildItem -LiteralPath $buildPath -Recurse -Force)
        foreach ($item in $items) {
            if (($item.Attributes -band [IO.FileAttributes]::ReadOnly) -ne 0) {
                $item.Attributes = $item.Attributes -band (-bnot [IO.FileAttributes]::ReadOnly)
            }
        }
    }

    & flutter pub get --enforce-lockfile
    if ($LASTEXITCODE -ne 0) { throw 'Dependency resolution failed.' }
    & flutter build apk --debug
    if ($LASTEXITCODE -ne 0) { throw 'Debug APK build failed. See the Flutter output above.' }
    Write-Host "Testing APK: $(Join-Path $buildPath 'app/outputs/flutter-apk/app-debug.apk')"
} finally {
    Pop-Location
}
