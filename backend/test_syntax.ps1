$ErrorActionPreference = "Stop"
try {
    Write-Host "This is a test."
    $data = @"
    This is indented content.
    Terminator should be at start of line.
"@
    Write-Host "If you see this, syntax is valid."
    Read-Host "Press Enter to exit..."
} catch {
    Write-Host "Error: $_"
    Read-Host "Press Enter to exit..."
}
