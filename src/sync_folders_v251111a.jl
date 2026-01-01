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

using Dates
using FilePathsBase

"""
    sync_folders(src::String, dst::String; check_content=false, delete_extra=true, dry_run=false)

Synchronizuje složku `src` do `dst` asymetricky (jako Total Commander):
- kopíruje chybějící a novější soubory z `src` do `dst`,
- smaže soubory v `dst`, které nejsou v `src` (pokud `delete_extra=true`),
- zachová časové údaje (mtime) souborů z `src`.

Argumenty:
- `check_content::Bool` - porovnává i obsah (jinak pouze velikost + mtime)
- `delete_extra::Bool` - smaže soubory, které nejsou ve zdrojové složce
- `dry_run::Bool` - pouze vypíše akce, nic neprovádí
"""
function sync_folders(src::String, dst::String;
                      check_content::Bool=false,
                      delete_extra::Bool=true,
                      dry_run::Bool=false)

    # pomocná funkce pro rekurzivní sběr souborů
    function collect_files(root::String)
        files = Dict{String, String}()
        for (dirpath, _, filenames) in walkdir(root)
            for fname in filenames
                rel = relpath(joinpath(dirpath, fname), root)
                files[rel] = joinpath(dirpath, fname)
            end
        end
        return files
    end

    src_files = collect_files(src)
    dst_files = collect_files(dst)

    actions = String[]

    # Kopírování nových a změněných souborů
    for (rel, src_path) in src_files
        dst_path = joinpath(dst, rel)
        if !haskey(dst_files, rel)
            push!(actions, "Kopírovat nový soubor: $rel")
            if !dry_run
                mkpath(dirname(dst_path))
                cp(src_path, dst_path; force=true)
                Base.Filesystem.utime(dst_path, stat(src_path).atime, stat(src_path).mtime)
            end
        else
            src_stat = stat(src_path)
            dst_stat = stat(dst_path)

            needs_copy = false
            if src_stat.size != dst_stat.size
                needs_copy = true
            elseif src_stat.mtime > dst_stat.mtime
                needs_copy = true
            elseif check_content
                open(src_path, "r") do fs
                    open(dst_path, "r") do fd
                        if !isequal(read(fs), read(fd))
                            needs_copy = true
                        end
                    end
                end
            end

            if needs_copy
                push!(actions, "Aktualizovat soubor: $rel")
                if !dry_run
                    cp(src_path, dst_path; force=true)
                    Base.Filesystem.utime(dst_path, src_stat.atime, src_stat.mtime)
                end
            end
        end
    end

    # Mazání přebytečných souborů
    if delete_extra
        for (rel, dst_path) in dst_files
            if !haskey(src_files, rel)
                push!(actions, "Smazat soubor: $rel")
                if !dry_run
                    rm(dst_path; force=true)
                end
            end
        end
    end

    println("=== Synchronizační akce ===")
    for a in actions
        println(a)
    end
    println("===========================")

    return actions
end
