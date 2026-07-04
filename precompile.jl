# ver: 2026-05-30
# Prekompilace balíčku pro zrychlení načítání

import Pkg

package_path = @__DIR__
println("Prekompilace balíčku: ", package_path)
nazev = basename(package_path)
println("Balíček: ", nazev)
Pkg.precompile(nazev)
