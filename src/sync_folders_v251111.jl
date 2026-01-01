## Funkce Julia
###############################################################
## Popis funkce:
#
# ver: 2025-11-11
## Funkce: nazev_funkce()
#
## Vzor:
## vystupni_promenne = nazev_funkce(vstupni_promenne)
## Vstupní proměnné:
#
## Výstupní proměnné:
#
## Použité balíčky
#
## Použité funkce:
#
## Příklad:
#
###############################################################
## Použité proměnné vnitřní:
#
import Base.Filesystem: utime
using Dates, FilePathsBase



"""
    sync_folders(src::String, dst::String;
                 check_content::Bool=false,
                 delete_extra::Bool=true,
                 dry_run::Bool=true)

Asymetricky synchronizuje obsah složky `src` do složky `dst`.
- Porovnává velikost a čas (nebo obsah).
- Kopíruje nové a změněné soubory.
- Volitelně maže soubory a složky, které se ve zdrojové složce nevyskytují.
- Zachovává čas poslední úpravy (mtime) u všech kopírovaných souborů.
"""


function sync_folders(src::String, dst::String;
                      check_content::Bool=false,
                      delete_extra::Bool=true,
                      dry_run::Bool=true)

    # --- Pomocná funkce pro sběr souborů ---
    function collect_files(root::String)
        files = Dict{String, Tuple{Int64, DateTime, String}}()
        for (path, _, fs) in walkdir(root)
            for f in fs
                srcfile = joinpath(path, f)
                rel = relpath(srcfile, root)
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

    # --- Kopírování a aktualizace ---
    for (rel, (size_s, time_s, path_s)) in files_src
        dest_path = joinpath(dst, rel)
        if !haskey(files_dst, rel)
            push!(actions, "Kopírovat nový soubor: $rel")
            if !dry_run
                mkpath(dirname(dest_path))
                cp(path_s, dest_path; force=true)
                utime(dest_path, time_s, time_s)  # zachová původní čas
            end
        else
            (size_d, time_d, path_d) = files_dst[rel]
            if size_s != size_d || time_s > time_d
                push!(actions, "Aktualizovat soubor: $rel")
                if !dry_run
                    cp(path_s, dest_path; force=true)
                    utime(dest_path, time_s, time_s)
                end
            end
        end
    end

    # --- Mazání přebytečných souborů ---
    if delete_extra
        for rel in setdiff(keys(files_dst), keys(files_src))
            dest_path = joinpath(dst, rel)
            push!(actions, "Smazat soubor: $rel")
            if !dry_run
                rm(dest_path; force=true)
            end
        end
    end

    # --- Mazání přebytečných složek ---
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