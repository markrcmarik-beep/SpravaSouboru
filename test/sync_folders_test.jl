# ver: 2025-11-10
using SpravaSouboru

cesta01 = dirname(@__FILE__) # Získá cestu k adresáři aktuálního souboru
podslozka01 = "sync_folders_test" # Podadresář s testovacími soubory

cesta1 = joinpath(cesta01, podslozka01, "MATLAB1")
cesta2 = joinpath(cesta01, podslozka01, "MATLAB2")
sync_folders(
    cesta1,          # zdrojová složka
    cesta2;        # cílová složka
    check_content=false,          # pouze podle velikosti a času
    delete_extra=true,            # maže soubory navíc v cíli
    dry_run=false                  # jen vypíše akce, nic nevykoná
)
