# Použití balíčku

## Instalace

```julia
using Pkg
Pkg.add(url="https://github.com/markrcmarik-beep/StrojniSoucasti")
```

## Typický postup výpočtu

Nejběžnější workflow v balíčku má tento sled:

1. načíst materiál (`materialy`),
2. určit dovolené napětí (`dovoleneNapeti`) nebo mez únavy (`mezUnavy`),
3. určit geometrii průřezu (`profily`) nebo zadat plochu ručně,
4. spustit konkrétní výpočet namáhání (`namahanitah`, `namahanitlak`, …),
5. volitelně uložit textový výstup (`ulozvypis`).

## Příklad A: materiál + dovolené napětí

```julia
using StrojniSoucasti
using Unitful

mat = materialy("S235")
Re = mat.Re * u"MPa"

sigmaDt = dovoleneNapeti("tah", "statický"; Re=Re)
```

## Příklad B: profil + namáhání v tahu

```julia
using StrojniSoucasti
using Unitful

# průřezové charakteristiky
prurez = profily("PLO 20x10", "S")

# výpočet namáhání
VV, txt = namahanitah(
    F = 25_000u"N",
    S = prurez[:S],
    mat = "S235",
    zatizeni = "statický"
)
```

## Příklad C: závit

```julia
using StrojniSoucasti

z = zavity("M8x1.25")
println(z.d)
println(z.p)
```

## Příklad D: uložení textového výstupu

```julia
using StrojniSoucasti

cesta = ulozvypis("Ukázkový výstup", soubor="vypocet_tah")
println(cesta)
```

## Poznámky k jednotkám

Balíček používá `Unitful` a většina výpočetních funkcí očekává vstupy s jednotkami
(např. `u"N"`, `u"mm^2"`, `u"MPa"`). U některých funkcí je možné zadat i holé číslo,
ale doporučený způsob je používat jednotky explicitně.
