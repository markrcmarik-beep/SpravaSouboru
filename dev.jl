# ver: 2026-02-14

import Pkg

# cesta ke složce, kde leží tento skript
package_path = @__DIR__

println("Aktivuji prostředí: ", package_path)

Pkg.activate(package_path)
Pkg.instantiate()

# volitelné – pokud je Revise nainstalován
try
    using Revise
    println("Revise aktivní.")
catch
    println("Revise není dostupný.")
end

# načtení balíčku podle jména z Project.toml
project = Pkg.TOML.parsefile(joinpath(package_path, "Project.toml"))
pkg_name = Symbol(project["name"])

println("Načítám balíček: ", pkg_name)

@eval using $(pkg_name)

println("Hotovo.")
println("Cesta balíčku: ", pathof(eval(pkg_name)))