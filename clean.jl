# ver: 2026-02-20
# Čištění cache a dočasných souborů
# Základní čištění
#julia clean.jl

# Čištění včetně build souborů
#julia clean.jl --build

# Odstranění závislostí a cache
#julia clean.jl --deps

# Kompletní úklid
#julia clean.jl --all

# Verbose režim
#julia clean.jl --verbose

import Pkg

package_path = @__DIR__

# získání argumentů z příkazové řádky
clean_deps = "--deps" in ARGS
clean_build = "--build" in ARGS
clean_all = "--all" in ARGS
verbose = "--verbose" in ARGS || "-v" in ARGS

if clean_all
    clean_deps = true
    clean_build = true
end

println("Čistím prostředí: ", package_path)

# smazání Julia cache
cache_dirs = [
    joinpath(package_path, ".julia"),
    joinpath(package_path, "__pycache__"),
]

for dir in cache_dirs
    if isdir(dir)
        println("Mažu: ", dir)
        rm(dir, recursive=true)
    end
end

# smazání build artefaktů (pokud je --build nebo --all)
if clean_build
    build_dirs = [
        joinpath(package_path, "build"),
        joinpath(package_path, "docs", "build"),
    ]
    
    for dir in build_dirs
        if isdir(dir)
            println("Mažu: ", dir)
            rm(dir, recursive=true)
        end
    end
end

# smazání dependency cache (pokud je --deps nebo --all)
if clean_deps
    deps_cache = joinpath(package_path, "Manifest.lock")
    if isfile(deps_cache)
        println("Mažu: ", deps_cache)
        rm(deps_cache)
    end
end

# smazání systémové cache balíčku
println("\nMažu systémovou cache balíčku...")
Pkg.activate(package_path)
Pkg.gc()

if verbose
    println("\nNalezene binarni artefakty:")
    for (root, _, files) in walkdir(package_path)
        for file in files
            if endswith(file, ".o") || endswith(file, ".so") || endswith(file, ".a")
                println(joinpath(root, file))
            end
        end
    end
end

println("\nHotovo. Prostředí bylo vyčištěno.")
