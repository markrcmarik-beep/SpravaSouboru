## Funkce Julia
###############################################################
## Popis funkce:
# Asymetricky synchronizuje obsah dvou složek (rekurzivně).
# Nové nebo změněné soubory ze zdrojové složky se zkopírují do cílové složky.
# Pokud je povoleno, odstraní soubory, které jsou jen v cílové složce.
# Lze volit kontrolu obsahu souborů, nebo jen velikosti a času.
# Lze volit režim "suchého běhu", kdy se akce pouze vypíšou, ale neprovedou.
# ver: 2026-01-03
## Funkce: sync_folders()
#
## Vzor:
## actions = sync_folders(zdrojova_slozka::String, cilova_slozka::String;
##                                  check_content::Bool=false,
##                                  delete_extra::Bool=true,
##                                  dry_run::Bool=true)
## Vstupní proměnné:
# - src::String : cesta ke zdrojové složce
# - dst::String : cesta k cílové složce
## Výstupní proměnné:
# - actions::Vector{String} : seznam provedených akcí (kopírování, mazání)
## Použité balíčky
# Dates, FilePathsBase
## Použité funkce:
#
## Příklad:
# sync_folders("cesta/k/zdroji", "cesta/k/cili"; check_content=true, 
#   delete_extra=true, dry_run=false)
###############################################################
## Použité proměnné vnitřní:
# files_src : slovník souborů ve zdrojové složce s metadaty
# files_dst : slovník souborů v cílové složce s metadaty
# actions : seznam plánovaných akcí během synchronizace
using Dates

"""
    sync_folders(src::String, dst::String;
                 check_content::Bool=false,
                 delete_extra::Bool=true,
                 dry_run::Bool=true)

Asymetricky synchronizuje obsah dvou složek včetně všech podsložek.

- Nové nebo změněné soubory ze `src` se zkopírují do `dst`.
- Při kopii se používá `copyfile_preserve_times` (multiplatformní zachování časů).
- Pokud `delete_extra=true`, soubory, které jsou jen v `dst`, se odstraní.
- Pokud `check_content=true`, kontroluje se i obsah souborů.
- Pokud `dry_run=true`, akce se pouze vypíší, ale neprovedou.

Vrací seznam provedených nebo plánovaných operací.
"""
function sync_folders(src::String, dst::String;
                      check_content::Bool=false,
                      delete_extra::Bool=true,
                      dry_run::Bool=true)
    ###########################################################################
    # Pomocná funkce – sběr všech souborů a jejich atributů
    ###########################################################################
    function collect_files(root::String)
        files = Dict{String, Tuple{Int64, DateTime, String}}()
        for (path, _, fs) in walkdir(root)
            for f in fs
                full = joinpath(path, f)
                rel  = Base.Filesystem.relpath(full, root)
                s    = stat(full)
                # stat().mtime je v některých OS číslo, v jiných DateTime
                mtime = s.mtime isa DateTime ? s.mtime : unix2datetime(s.mtime)
                files[rel] = (s.size, mtime, full)
            end
        end
        return files
    end
    ###########################################################################
    # Načtení struktury obou složek
    ###########################################################################
    files_src = collect_files(src)
    files_dst = collect_files(dst)
    actions = String[]
    ###########################################################################
    # Vyhledání nových nebo změněných souborů
    ###########################################################################
    for (rel, (size_s, time_s, path_s)) in files_src
        dest_path = joinpath(dst, rel)
        if !haskey(files_dst, rel)
            push!(actions, "Kopírovat nový soubor: $rel")
            if !dry_run
                mkpath(dirname(dest_path))
                copyfile_preserve_times(path_s, dest_path)
            end
        else
            size_d, time_d, path_d = files_dst[rel]
            needs_copy = false
            if check_content
                # Kontrola obsahu – pomalé, ale přesné
                if read(path_s) != read(path_d)
                    needs_copy = true
                end
            else
                # Kontrola velikosti nebo času
                if size_s != size_d || time_s > time_d
                    needs_copy = true
                end
            end
            if needs_copy
                push!(actions, "Aktualizovat soubor: $rel")
                if !dry_run
                    SpravaSouboru.copyfile_preserve_times(path_s, dest_path)
                end
            end
        end
    end
    ###########################################################################
    # Mazání souborů, které jsou pouze v cílové složce
    ###########################################################################
    if delete_extra
        for rel in setdiff(keys(files_dst), keys(files_src))
            dest_path = joinpath(dst, rel)
            push!(actions, "Smazat soubor: $rel")
            if !dry_run
                rm(dest_path; force=true)
            end
        end
    end
    ###########################################################################
    # Mazání prázdných a přebytečných složek
    ###########################################################################
    if delete_extra
        src_dirs = Set{String}(relpath(d, src) for (d,_,_) in walkdir(src))
        dst_dirs = Set{String}(relpath(d, dst) for (d,_,_) in walkdir(dst))
        # Složky mažeme od nejhlubší
        for rel in sort(collect(setdiff(dst_dirs, src_dirs)), rev=true)
            dpath = joinpath(dst, rel)
            if isdir(dpath)
                push!(actions, "Smazat složku: $rel")
                if !dry_run
                    rm(dpath; recursive=true, force=true)
                end
            end
        end
    end
    ###########################################################################
    # Výpis
    ###########################################################################
    println("=== Synchronizační akce ===")
    for a in actions
        println(a)
    end
    println("===========================")

    return actions
end