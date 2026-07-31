## funkce `zalohovat.jl`
## Funkce Julia v1.12
###############################################################
## Popis funkce:
Synchronizuje nebo zálohuje složku podle příkazu `zpu`.
## Vzor:
vystupni_promenne = zalohovat(source::String, destination::String, zpu::String)
## Vstupní proměnné:
- `source` - Cesta ke zdrojové složce. [string]
- `destination` - Cesta k cílové složce. [string]
- `zpu` - Režim operace: [string]
    - *"zalohovat old"* - kompletní smazání cíle a nové kopírování
    - *"zalohovat"* - inteligentní synchronizace pomocí sync_folders()
    - *"zipnout"* - vytvoření zip archivu složky v cíli
    - *"obnovit"* - obnova složky (kopírování opačným směrem)
## Výstupní proměnné:
#
## Příklad:
```julia
zalohovat("C:/data/documents", "D:/backups", "zalohovat old")
zalohovat("C:/data/documents", "D:/backups", "zalohovat")
zalohovat("/home/user/docs", "/mnt/backup", "zipnout")
zalohovat("D:/backups/documents", "C:/data/documents", "obnovit")
```
