# stop-tunnel.ps1
$logFile = "$PSScriptRoot\tunnel-log.txt"
$flagFile = "$PSScriptRoot\stop.flag"

function Write-Log($message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "$timestamp - $message"
}

# Créer le flag d'arrêt pour le script start-tunnel.ps1
New-Item -Path $flagFile -ItemType File -Force | Out-Null
Write-Log ("-" * 50)
Write-Log "Création du flag d'arrêt."

# Tuer les processus LocalTunnel (lt)
$ltProcesses = Get-Process -Name lt -ErrorAction SilentlyContinue
if ($ltProcesses) {
    foreach ($p in $ltProcesses) {
        Write-Log "Arrêt du tunnel LocalTunnel (PID $($p.Id), ProcessName $($p.ProcessName))"
        try {
            $p.Kill()
            Write-Log "Processus $($p.Id) tué avec succès."
        } catch {
            Write-Log "Erreur en tuant le processus $($p.Id) : $_"
        }
    }
} else {
    Write-Log "Aucun processus LocalTunnel (lt) trouvé."
}

# Tuer les processus node.exe avec 'lt' dans la ligne de commande
$nodeProcesses = Get-CimInstance Win32_Process | Where-Object {
    $_.Name -eq "node.exe" -and $_.CommandLine -match "lt"
}
if ($nodeProcesses) {
    foreach ($proc in $nodeProcesses) {
        Write-Log "Arrêt du tunnel node.exe (PID $($proc.ProcessId)), CommandLine: $($proc.CommandLine)"
        try {
            Stop-Process -Id $proc.ProcessId -Force
            Write-Log "Processus $($proc.ProcessId) tué avec succès."
        } catch {
            Write-Log "Erreur en tuant le processus $($proc.ProcessId) : $_"
        }
    }
} else {
    Write-Log "Aucun processus node.exe avec 'lt' dans la ligne de commande trouvé."
}

# Tuer les instances start-tunnel.ps1 (powershell.exe)
$powershellProcesses = Get-CimInstance Win32_Process | Where-Object {
    $_.Name -match "powershell.exe" -and $_.CommandLine -match "start-tunnel.ps1"
}
if ($powershellProcesses) {
    foreach ($proc in $powershellProcesses) {
        Write-Log "Arrêt du script start-tunnel.ps1 (PID $($proc.ProcessId)), CommandLine: $($proc.CommandLine)"
        try {
            Stop-Process -Id $proc.ProcessId -Force
            Write-Log "Processus $($proc.ProcessId) tué avec succès."
        } catch {
            Write-Log "Erreur en tuant le processus $($proc.ProcessId) : $_"
        }
    }
} else {
    Write-Log "Aucun processus start-tunnel.ps1 trouvé."
}
