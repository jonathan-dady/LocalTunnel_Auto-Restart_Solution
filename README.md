# LocalTunnel Auto-Restart Solution

## Description
Solution automatisée pour maintenir un tunnel LocalTunnel actif avec redémarrage automatique en cas d'interruption. Idéal pour exposer des services locaux sur Internet de manière fiable et continue.

## Développé par
Jonathan Rabemananoro

## Fonctionnalités
- Redémarrage automatique en cas d'interruption
- Configuration via fichier .env
- Logging détaillé des événements
- Arrêt propre via fichier flag

## Prérequis
1. **Node.js et NPM**
   - Installer depuis [nodejs.org](https://nodejs.org/)
   - Vérifier l'installation :
   ```batch
   node --version
   npm --version
   ```

2. **LocalTunnel**
   ```batch
   npm install -g localtunnel
   ```

## Structure des fichiers
```
tunnel-auto/
├── start-tunnel.ps1
├── .env
└── tunnel-log.txt (généré automatiquement)
```

## Configuration
1. **Fichier .env**
```properties
TUNNEL_SUBDOMAIN=votre-subdomain
TUNNEL_PORT=votre-port
```

## Installation
1. Cloner ou télécharger le dossier
2. Configurer le fichier `.env`
3. Exécuter dans PowerShell (en admin) :
```powershell
Set-ExecutionPolicy RemoteSigned
```

## Utilisation
1. Ouvrir PowerShell en administrateur
2. Naviguer vers le dossier :
```powershell
cd chemin\vers\tunnel-auto
.\start-tunnel.ps1
```

## Arrêt
Naviguer vers le dossier :
```powershell
cd chemin\vers\tunnel-auto
.\stop-tunnel.ps1
```
- Cela va créer un fichier `stop.flag` dans le dossier du script
- Le script s'arrêtera proprement

## Logs
- Les logs sont stockés dans `tunnel-log.txt`
- Permet de suivre l'activité et diagnostiquer les problèmes

## Support
Pour toute question ou problème, contactez Jonathan Rabemananoro.

## Licence
Copyright © 2025 Jonathan