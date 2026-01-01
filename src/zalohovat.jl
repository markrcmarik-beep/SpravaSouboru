## Funkce Julia
###############################################################
## Popis funkce:
# Synchronizuje nebo zálohuje složku podle příkazu `zpu`.
# ver: 2025-11-20
## Funkce: []=zalohovat()
#
## Vzor:
## []=zalohovat(source::String, destination::String, zpu::String)
## Vstupní proměnné:
# source - Cesta ke zdrojové složce. [string]
# destination - Cesta k cílové složce. [string]
# zpu - Režim operace: [string]
#     - "zalohovat old" - kompletní smazání cíle a nové kopírování
#     - "zalohovat" - inteligentní synchronizace pomocí sync_folders()
#     - "zipnout" - vytvoření zip archivu složky v cíli
#     - "obnovit" - obnova složky (kopírování opačným směrem)
## Výstupní proměnné:
#
## Použité balíčky
# Dates, ZipFile
## Použité funkce:
#
## Příklad:
# >> zalohovat("C:/data/documents", "D:/backups", "zalohovat old")
# >> zalohovat("C:/data/documents", "D:/backups", "zalohovat")
# >> zalohovat("/home/user/docs", "/mnt/backup", "zipnout")
# >> zalohovat("D:/backups/documents", "C:/data/documents", "obnovit")

## Použité proměnné vnitřní:
#
using Dates, ZipFile

"""
    zalohovat(source::String, destination::String, zpu::String)

Synchronizuje nebo zálohuje složku podle příkazu `zpu`.

Dostupné režimy:
- `"zalohovat old"` - kompletní smazání cíle a nové kopírování
- `"zalohovat"` - inteligentní synchronizace pomocí sync_folders()
- `"zipnout"` - vytvoření zip archivu složky v cíli
- `"obnovit"` - obnova složky (kopírování opačným směrem)

"""
function zalohovat(source::String, destination::String, zpu::String)

    if !isdir(source)
        @warn "Nelze provést operaci. Nenalezen zdroj: $source"
        return
    end

    _, cilslozka = splitdir(source)
    cil = joinpath(destination, cilslozka)

########################################################################
## 1) Režim "zalohovat old" – smazat a znovu vše nakopírovat (multiplatformně)
########################################################################
if zpu == "zalohovat old"

    # odstranění původní cílové složky
    if isdir(cil)
        rm(cil; recursive=true, force=true)
        println("Odstraněno: $cil")
    end

    mkpath(destination)

    println("Kopíruji se zachováním metadat...")

    ####################################################################
    # Windows – PowerShell Copy-Item (nejvyšší přesnost metadat)
    ####################################################################
    if Sys.iswindows()
        # únik speciálních znaků pro PowerShell
        src_ps = replace(source, "\"" => "`\"")
        dst_ps = replace(cil, "\"" => "`\"")

        ps_cmd =
            "Copy-Item -LiteralPath \"$src_ps\" " *
            "-Destination \"$dst_ps\" " *
            "-Recurse -Force -Container"

        run(`powershell -NoLogo -NoProfile -Command $ps_cmd`)

    ####################################################################
    # Linux – cp -a (archivní mód, zachová vše)
    ####################################################################
    elseif Sys.islinux()
        # cp -a zachovává mtime, atime, ownership, permissions, symlinks
        run(`cp -a "$source" "$cil"`)

    ####################################################################
    # macOS – cp -pR (zachovává metadata Apple FS + časové atributy)
    ####################################################################
    elseif Sys.isapple()
        # -p = preserve metadata, -R = recursive
        run(`cp -pR "$source" "$cil"`)
    ####################################################################
    # Nepodporovaný operační systém
    ####################################################################
    else
        @warn "Neznámý OS - provádím základní kopii bez zaručeného zachování metadat."
        error("Unsupported operating system: cannot perform metadata-preserving copy.")
    end

    println("Kopie dokončena: $source → $cil")
    return
end

########################################################################
## 2) Režim "zalohovat" – inteligentní synchronizace
########################################################################
 if zpu == "zalohovat"

    mkpath(destination) # vytvoření cílové složky, pokud neexistuje
    sync_folders(source, cil; check_content=false, delete_extra=true, dry_run=false)
    println("Synchronizace dokončena.")
    return
end

########################################################################
## 3) Režim "zipnout"
########################################################################
if zpu == "zipnout"

    if !isdir(cil)
        @warn "Nelze zipovat - složka v cíli neexistuje: $cil"
        return
    end

    base = string(cilslozka, "_v", Dates.format(now(), "yyyyMMdd")) # základ názvu zipu
    tx = ['a','b','c','d','e','f','g','h']

    # nalezení volného názvu
    nazev = base
    allnames = vcat([nazev], [string(base, t) for t in tx]) # přidání přípon a–h

    for nm in allnames
        if !isfile(joinpath(destination, nm * ".zip"))
            nazev = nm
            break
        end
    end

    zipfile_path = joinpath(destination, nazev * ".zip") # plná cesta k zipu
    println("Vytvářím archiv: $zipfile_path")

    ZipFile.zip(zipfile_path, cil)
    println("Vytvořen ZIP: $zipfile_path")
    return
end

########################################################################
## 4) Režim "obnovit" – opačné kopírování (z cíle do zdroje)
########################################################################
if zpu == "obnovit"

    if !isdir(cil)
        @warn "Nelze obnovit - v cíli nenalezena složka: $cil"
        return
    end

    # Pokud složka existuje, vyčistí se synchronizací.
    # Pokud neexistuje, vytvoří se prázdná pro účely obnovy.
    if !isdir(source)
        mkpath(source)
        println("Vytvořena složka: $source")
    end

    # Obnova pomocí sync_folders – opačným směrem
    println("Obnovuji z  $cil  do  $source ...")
    sync_folders(cil, source; check_content=false, delete_extra=true, dry_run=false)
    println("Obnoveno z  $cil  do  $source")
    return
end

########################################################################
## 5) Neznámý příkaz
########################################################################
@warn "Neznámý příkaz: $zpu"

end
