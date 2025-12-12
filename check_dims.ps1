$path = "d:\4. Java Project\gameTest2\assets\pixel2d\Entities\Characters\Body_A\Animations\Pierce_Base\Pierce_Side-Sheet.png"
if (Test-Path $path) {
    Add-Type -AssemblyName System.Drawing
    $image = [System.Drawing.Image]::FromFile($path)
    Write-Host "Width: $($image.Width) Height: $($image.Height)"
    $image.Dispose()
} else {
    Write-Host "File not found: $path"
}
