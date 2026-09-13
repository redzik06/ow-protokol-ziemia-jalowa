# sync_to_test.ps1 — kopiuje pliki MODA (Desktop, repo git) do folderu testowego
# Mods\Protokol w instalacji Steam. NIE przenosi — oryginały zostają w repo.
# Użycie: prawy klik → Uruchom w PowerShell (po każdej zmianie w repo).
$src = "C:\Users\user\Desktop\ow mod test"
$dst = "C:\Program Files (x86)\Steam\steamapps\common\Original War\Mods\Protokol"
New-Item -ItemType Directory -Path $dst -Force | Out-Null
Copy-Item -LiteralPath "$src\campaign.txt" -Destination $dst -Force
Copy-Item -LiteralPath "$src\characters.txt" -Destination $dst -Force
Copy-Item -LiteralPath "$src\README.md" -Destination $dst -Force
New-Item -ItemType Directory -Path "$dst\missions" -Force | Out-Null
Copy-Item -Path "$src\missions\*.sail" -Destination "$dst\missions" -Force
New-Item -ItemType Directory -Path "$dst\strings" -Force | Out-Null
Copy-Item -LiteralPath "$src\strings\texts_pl.txt" -Destination "$dst\strings" -Force
Copy-Item -LiteralPath "$src\strings\voices_ai.json" -Destination "$dst\strings" -Force
Copy-Item -LiteralPath "$src\maps" -Destination "$dst\maps" -Recurse -Force
Copy-Item -LiteralPath "$src\campaign\Missions\__PZ" -Destination "$dst\missions\__PZ" -Recurse -Force
Copy-Item -LiteralPath "$src\campaign\Campaigns" -Destination "$dst\Campaigns" -Recurse -Force
Copy-Item -LiteralPath "$src\campaign\Texts" -Destination "$dst\Texts" -Recurse -Force
Copy-Item -LiteralPath "$src\tools" -Destination "$dst\tools" -Recurse -Force
if (Test-Path -LiteralPath "$dst\campaign") { Remove-Item -LiteralPath "$dst\campaign" -Recurse -Force }
New-Item -ItemType Directory -Path "$dst\graphics\faces" -Force | Out-Null
Copy-Item -LiteralPath "$src\graphics\faces\prompts_ow_style.txt" -Destination "$dst\graphics\faces" -Force
$maps = (Get-ChildItem -Recurse -File "$dst\maps\*.map" -ErrorAction SilentlyContinue | Measure-Object).Count
$sails = (Get-ChildItem "$dst\missions\*.sail" | Measure-Object).Count
Write-Output "SYNC OK: $sails SAIL, $maps real .map w $dst"
Write-Output "Źródło prawdy: repo git na Desktopie. Ten folder to KOPIA testowa."
