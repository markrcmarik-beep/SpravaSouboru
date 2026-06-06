# ver: 2026-02-20
# Aktualizace balíčku s flexibilními možnostmi
# Základní aktualizace (jen hlavní balíček)
#julia update.jl

# S detailním výstupem
#julia update.jl --verbose
#julia update.jl -v

# Včetně aktualizace docs prostředí
#julia update.jl --docs

# Kombinace
#julia update.jl --docs --verbose

import Pkg

package_path = @__DIR__

# získání argumentů z příkazové řádky
update_docs = "--docs" in ARGS
verbose = "--verbose" in ARGS || "-v" in ARGS

println("Aktualizuji prostředí: ", package_path)

# aktivace lokálního prostředí
Pkg.activate(package_path)

# aktualizace závislostí
println("Aktualizuji závislosti...")
Pkg.update()

# aktualizace docs prostředí (pokud je požadováno)
if update_docs && isdir(joinpath(package_path, "docs"))
    println("\nAktualizuji docs prostředí...")
    Pkg.activate(joinpath(package_path, "docs"))
    Pkg.update()
    Pkg.activate(package_path)
end

# zobrazení statusu
if verbose || update_docs
    println("\nAktuální stav prostředí:")
    Pkg.status()
end

println("\nHotovo. Prostředí je aktualizováno.")
