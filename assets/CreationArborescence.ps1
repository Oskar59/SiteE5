# =====================================================
# Script PowerShell - Création de l'arborescence GSB IDF
# =====================================================

# Dossier racine du serveur de fichiers
$Racine = "E:\Entreprise"

# --- SERVICES ADMINISTRATIFS ---
$admin = Join-Path $Racine "services-administratifs"
New-Item -ItemType Directory -Path $admin -Force | Out-Null

# Sous-dossiers
New-Item -ItemType Directory -Path "$admin\doc_officiels" -Force | Out-Null
New-Item -ItemType Directory -Path "$admin\salaire\remboursements" -Force | Out-Null
New-Item -ItemType Directory -Path "$admin\commun" -Force | Out-Null

# Fichiers exemple
New-Item -ItemType File -Path "$admin\doc_officiels\convention-collective.txt" -Force | Out-Null


# --- SERVICE INFORMATIQUE ---
$info = Join-Path $Racine "service-informatique"
New-Item -ItemType Directory -Path $info -Force | Out-Null

New-Item -ItemType Directory -Path "$info\reseau\fiche-depannage" -Force | Out-Null
New-Item -ItemType Directory -Path "$info\reseau\schema-reseau" -Force | Out-Null
New-Item -ItemType Directory -Path "$info\reseau\planning" -Force | Out-Null

New-Item -ItemType Directory -Path "$info\developpement\bases-donnees" -Force | Out-Null
New-Item -ItemType Directory -Path "$info\developpement\commun" -Force | Out-Null

New-Item -ItemType Directory -Path "$info\commun" -Force | Out-Null


# --- SERVICE COMMERCIAL ---
$comm = Join-Path $Racine "service-commercial"
New-Item -ItemType Directory -Path $comm -Force | Out-Null

New-Item -ItemType Directory -Path "$comm\commandes" -Force | Out-Null
New-Item -ItemType Directory -Path "$comm\clients" -Force | Out-Null
New-Item -ItemType Directory -Path "$comm\commun" -Force | Out-Null


# --- SERVICE PRODUCTION ---
$prod = Join-Path $Racine "service-production"
New-Item -ItemType Directory -Path $prod -Force | Out-Null

New-Item -ItemType Directory -Path "$prod\stock" -Force | Out-Null
New-Item -ItemType Directory -Path "$prod\production" -Force | Out-Null
New-Item -ItemType Directory -Path "$prod\relation-four" -Force | Out-Null
New-Item -ItemType Directory -Path "$prod\commun" -Force | Out-Null


# --- SERVICE LOGISTIQUE ---
$log = Join-Path $Racine "service-logistique"
New-Item -ItemType Directory -Path $log -Force | Out-Null

New-Item -ItemType Directory -Path "$log\planning_sept" -Force | Out-Null
New-Item -ItemType Directory -Path "$log\planning_oct" -Force | Out-Null
New-Item -ItemType Directory -Path "$log\commun" -Force | Out-Null


# --- SERVICE RECHERCHE & DÉVELOPPEMENT ---
$rd = Join-Path $Racine "service-rech_developpement"
New-Item -ItemType Directory -Path $rd -Force | Out-Null

New-Item -ItemType Directory -Path "$rd\phyto" -Force | Out-Null
New-Item -ItemType Directory -Path "$rd\homeopathie" -Force | Out-Null
New-Item -ItemType Directory -Path "$rd\commun" -Force | Out-Null


# --- SERVICE PHARMACIE ---
$pharma = Join-Path $Racine "service-pharmacie"
New-Item -ItemType Directory -Path $pharma -Force | Out-Null

New-Item -ItemType Directory -Path "$pharma\medicament" -Force | Out-Null
New-Item -ItemType Directory -Path "$pharma\hopital" -Force | Out-Null
New-Item -ItemType Directory -Path "$pharma\commun" -Force | Out-Null


# --- Message final ---
Write-Host "Arborescence complète créée avec succès dans $Racine"
