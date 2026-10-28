param(
    [int]$Port = 5500,
    [string]$Directory = $PSScriptRoot
)

$ErrorActionPreference = 'Stop'
if (-not $Directory) { $Directory = (Get-Location).Path }

# Find available port
while ($true) {
    try {
        $listener = New-Object System.Net.HttpListener
        $listener.Prefixes.Add("http://127.0.0.1:$Port/")
        $listener.Start()
        break
    } catch {
        Write-Host "Port $Port is busy, trying $($Port + 1)..."
        $Port++
        if ($Port -gt 5550) { throw "No free port found between 5500 and 5550." }
    }
}

Write-Host "=========================================================="
Write-Host "   NFX Portfolio Live-Preview Server Running"
Write-Host "   URL: http://localhost:$Port/"
Write-Host "   Serving from: $Directory"
Write-Host "   Live-Reload: Active (Real-time updates on file save)"
Write-Host "=========================================================="

# Auto-open browser
try {
    Start-Process "http://localhost:$Port/"
} catch {
    Write-Host "Could not auto-launch browser. Please navigate to http://localhost:$Port/"
}

$liveReloadScript = @"
<!-- Live-Reload Script -->
<script>
(function() {
  let lastTime = '';
  async function check() {
    try {
      const res = await fetch('/__livereload__?t=' + Date.now());
      if (res.ok) {
        const time = await res.text();
        if (lastTime && time !== lastTime) {
          console.log('[LiveReload] Change detected, refreshing...');
          window.location.reload();
          return;
        }
        lastTime = time;
      }
      setTimeout(check, 800);
    } catch(e) {
      setTimeout(check, 1500);
    }
  }
  check();
})();
</script>
"@

try {
    while ($listener.IsListening) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response

            $rawUrl = $request.RawUrl.Split('?')[0]

            if ($rawUrl -eq '/__livereload__') {
                $files = Get-ChildItem -Path $Directory -Filter "*.*" -File -Recurse | Where-Object { $_.Extension -match '\.(html|htm|css|js)$' }
                $latest = 0
                foreach ($f in $files) {
                    if ($f.LastWriteTimeUtc.Ticks -gt $latest) { $latest = $f.LastWriteTimeUtc.Ticks }
                }
                $bytes = [System.Text.Encoding]::UTF8.GetBytes("$latest")
                $response.ContentType = "text/plain"
                $response.ContentLength64 = $bytes.Length
                if ($request.HttpMethod -ne 'HEAD') {
                    $response.OutputStream.Write($bytes, 0, $bytes.Length)
                }
                $response.Close()
                continue
            }

            # Resolve local file path
            $relPath = $rawUrl.TrimStart('/')
            if (-not $relPath -or $relPath -eq '') { $relPath = 'index.html' }
            $filePath = Join-Path $Directory $relPath

            if (Test-Path $filePath -PathType Leaf) {
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                $contentType = switch ($ext) {
                    '.html' { 'text/html; charset=utf-8' }
                    '.htm'  { 'text/html; charset=utf-8' }
                    '.css'  { 'text/css; charset=utf-8' }
                    '.js'   { 'application/javascript; charset=utf-8' }
                    '.json' { 'application/json; charset=utf-8' }
                    '.png'  { 'image/png' }
                    '.jpg'  { 'image/jpeg' }
                    '.jpeg' { 'image/jpeg' }
                    '.svg'  { 'image/svg+xml' }
                    '.mp4'  { 'video/mp4' }
                    '.webm' { 'video/webm' }
                    '.woff' { 'font/woff' }
                    '.woff2'{ 'font/woff2' }
                    '.ttf'  { 'font/ttf' }
                    '.otf'  { 'font/otf' }
                    default { 'application/octet-stream' }
                }

                $response.ContentType = $contentType
                $response.AddHeader("Cache-Control", "no-cache, no-store, must-revalidate")
                $response.AddHeader("Pragma", "no-cache")
                $response.AddHeader("Expires", "0")

                if ($ext -in @('.html', '.htm')) {
                    $content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
                    if ($content.Contains('</body>')) {
                        $content = $content.Replace('</body>', "$liveReloadScript`n</body>")
                    } else {
                        $content += "`n$liveReloadScript"
                    }
                    $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
                    $response.ContentLength64 = $bytes.Length
                    if ($request.HttpMethod -ne 'HEAD') {
                        $response.OutputStream.Write($bytes, 0, $bytes.Length)
                    }
                } else {
                    $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
                    $response.ContentLength64 = $fileBytes.Length
                    if ($request.HttpMethod -ne 'HEAD') {
                        $response.OutputStream.Write($fileBytes, 0, $fileBytes.Length)
                    }
                }
            } else {
                $response.StatusCode = 404
                $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
                $response.ContentLength64 = $msg.Length
                if ($request.HttpMethod -ne 'HEAD') {
                    $response.OutputStream.Write($msg, 0, $msg.Length)
                }
            }
            $response.Close()
        } catch {
            # Catch per-request errors and continue serving
            try { if ($response) { $response.Close() } } catch {}
        }
    }
} finally {
    if ($listener) {
        $listener.Stop()
        $listener.Close()
    }
}
