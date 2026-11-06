# Changelog

Přehled změn v jednotlivých verzích balíčku `SpravaSouboru`. Verze jsou uvedeny podle historie `Project.toml`.

## [0.1.12] - 2026-11-04

### Přidáno
- Dokumentace balíčku včetně návodů k použití, API, menu a zálohování.
- Testovací skripty pro spouštění a údržbu balíčku.
- Soubor nápovědy balíčku `SpravaSouboru.md`
### Upraveno
- Uspořádání implementace tabulkových funkcí do podsložky `sprsheet2tabl`.
- Úpravy zálohování, menu a testů.
- Opravy podpory Gtk4.
- Odstraněno verzování používaných balíčků.

## [0.1.11] - 2026-07-25

### Přidáno
- Skript pro prekompilaci balíčku.
### Upraveno
- Grafické menu přejmenováno z `menugui` na `menuokno` a aktualizována jeho registrace i testy.
- Aktualizována projektová konfigurace a pravidla `.gitignore`.

## [0.1.10] - 2026-06-05

### Přidáno
- Pomocné skripty `clean.jl` pro čištění prostředí a `update.jl` pro aktualizaci balíčku.
### Upraveno
- Opravy textového menu a projektové konfigurace.

## [0.1.9] - 2026-03-31

### Přidáno
- README s popisem funkcí, instalace a příklady použití.
- Skripty pro aktivaci vývojového prostředí a lokální vývoj balíčku.
### Upraveno
- Opravy a rozšíření testů, zejména pro převod adres buněk.
- Aktualizace závislostí a nastavení projektu.

## [0.1.8] - 2026-02-09

### Upraveno
- Zpřehledněna struktura menu a aktualizována grafická i textová menu.
- Rozšířeny a upraveny testy menu a určení rozsahu tabulky.

## [0.1.7] - 2026-02-05

### Upraveno
- Aktualizována projektová konfigurace a metadata balíčku.

## [0.1.6] - 2026-01-25

### Upraveno
- Provedena rozsáhlá úprava implementace synchronizace, zálohování, menu a práce s tabulkami.
- Zpřehledněny zdrojové soubory a upraveny testy.
- Odstraněn z repozitáře generovaný `Manifest.toml`.

## [0.1.5] - 2026-01-04

### Upraveno
- Aktualizovány závislosti a konfigurace projektu.

## [0.1.4] - 2026-01-03

### Upraveno
- Aktualizována konfigurace projektu a manifest závislostí.

## [0.1.3] - 2026-01-03

### Upraveno
- Zjednodušena implementace synchronizace složek a odstraněny starší varianty funkce.
- Doplněny a upraveny testy synchronizace a kopírování souborů se zachováním časů.

## [0.1.2] - 2026-01-01

### Přidáno
- První zaznamenaná verze balíčku s nástroji pro správu souborů, synchronizaci složek, práci s tabulkami, menu a zálohování.
