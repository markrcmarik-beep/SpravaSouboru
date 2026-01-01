## Funkce Julia
###############################################################
## Popis funkce:
#
# ver: 2025-11-10
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
                      dry_run::Bool=false)

    # Pomocná funkce – získá mapu souborů
    function collect_files(root)
        files = Dict{String, Tuple{Int64, DateTime, String}}()
        for (dir, _, names) in walkdir(root)
            for n in names
                path = joinpath(dir, n)
                rel = relpath(path, root)
                s = stat(path)
                # Kompatibilní převod (Float64 → DateTime)
                mtime = s.mtime isa DateTime ? s.mtime : unix2datetime(s.mtime)
                files[rel] = (s.size, mtime, path)
            end
        end
        return files
    end

    # Porovnání obsahu po blocích
    function same_file(path1, path2; blocksize=1_000_000)
        s1, s2 = stat(path1), stat(path2)
        s1.size == s2.size || return false
        open(path1) do f1
            open(path2) do f2
                while !eof(f1)
                    b1 = read(f1, blocksize)
                    b2 = read(f2, blocksize)
                    b1 == b2 || return false
                end
            end
        end
        return true
    end

    src_files = collect_files(src)
    dst_files = collect_files(dst)
    ops = 0

    # 1️⃣ Kopírování / aktualizace
    for (rel, (size, mtime, src_path)) in src_files
        dst_path = joinpath(dst, rel)
        if haskey(dst_files, rel)
            s2, t2, _ = dst_files[rel]
            need_copy = false
            if size != s2 || mtime > t2
                need_copy = true
            elseif check_content && !same_file(src_path, dst_path)
                need_copy = true
            end

            if need_copy
                if dry_run
                    println("Aktualizace: ", rel)
                else
                    mkpath(dirname(dst_path))
                    cp(src_path, dst_path; force=true)
                    println("→ Přepsán: ", rel)
                end
                ops += 1
            end
        else
            if dry_run
                println("Kopírování nového: ", rel)
            else
                mkpath(dirname(dst_path))
                cp(src_path, dst_path)
                println("→ Zkopírován: ", rel)
            end
            ops += 1
        end
    end

    # 2️⃣ Odstranění nadbytečných souborů
    if delete_extra
        for (rel, (_, _, dst_path)) in dst_files
            if !haskey(src_files, rel)
                if dry_run
                    println("Smazal by: ", rel)
                else
                    rm(dst_path; force=true)
                    println("× Smazán: ", rel)
                end
                ops += 1
            end
        end
    end

    println("\nHotovo. Provedeno $ops operací.")
    return ops
end