SpravaSouboru

Balíček v jazyce Julia pro práci se soubory, tabulkovými daty a synchronizaci složek.
Knihovna obsahuje pomocné funkce pro čtení spreadsheet souborů, převody adres buněk, zálohování a menu pro výběr akcí.

Projekt je určen především pro:

práci s tabulkovými soubory (.xlsx, .ods)

synchronizaci a zálohování adresářů

automatizaci správy souborů

pomocné nástroje pro CLI/GUI výběr operací

Instalace

Balíček lze instalovat pomocí správce balíčků Julia.

using Pkg
Pkg.add(url="https://github.com/markrcmarik-beep/SpravaSouboru")

Poté je možné balíček načíst:

using SpravaSouboru

Hlavní funkce

Balíček exportuje zejména tyto funkce:

sprsheetRef() - převod mezi adresou buňky (např. "AB3") a souřadnicemi [řádek, sloupec]

sprsheet2tabl() - načtení dat z definovaných rozsahů tabulky (.xlsx/.ods) s cache do .jld2

sprdsheet2velkst() - určení vyplněného rozsahu listu (např. "A1:K15")

sync_folders() - asymetrická synchronizace dvou složek

zalohovat() - záloha, obnova nebo zip archivace složky podle zvoleného režimu

menutext() - textové menu s výběrem položky

menugui() - grafické menu s výběrem položky

Příklad použití

Převod adresy buňky:

sprsheetRef([3,28])

výstup:

"AB3"

a opačně:

sprsheetRef("AB3")

výstup:

[3,28]

Načtení tabulky v daných rozsazích:

cesta = "data"
soubory = ["tabulka.ods", "tabulka.jld2"]
list = "List1"
rozsahy = ["A1", "B1", "A2:B20"]
Var_X, Var_Y, Var1 = sprsheet2tabl(cesta, soubory, list, rozsahy)

Synchronizace složek:

sync_folders("cesta/zdroj", "cesta/cil"; dry_run=false)

Záloha složky:

zalohovat("cesta/zdroj", "cesta/zalohy", "zalohovat")

Práce s tabulkami

Balíček obsahuje funkce pro načítání dat z tabulkových souborů:

Excel (.xlsx)

OpenDocument Spreadsheet (.ods)

Načtená data a pomocné informace (např. rozsah listu) se ukládají do `.jld2`,
aby bylo opakované načítání výrazně rychlejší.

Struktura projektu
SpravaSouboru
│
├─ src
│   ├─ SpravaSouboru.jl
│   ├─ sprsheetRef.jl
│   ├─ sprsheet2tabl.jl
│   ├─ sprdsheet2velkst.jl
│   ├─ sync_folders.jl
│   ├─ zalohovat.jl
│   └─ menu/
│       ├─ menutext.jl
│       └─ menugui.jl
│
├─ test
│
└─ Project.toml

Stav projektu

Projekt je ve vývoji.
Nové funkce a úpravy jsou průběžně přidávány.

Spolupráce na vývoji

Pokud chcete přispět k vývoji:

vytvořte vlastní branch

proveďte změny

odešlete Pull Request

Diskuse o vývoji probíhá pomocí nástrojů platformy GitHub.

Licence

Licence projektu bude doplněna.
