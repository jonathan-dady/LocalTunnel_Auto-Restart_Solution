# start-tunnel.ps1
# Variables globales
$logFile = "$PSScriptRoot\tunnel-log.txt"
$npxPath = "C:\Program Files\nodejs\npx.cmd"
$envFile = "$PSScriptRoot\.env"
$flagFile = "$PSScriptRoot\stop.flag"

# Lecture du fichier .env
function Get-EnvVariable {
    param($varName, $defaultValue)
    if (Test-Path $envFile) {
        $envContent = Get-Content $envFile -Raw
        $match = [regex]::Match($envContent, "$varName=(.+)")
        if ($match.Success) {
            return $match.Groups[1].Value.Trim()
        }
    }
    return $defaultValue
}

$targetSubdomain = Get-EnvVariable "TUNNEL_SUBDOMAIN" "test-jodady-93"
$targetPort = [int](Get-EnvVariable "TUNNEL_PORT" "4000")

function Write-Log($message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "$timestamp - $message"
}

function Test-PortAvailable {
    param($port)
    try {
        $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Any, $port)
        $listener.Start()
        $listener.Stop()
        return $true
    }
    catch {
        return $false
    }
}

Write-Log ("-" * 50)
Write-Log "Démarrage du script avec :"
Write-Log "npxPath: $npxPath"
Write-Log "targetSubdomain: $targetSubdomain"
Write-Log "targetPort: $targetPort"
Write-Log "Working Directory: $PSScriptRoot"

# Supprimer le fichier stop.flag au démarrage s'il existe
if (Test-Path $flagFile) {
    Remove-Item $flagFile -Force
    Write-Log "Suppression du fichier stop.flag au démarrage"
}

while ($true) {
    if (Test-Path $flagFile) {
        Write-Log "Flag d'arrêt détecté. Fin du script start-tunnel.ps1."
        Remove-Item $flagFile
        break
    }

    if (-not (Test-PortAvailable $targetPort)) {
        Write-Log "Port $targetPort déjà utilisé. Attente de libération..."
        Start-Sleep -Seconds 30
        continue
    }

    Write-Log "Lancement de LocalTunnel via npx avec sous-domaine $targetSubdomain sur le port $targetPort..."

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $npxPath
    $psi.Arguments = "localtunnel --port $targetPort --subdomain $targetSubdomain --verbose"
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.WorkingDirectory = $PSScriptRoot

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi

    try {
        Write-Log "Tentative de démarrage avec command: $($psi.FileName) $($psi.Arguments)"
        $started = $process.Start()
        if ($started) {
            $gotGoodSubdomain = $false
            while (-not $process.HasExited) {
                if (-not $process.StandardOutput.EndOfStream) {
                    $line = $process.StandardOutput.ReadLine()
                    Write-Log "[stdout] $line"
                    
                    if ($line -match "(?i)https://$targetSubdomain\.loca\.lt") {
                        Write-Log "Sous-domaine exact détecté dans la sortie."
                        $gotGoodSubdomain = $true
                    }
                }
                if (-not $process.StandardError.EndOfStream) {
                    $errorLine = $process.StandardError.ReadLine()
                    Write-Log "[stderr] $errorLine"
                }
                Start-Sleep -Milliseconds 200
            }

            if (-not $gotGoodSubdomain) {
                Write-Log "Sous-domaine incorrect attribué. On va relancer..."
            }

            $exitCode = $process.ExitCode
            Write-Log "Tunnel arrêté avec code $exitCode. Redémarrage dans 5 secondes..."
        }
    }
    catch {
        Write-Log "Erreur lors du démarrage : $($_.Exception.Message)"
    }

    Start-Sleep -Seconds 5
}
