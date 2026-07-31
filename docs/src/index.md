# SpravaSouboru

`SpravaSouboru` je balíček v jazyce Julia pro práci se soubory, tabulkovými daty a synchronizaci složek.
Knihovna obsahuje pomocné funkce pro čtení spreadsheet souborů, převody adres buněk, zálohování a menu pro výběr akcí.

## Hlavní funkce

- `sprsheetRef()`: Převod mezi adresou buňky (např. "AB3") a souřadnicemi.
- `sprsheet2tabl()`: Načtení dat z tabulky (.xlsx/.ods).
- `sprdsheet2velkst()`: Určení vyplněného rozsahu listu.
- `sync_folders()`: Asymetrická synchronizace dvou složek.
- `zalohovat()`: Záloha, obnova nebo ZIP archivace složky.
- `menutext()` / `menuokno()`: Menu pro výběr akcí.

## Rychlý start

```julia
using SpravaSouboru

# Synchronizace složek
sync_folders("cesta/zdroj", "cesta/cil")

# Záloha složky
zalohovat("cesta/zdroj", "cesta/zalohy", "zalohovat")
```

Podrobný návod je v kapitole [Použití balíčku](pouziti.md) a kompletní seznam API v [API](api.md).
