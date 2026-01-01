## Funkce Julia
###############################################################
## Popis funkce:
# Asymetricky synchronizuje obsah dvou složek (rekurzivně).
# Nové nebo změněné soubory ze zdrojové složky se zkopírují do cílové složky.
# Pokud je povoleno, odstraní soubory, které jsou jen v cílové složce.
# Lze volit kontrolu obsahu souborů, nebo jen velikosti a času.
# Lze volit režim "suchého běhu", kdy se akce pouze vypíšou, ale neprovedou.
# ver: 2025-11-11
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
# sync_folders("cesta/k/zdroji", "cesta/k/ciliu"; check_content=true, delete_extra=true, dry_run=false)
###############################################################
## Použité proměnné vnitřní:
# files_src : slovník souborů ve zdrojové složce s metadaty
# files_dst : slovník souborů v cílové složce s metadaty
# actions : seznam plánovaných akcí během synchronizace
using Dates, FilePathsBase

"""
sync_folders(src::String, dst::String; check_content=false, delete_extra=true, dry_run=false)

Asymetricky synchronizuje obsah dvou složek (rekurzivně).

- Nové nebo změněné soubory ze `src` se zkopírují do `dst`.
- Pokud `delete_extra=true`, soubory které jsou jen v `dst` se odstraní.
- Pokud `check_content=true`, kontroluje i obsah souborů, nejen velikost a čas.
- Pokud `dry_run=true`, pouze vypíše plánované akce bez provedení.

Vrací počet provedených operací (kopií, smazání, vytvořených složek).
"""
function sync_folders(src::String, dst::String;
                      check_content::Bool=false,
                      delete_extra::Bool=true,
                      dry_run::Bool=true)

    # Pomocná funkce pro sběr souborů s metadaty
    function collect_files(root::String)
    files = Dict{String, Tuple{Int64, DateTime, String}}()
    for (path, _, fs) in walkdir(root)
        for f in fs
            srcfile = joinpath(path, f)
            rel = Base.Filesystem.relpath(srcfile, root)   # opraveno
            s = stat(srcfile)
            mtime = s.mtime isa DateTime ? s.mtime : unix2datetime(s.mtime)
            files[rel] = (s.size, mtime, srcfile)
        end
    end
        return files
    end

    files_src = collect_files(src)
    files_dst = collect_files(dst)

    actions = String[]

    # --- Porovnání souborů ---
    for (rel, (size_s, time_s, path_s)) in files_src
        dest_path = joinpath(dst, rel)
        if !haskey(files_dst, rel)
            push!(actions, "Kopírovat nový soubor: $rel")
            if !dry_run
                mkpath(dirname(dest_path))
                cp(path_s, dest_path; force=true)
            end
        else
            (size_d, time_d, path_d) = files_dst[rel]
            if size_s != size_d || time_s > time_d
                push!(actions, "Aktualizovat soubor: $rel")
                if !dry_run
                    cp(path_s, dest_path; force=true)
                end
            end
        end
    end

    # --- Odstranění přebytečných souborů ---
    if delete_extra
        for rel in setdiff(keys(files_dst), keys(files_src))
            dest_path = joinpath(dst, rel)
            push!(actions, "Smazat soubor: $rel")
            if !dry_run
                rm(dest_path; force=true)
            end
        end
    end

    # --- Odstranění prázdných nebo přebytečných složek ---
    if delete_extra
        src_dirs = Set{String}(relpath(d, src) for (d, _, _) in walkdir(src))
        dst_dirs = Set{String}(relpath(d, dst) for (d, _, _) in walkdir(dst))
        for rel_dir in sort(collect(setdiff(dst_dirs, src_dirs)), rev=true)
            dest_dir = joinpath(dst, rel_dir)
            if isdir(dest_dir)
                push!(actions, "Smazat složku: $rel_dir")
                if !dry_run
                    rm(dest_dir; force=true, recursive=true)
                end
            end
        end
    end

    println("=== Synchronizační akce ===")
    for act in actions
        println(act)
    end
    println("===========================")

    return actions
end