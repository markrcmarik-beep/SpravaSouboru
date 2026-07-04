# ver: 2026-05-30
# Spouští všechny testy pro balíček StrojniSoucasti

import Pkg

package_path = @__DIR__
println("Spouštím testy pro balíček: ", package_path)
nazev = basename(package_path)
println("Balíček: ", nazev)

Pkg.test(nazev)
