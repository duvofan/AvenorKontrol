# AvenorKontrol - SS araclari indirici
# Kullanim: PowerShell'i yonetici olarak ac ve calistir:
#   powershell -ExecutionPolicy Bypass -File .\AvenorKontrol.ps1

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    if ($PSCommandPath) {
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        exit
    }
    Write-Host "[!] Yonetici olarak calistirman onerilir." -ForegroundColor Yellow
}

$tools = @(
    @{ Name = 'JournalTrace';           Url = 'https://github.com/duvosh/JournalTraceRust/releases/download/v2.5.0/JournalTrace.exe' }
    @{ Name = 'JournalScanner';         Url = 'https://github.com/duvosh/JournalScanner/releases/download/v2.0.4/JournalScanner.exe' }
    @{ Name = 'Everything';             Url = 'https://www.voidtools.com/Everything-1.4.1.1032.x86-Setup.exe' }
    @{ Name = 'SystemInformer';         Url = 'https://github.com/winsiderss/si-builds/releases/download/4.0.26255.346/systeminformer-build-canary-setup.exe' }
    @{ Name = 'USBDeview';              Url = 'https://www.nirsoft.net/utils/usbdeview-x64.zip' }
    @{ Name = 'BrowserDownloadsView';   Url = 'https://www.nirsoft.net/utils/browserdownloadsview-x64.zip' }
    @{ Name = 'JD-GUI';                 Url = 'https://github.com/java-decompiler/jd-gui/releases/download/v1.6.6/jd-gui-1.6.6.jar' }
)
$desktop = [Environment]::GetFolderPath('Desktop')
$root = Join-Path $desktop 'AvenorKontrol'
if (Test-Path -LiteralPath $root) {
    try {
        Remove-Item -LiteralPath $root -Recurse -Force
        Write-Host "  [*] Eski AvenorKontrol silindi." -ForegroundColor Yellow
    } catch {
        Write-Host "  [!] Eski AvenorKontrol silinemedi, icindeki araclar acik olabilir. Kapatip tekrar dene." -ForegroundColor Red
        return
    }
}
New-Item -ItemType Directory -Force -Path $root | Out-Null
if ($isAdmin) {
    try { Add-MpPreference -ExclusionPath $root -ErrorAction Stop } catch { }
}

Write-Host ""
Write-Host "  AvenorKontrol -> $root" -ForegroundColor Cyan
Write-Host ""

function Format-Size([double]$b) {
    if ($b -ge 1MB) { '{0:N1} MB' -f ($b / 1MB) } else { '{0:N0} KB' -f ($b / 1KB) }
}

function Format-Time([double]$s) {
    $ts = [TimeSpan]::FromSeconds([Math]::Ceiling($s))
    '{0:00}:{1:00}' -f [Math]::Floor($ts.TotalMinutes), $ts.Seconds
}

function Write-Line($prefix, $text, $color = 'Gray') {
    Write-Host ("`r$prefix" + $text.PadRight(52)) -NoNewline -ForegroundColor $color
}

function Get-File($url, $dest, $prefix) {
    $req = [Net.HttpWebRequest]::Create($url)
    $req.UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
    $resp = $req.GetResponse()
    try {
        $total = $resp.ContentLength
        $in = $resp.GetResponseStream()
        $out = [IO.File]::Create($dest)
        try {
            $buf = New-Object byte[] 65536
            $done = 0
            $sw = [Diagnostics.Stopwatch]::StartNew()
            $lastDraw = -1000
            while (($n = $in.Read($buf, 0, $buf.Length)) -gt 0) {
                $out.Write($buf, 0, $n)
                $done += $n
                if ($sw.ElapsedMilliseconds - $lastDraw -ge 200) {
                    $lastDraw = $sw.ElapsedMilliseconds
                    $speed = $done / [Math]::Max($sw.Elapsed.TotalSeconds, 0.001)
                    if ($total -gt 0) {
                        $eta = ($total - $done) / [Math]::Max($speed, 1)
                        Write-Line $prefix ('{0,3}%  {1} / {2}  {3}/s  Tahmini: {4}' -f [int]($done * 100 / $total), (Format-Size $done), (Format-Size $total), (Format-Size $speed), (Format-Time $eta))
                    } else {
                        Write-Line $prefix ('{0}  {1}/s' -f (Format-Size $done), (Format-Size $speed))
                    }
                }
            }
            $sw.Stop()
            return @{ Size = $done; Seconds = $sw.Elapsed.TotalSeconds }
        } finally { $out.Close(); $in.Close() }
    } finally { $resp.Close() }
}

$ok = 0
foreach ($t in $tools) {
    $fileName = [IO.Path]::GetFileName(([Uri]$t.Url).AbsolutePath)
    $dest = Join-Path $root $fileName
    $prefix = "  [*] {0,-22}" -f $t.Name
    Write-Host $prefix -NoNewline
    try {
        $r = Get-File $t.Url $dest $prefix
        Unblock-File -Path $dest -ErrorAction SilentlyContinue

        if ($dest -like '*.zip') {
            $out = Join-Path $root $t.Name
            Expand-Archive -Path $dest -DestinationPath $out -Force
            Get-ChildItem $out -Recurse -File | Unblock-File -ErrorAction SilentlyContinue
            Remove-Item $dest -Force
        }
        $avg = $r.Size / [Math]::Max($r.Seconds, 0.001)
        Write-Line $prefix ('OK  {0}  ({1}/s, {2})' -f (Format-Size $r.Size), (Format-Size $avg), (Format-Time $r.Seconds)) 'Green'
        Write-Host ""
        $ok++
    } catch {
        $ex = $_.Exception
        if ($ex.InnerException) { $ex = $ex.InnerException }
        Write-Line $prefix "HATA: $($ex.Message)" 'Red'
        Write-Host ""
    }
}
try {
    Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/duvosh/AvenorKontrol/main/BENI_OKU.txt' -OutFile (Join-Path $root "BEN$([char]0x130) OKU.txt") -UseBasicParsing
} catch { }

Write-Host ""
Write-Host "  $ok / $($tools.Count) arac indirildi." -ForegroundColor Cyan
Start-Process explorer.exe $root
