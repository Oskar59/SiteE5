
<#
Script de Migration
#>

# ---------------------------------------------------------------------------
# 1. VÉRIFICATION ADMIN
# ---------------------------------------------------------------------------
$identiteActuelle = [Security.Principal.WindowsIdentity]::GetCurrent()
$principalWindows = New-Object Security.Principal.WindowsPrincipal($identiteActuelle)

if (-not $principalWindows.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
Write-Host "Relance en mode Administrateur..." -ForegroundColor Cyan
$argumentsProcessus = "-NoProfile -NoExit -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Definition)`""
Start-Process PowerShell -Verb RunAs -ArgumentList $argumentsProcessus
exit
}

# ---------------------------------------------------------------------------
# 2. CORPS DU SCRIPT
# ---------------------------------------------------------------------------
try {
Clear-Host
Write-Host "==============================================" -ForegroundColor Green
Write-Host " MIGRATION (DONNÉES, WIFI, IMPR., ICÔNES)" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green
Write-Host ""

# --- A. Menu de Choix ---
Write-Host "Action à effectuer :" -ForegroundColor Cyan
Write-Host " [1] SAUVEGARDE (PC -> vers Disque Externe)"
Write-Host " [2] RESTAURATION (Disque Externe -> vers ce PC)"
$choix = Read-Host "Votre choix (1 ou 2)"

if ($choix -ne "1" -and $choix -ne "2") { throw "Choix invalide." }

# --- B. Définition Utilisateur ---
$utilisateurCible = Read-Host "Nom de l'utilisateur Windows (ex: odoutreligne01)"
$cheminProfilUtilisateur = "C:\Users\$utilisateurCible"

if (-not (Test-Path $cheminProfilUtilisateur) -and $choix -eq "1") {
throw "L'utilisateur '$utilisateurCible' n'existe pas sur ce PC."
}

# --- C. Sélection Destination ---
Add-Type -AssemblyName System.Windows.Forms
$selecteurDossier = New-Object System.Windows.Forms.FolderBrowserDialog
$selecteurDossier.Description = "Sélectionnez l'emplacement (Disque Externe ou Dossier Backup)"

$formulairePremierPlan = New-Object System.Windows.Forms.Form
$formulairePremierPlan.TopMost = $true; $formulairePremierPlan.TopLevel = $true

if ($selecteurDossier.ShowDialog($formulairePremierPlan) -eq [System.Windows.Forms.DialogResult]::OK) {
$cheminSelectionne = $selecteurDossier.SelectedPath
} else { exit }

# --- D. Configuration des Chemins ---
if ($choix -eq "1") {
# MODE SAUVEGARDE
$RacineSource = $cheminProfilUtilisateur
$RacineDest = Join-Path -Path $cheminSelectionne -ChildPath "$utilisateurCible-Backup"
$FichierJournal = Join-Path $RacineDest "Journal_Migration.txt"

# Recherche ReIcon
$cheminScript = Split-Path -Parent $MyInvocation.MyCommand.Definition
$cheminReIcon = "$cheminScript\Tools\ReIcon_x64.exe"
if (-not (Test-Path $cheminReIcon)) { $cheminReIcon = "$cheminSelectionne\Tools\ReIcon_x64.exe" }

if (-not (Test-Path $RacineDest)) { New-Item -Path $RacineDest -ItemType Directory | Out-Null }

} else {
# MODE RESTAURATION
$RacineSource = $cheminSelectionne
$RacineDest = $cheminProfilUtilisateur
$FichierJournal = Join-Path $RacineSource "Journal_Migration.txt"

$cheminScript = Split-Path -Parent $MyInvocation.MyCommand.Definition
$cheminReIcon = "$cheminScript\Tools\ReIcon_x64.exe"
if (-not (Test-Path $cheminReIcon)) { $cheminReIcon = "$cheminSelectionne\..\Tools\ReIcon_x64.exe" }
}

# --- E. VÉRIFICATION ESPACE DISQUE ---
Write-Host "`n[VÉRIFICATION] Calcul de l'espace disque... (Patientez)" -ForegroundColor Yellow
$mesureTaille = Get-ChildItem -Path $RacineSource -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
$tailleSourceGB = [math]::Round($mesureTaille.Sum / 1GB, 2)

if ($choix -eq "1") {
$lettreLecteur = (Get-Item $RacineDest).Root.Name
$disque = Get-Volume -DriveLetter $lettreLecteur.Substring(0,1)
$espaceLibreGB = [math]::Round($disque.SizeRemaining / 1GB, 2)
} else {
$disque = Get-Volume -DriveLetter "C"
$espaceLibreGB = [math]::Round($disque.SizeRemaining / 1GB, 2)
}

Write-Host " - Taille des données : $tailleSourceGB GB"
Write-Host " - Espace libre Dest. : $espaceLibreGB GB"

if ($tailleSourceGB -gt $espaceLibreGB) {
Write-Host "ERREUR : Pas assez d'espace disque !" -ForegroundColor Red
$confirmation = Read-Host "Voulez-vous forcer et essayer quand même ? (O/N)"
if ($confirmation -ne "O") { exit }
} else {
Write-Host " - Espace disque OK." -ForegroundColor Green
}

# --- E-Bis. MESSAGE D'AVERTISSEMENT ---
Write-Host "`n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
Write-Host " ATTENTION : VEUILLEZ FERMER TOUTES LES APPLICATIONS !" -ForegroundColor Yellow
Write-Host " - Firefox, Chrome, Edge" -ForegroundColor Yellow
Write-Host " - Thunderbird, Outlook" -ForegroundColor Yellow
Write-Host " - Word, Excel, LibreOffice" -ForegroundColor Yellow
Write-Host " Si ces logiciels restent ouverts, la copie échouera." -ForegroundColor Red
Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
Read-Host "Appuyez sur Entrée une fois que TOUT est fermé pour commencer..."

# --- F. Fonction Wrapper Robocopy ---
function Executer-Robocopy {
param ([string]$CheminSource, [string]$CheminDest, [string]$NomElement, [string]$CheminLog)
if (Test-Path $CheminSource) {
Write-Host "`n >> Copie : $NomElement" -ForegroundColor Cyan
robocopy "$CheminSource" "$CheminDest" /E /XO /ZB /R:1 /W:1 /ETA /LOG+:"$CheminLog" /TEE
} else {
Add-Content -Path $CheminLog -Value "[WARN] $NomElement introuvable : $CheminSource"
}
}

# --- G. EXÉCUTION DES TÂCHES ---

# 1. DOSSIERS STANDARDS
$dossiersStandards = @("Desktop", "Documents", "Downloads", "Pictures", "Links", "Favorites")
foreach ($dossier in $dossiersStandards) {
Executer-Robocopy (Join-Path $RacineSource $dossier) (Join-Path $RacineDest $dossier) $dossier $FichierJournal
}

# 2. FIREFOX
Write-Host "`n----------------------------------------------------" -ForegroundColor Magenta
Write-Host " TRAITEMENT FIREFOX (Profils)" -ForegroundColor Magenta
Write-Host "----------------------------------------------------" -ForegroundColor Magenta

if ($choix -eq "1") {
$baseSourceFF = "$RacineSource\AppData\Roaming\Mozilla\Firefox\Profiles"
$baseDestFF = "$RacineDest\DonneesFirefox"
} else {
$baseSourceFF = "$RacineSource\DonneesFirefox"
$baseDestFF = "$RacineDest\AppData\Roaming\Mozilla\Firefox\Profiles"
}

if (Test-Path $baseSourceFF) {
$repProfilSource = Get-ChildItem -Path $baseSourceFF -Directory | Where-Object { $_.Name -like "*.default*" } | Select-Object -First 1
if ($repProfilSource) {
if (-not (Test-Path $baseDestFF)) { New-Item -Path $baseDestFF -ItemType Directory -Force | Out-Null }

$repProfilDest = Get-ChildItem -Path $baseDestFF -Directory | Where-Object { $_.Name -like "*.default*" } | Select-Object -First 1

if (-not $repProfilDest) { $cheminCompletProfilDest = Join-Path $baseDestFF $repProfilSource.Name }
else { $cheminCompletProfilDest = $repProfilDest.FullName }

Write-Host " - Source : $($repProfilSource.Name)"
robocopy "$($repProfilSource.FullName)" "$cheminCompletProfilDest" /E /XO /ZB /R:1 /W:1 /LOG+:"$FichierJournal" /TEE /XF "parent.lock" /XD "cache2" "startupCache"
}
} else { Write-Host " - Pas de profil Firefox détecté." -ForegroundColor DarkGray }

# 3. MICROSOFT EDGE
Write-Host "`n----------------------------------------------------" -ForegroundColor Magenta
Write-Host " TRAITEMENT MICROSOFT EDGE (Favoris)" -ForegroundColor Magenta
Write-Host "----------------------------------------------------" -ForegroundColor Magenta

if ($choix -eq "1") {
$sourceEdge = "$RacineSource\AppData\Local\Microsoft\Edge\User Data\Default"
$destEdge = "$RacineDest\DonneesEdge"
} else {
$sourceEdge = "$RacineSource\DonneesEdge"
$destEdge = "$RacineDest\AppData\Local\Microsoft\Edge\User Data\Default"
}

if (Test-Path $sourceEdge) {
if (-not (Test-Path $destEdge)) { New-Item -Path $destEdge -ItemType Directory -Force | Out-Null }
Write-Host " - Copie des Favoris et de l'Historique Edge..."
robocopy "$sourceEdge" "$destEdge" "Bookmarks" "Favicons" "History" /ZB /R:1 /W:1 /LOG+:"$FichierJournal" /TEE
} else {
Write-Host " - Pas de profil Edge Default trouvé." -ForegroundColor DarkGray
}

# 4. PROFILS WI-FI
Write-Host "`n----------------------------------------------------" -ForegroundColor Magenta
Write-Host " GESTION WI-FI" -ForegroundColor Magenta
Write-Host "----------------------------------------------------" -ForegroundColor Magenta

$repWifi = Join-Path $RacineDest "Config_WiFi"
if ($choix -eq "2") { $repWifi = Join-Path $RacineSource "Config_WiFi" }

if ($choix -eq "1") {
if (-not (Test-Path $repWifi)) { New-Item -Path $repWifi -ItemType Directory | Out-Null }
netsh wlan export profile folder="$repWifi" key=clear | Out-Null
Write-Host " - Export OK."
} else {
if (Test-Path $repWifi) {
$fichiersWifi = Get-ChildItem "$repWifi\*.xml"
foreach ($xml in $fichiersWifi) {
netsh wlan add profile filename="$($xml.FullName)" | Out-Null
Write-Host " + Ajouté : $($xml.Name)"
}
} else { Write-Host " - Pas de backup Wi-Fi trouvée." }
}

# 5. IMPRIMANTES
Write-Host "`n----------------------------------------------------" -ForegroundColor Magenta
Write-Host " GESTION IMPRIMANTES" -ForegroundColor Magenta
Write-Host "----------------------------------------------------" -ForegroundColor Magenta

$repImprimantes = Join-Path $RacineDest "Config_Imprimantes"
if ($choix -eq "2") { $repImprimantes = Join-Path $RacineSource "Config_Imprimantes" }

$fichierImprimantes = Join-Path $repImprimantes "SauvegardeImprimantes.printerExport"
$outilPrintBrm = "$env:SystemRoot\System32\spool\tools\PrintBrm.exe"

if ($choix -eq "1") {
if (-not (Test-Path $repImprimantes)) { New-Item -Path $repImprimantes -ItemType Directory | Out-Null }
Write-Host " - Exportation..."
$argumentsPrint = @("-B", "-F", "$fichierImprimantes", "-O", "FORCE")
$processusPrint = Start-Process -FilePath $outilPrintBrm -ArgumentList $argumentsPrint -Wait -NoNewWindow -PassThru
if ($processusPrint.ExitCode -eq 0 -and (Test-Path $fichierImprimantes)) {
Write-Host " - Export Imprimantes RÉUSSI." -ForegroundColor Green
} else {
Write-Host " - ÉCHEC Export Imprimantes." -ForegroundColor Red
if ($FichierJournal) { Add-Content -Path $FichierJournal -Value "ERREUR: Échec export imprimantes (Code $($processusPrint.ExitCode))" }
}

} else {
if (Test-Path $fichierImprimantes) {
Write-Host " - Restauration..."
$argumentsPrint = @("-R", "-F", "$fichierImprimantes", "-O", "FORCE")
$processusPrint = Start-Process -FilePath $outilPrintBrm -ArgumentList $argumentsPrint -Wait -NoNewWindow -PassThru
if ($processusPrint.ExitCode -eq 0) {
Write-Host " - Import Imprimantes RÉUSSI." -ForegroundColor Green
} else {
Write-Host " - Erreur Import Imprimantes (Code: $($processusPrint.ExitCode))" -ForegroundColor Red
}
} else { Write-Host " - Fichier backup imprimantes introuvable." -ForegroundColor Yellow }
}

# 6. THUNDERBIRD / LIBREOFFICE
$autresApps = @("Thunderbird", "LibreOffice")
foreach ($app in $autresApps) {
if ($choix -eq "1") {
Executer-Robocopy (Join-Path $RacineSource "AppData\Roaming\$app") (Join-Path $RacineDest "Roaming\$app") $app $FichierJournal
} else {
Executer-Robocopy (Join-Path $RacineSource "Roaming\$app") (Join-Path $RacineDest "AppData\Roaming\$app") $app $FichierJournal
}
}

# 7. GESTION DES ICÔNES BUREAU
Write-Host "`n----------------------------------------------------" -ForegroundColor Magenta
Write-Host " GESTION DES ICÔNES BUREAU (ReIcon)" -ForegroundColor Magenta
Write-Host "----------------------------------------------------" -ForegroundColor Magenta

$fichierDispositionIcones = Join-Path $RacineDest "DispositionIcones.ini"
if ($choix -eq "2") { $fichierDispositionIcones = Join-Path $RacineSource "DispositionIcones.ini" }

if (Test-Path $cheminReIcon) {
if ($choix -eq "1") {
# SAUVEGARDE
Write-Host " - Sauvegarde de la position des icônes..."
$argumentsIcones = @("/S", "/File", "$fichierDispositionIcones")

Start-Process -FilePath $cheminReIcon -ArgumentList $argumentsIcones -Wait
if (Test-Path $fichierDispositionIcones) { Write-Host " - Position sauvegardée avec succès." -ForegroundColor Green }
else { Write-Host " - Erreur lors de la sauvegarde ReIcon." -ForegroundColor Red }
} else {
# RESTAURATION
if (Test-Path $fichierDispositionIcones) {
Write-Host " - Restauration de la position des icônes..."

# Pause de sécurité pour que le bureau soit prêt
Write-Host " (Attente de 4 secondes pour le rafraîchissement du bureau...)"
Start-Sleep -Seconds 4

$argumentsIcones = @("/R", "/File", "$fichierDispositionIcones")

Start-Process -FilePath $cheminReIcon -ArgumentList $argumentsIcones -Wait
Write-Host " - Ordre de restauration envoyé." -ForegroundColor Green
} else {
Write-Host " - Pas de fichier DispositionIcones.ini trouvé." -ForegroundColor Yellow
}
}
} else {
Write-Host " [!] ReIcon_x64.exe non trouvé." -ForegroundColor DarkGray
}

Write-Host "`n==============================================" -ForegroundColor Green
Write-Host " OPÉRATION TERMINÉE" -ForegroundColor Green
Write-Host " Journal disponible ici : $FichierJournal"
Write-Host "==============================================" -ForegroundColor Green

}
catch {
Write-Host "`n!!! ERREUR CRITIQUE !!!" -ForegroundColor Red
Write-Host "Message : $($_.Exception.Message)" -ForegroundColor Red
if ($FichierJournal) { Add-Content -Path $FichierJournal -Value "ERREUR CRITIQUE: $($_.Exception.Message)" }
}

Write-Host "Appuyez sur Entrée pour fermer..."
Read-Host
