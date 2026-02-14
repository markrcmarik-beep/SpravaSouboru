# ver: 2026-02-14

import Pkg

package_path = @__DIR__

println("Instaluji balíček z: ", package_path)

# aktivace globálního prostředí
Pkg.activate()   # = @v1.x

# přidání balíčku v režimu vývoje (trvalý odkaz na cestu)
Pkg.develop(path=package_path)

println("Hotovo.")
println("Balíček je nyní dostupný globálně přes `using`.")