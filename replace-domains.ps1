$TargetIP = "127.0.0.1"
$ProjectDir = "D:\zgj\websites\zgx"

Write-Host "========================================="
Write-Host " Replace frog.co -> $TargetIP"
Write-Host "========================================="

$exts = @(".html", ".js", ".txt", ".xml", ".json")
$files = Get-ChildItem -Path $ProjectDir -Recurse -File | Where-Object { $exts -contains $_.Extension }

$totalFiles = $files.Count
$updated = 0
$processed = 0

foreach ($file in $files) {
    $processed++
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    if ($null -eq $content -or $content -eq "") { continue }

    $original = $content

    $content = $content -replace 'https://www\.frog\.co', "http://$TargetIP"
    $content = $content -replace 'http://www\.frog\.co', "http://$TargetIP"
    $content = $content -replace 'https://frog\.co/', "http://$TargetIP/"
    $content = $content -replace "https://frog\.co`"", "http://$TargetIP`""
    $content = $content -replace 'https://wp\.frog\.co', "http://$TargetIP/wp"
    $content = $content -replace 'https://go\.frog\.co', "http://$TargetIP/go"
    $content = $content -replace 'https://frogco\.cn', "http://$TargetIP"
    $content = $content -replace '\.\./www\.frog\.co/', "/"
    $content = $content -replace '\.\./wp\.frog\.co/', "/wp/"
    $content = $content -replace '\.\./go\.frog\.co/', "/go/"
    $content = $content -replace '\.\./\.\./frog\.co/', "/"
    $content = $content -replace '\.\./frog\.co/', "/"

    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
        $updated++
        $rel = $file.FullName.Replace($ProjectDir, "")
        Write-Host "  [$updated] $rel"
    }
}

Write-Host "========================================="
Write-Host " Done! Total: $totalFiles, Updated: $updated"
Write-Host "========================================="