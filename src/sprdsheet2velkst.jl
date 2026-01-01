## Funkce Julia
###############################################################
## Popis funkce:
# Načte spreadsheet soubor (.ods nebo .xlsx), určí velikost vyplněné
# tabulky (rozsah neprázdných buněk) a vytvoří pomocný záložní soubor
# (.jld2) pro urychlení dalšího načítání. 
#
# Pokud se od posledního načtení soubor nezměnil, použije uložený rozsah.
#
# ver: 2025-11-02
## Funkce: [] = sprdsheet2velkst()
#
## Vzor:
## [rozsah] = sprdsheet2velkst(cesta, list; druh="plny")
#
## Vstupní proměnné:
# cesta - Cesta k souboru (.ods nebo .xlsx), včetně názvu. [string]
# list  - Název listu v souboru. [string]
# druh  - Určuje formát výstupu. [string]
#          'plny'             → celý rozsah např. "A1:K15" (výchozí)
#          'první'            → první buňka ("A1")
#          'poslední'         → poslední buňka ("K15")
#          'první písmeno'    → "A"
#          'první číslo'      → "1"
#          'poslední písmeno' → "K"
#          'poslední číslo'   → "15"
#
## Výstupní proměnné:
# rozsah - Textová adresa vyplněného rozsahu tabulky. [string]
#
## Použité balíčky:
# XLSX, OdsIO, FileIO, JLD2, Dates
#
## Použité uživatelské funkce:
# SprdsheetRef()
# ismissing(), isempty(), findfirst(), occursin(), readdir()
#
## Příklad:
# cesta = "data/sprdsheet2velkst_test.ods"
# list  = "List1"
# rozsah = sprdsheet2velkst(cesta, list)
# println("Vyplněný rozsah: ", rozsah)
#   vrátí vyplněný rozsah tabulky v listu "List1" souboru "sprdsheet2velkst_test.ods"
#  => rozsah = "A1:K15" (nebo jiný rozsah dle obsahu tabulky)
# Uložený záložní soubor (.jld2) bude vytvořen ve stejné složce jako
# původní spreadsheet, s názvem odvozeným od názvu souboru
## Použité proměnné vnitřní:
# data, nRows, nCols, nonEmptyRows, nonEmptyCols
# firstRow, lastRow, firstCol, lastCol
# od, do_, rozsahN
###############################################################

using XLSX, OdsIO, JLD2, Dates, Tables

function sprdsheet2velkst(cesta::String, list::String; druh::String = "plny")
    # vytvoření cesty,  názvu záložního souboru
    base = splitext(cesta)[1] # cesta bez přípony
    
    zaloznS = string(base, "_sprsheet2velkstF.jld2") # založní soubor s cestou

    # čas poslední změny spreadsheetu
    TIMEsprN = unix2datetime(stat(cesta).mtime)

    # VYLEPŠENÍ: používat jednoznačný prefix pro klíče jednotlivých listů, aby se listy nemíchaly
    # Každý sheet bude mít své vlastní dvě položky v .jld2:
    #   "__sheet__<list>__rozsah"  - uložený rozsah (string)
    #   "__sheet__<list>__TIMEspr"  - uložený čas poslední modifikace (DateTime)
    # Tento formát minimalizuje riziko kolizí s jinými proměnnými a zaručuje izolaci listů.
    key_prefix = "__sheet__"
    raw_roz_key = string(key_prefix, list, "__rozsah")
    raw_time_key = string(key_prefix, list, "__TIMEspr")

    # Pokud existuje .jld2 soubor, načteme pouze tyto konkrétní klíče (nikoli globální slovníky),
    # a použijeme uložený rozsah jen pokud se čas souboru shoduje.
    if isfile(zaloznS)
        try
            JLD2.jldopen(zaloznS, "r") do f
                if haskey(f, raw_time_key) && haskey(f, raw_roz_key)
                    # Porovnáme uložený čas pro tento list se současným mtime souboru
                    # Zaokrouhlíme oba časové údaje na celé sekundy, aby drobné rozdíly v přesnosti
                    # (sub-sekundové) nezpůsobily zbytečné přepočítání rozsahu.
                    try
                        if Dates.floor(f[raw_time_key], Dates.Second) == Dates.floor(TIMEsprN, Dates.Second)
                            return uprav_rozsah(f[raw_roz_key], druh)  # použití cache pro tento list
                        end
                    catch
                        # Pokud uložený čas není DateTime (např. starší Int), zkusíme přímé porovnání
                        if f[raw_time_key] == TIMEsprN
                            return uprav_rozsah(f[raw_roz_key], druh)
                        end
                    end
                end
            end
        catch err
            # pokud při čtení JLD2 nastane chyba (poškozený soubor, nelze číst), pokračujeme v běžném načtení
        end
    end

    # načtení listu podle typu souboru
    if endswith(lowercase(cesta), ".ods")
        # pomocí OdsIO (vrací Matrix pokud retType="Matrix")
        data = OdsIO.ods_read(cesta; sheetName=list, retType="Matrix")
        # Převedeme na Array a zajistíme, že prázdné buňky budou missing
        A = Array(data)
        # Nahradíme prázdné stringy a čisté whitespace za missing
        for i in eachindex(A)
            if A[i] isa AbstractString && isempty(strip(A[i]))
                A[i] = missing
            end
        end
    elseif endswith(lowercase(cesta), ".xlsx")
        # XLSX.readtable vrací XLSX.DataTable, nelze přímo volat Array(data)
        dt = XLSX.readtable(cesta, list)
        # Pokusíme se převést pomocí Tables.columntable (vrátí NamedTuple sloupců)
        try
            coltbl = Tables.columntable(dt)
            cols = collect(values(coltbl))
            if length(cols) == 0
                A = Array{Any}(undef, 0, 0)
            else
                nRows = length(cols[1])
                nCols = length(cols)
                A = Array{Any}(undef, nRows, nCols)
                for j in 1:nCols
                    colj = cols[j]
                    for i in 1:nRows
                        val = colj[i]
                        # Převedeme prázdné stringy a whitespace na missing
                        if val isa AbstractString && isempty(strip(val))
                            A[i, j] = missing
                        else
                            A[i, j] = val
                        end
                    end
                end
            end
        catch err
            # Fallback: zkusit sesbírat řádky a převést hodnoty na matici
            rows = collect(dt)
            if isempty(rows)
                A = Array{Any}(undef, 0, 0)
            else
                # každé řádku je očekáván NamedTuple nebo tuple hodnot
                firstrow = rows[1]
                if isa(firstrow, NamedTuple)
                    colnames = propertynames(firstrow)
                    nCols = length(colnames)
                    nRows = length(rows)
                    A = Array{Any}(undef, nRows, nCols)
                    for i in 1:nRows
                        rowi = rows[i]
                        for j in 1:nCols
                            A[i, j] = getfield(rowi, colnames[j])
                        end
                    end
                else
                    # assume tuple-like
                    nCols = length(firstrow)
                    nRows = length(rows)
                    A = Array{Any}(undef, nRows, nCols)
                    for i in 1:nRows
                        for j in 1:nCols
                            A[i, j] = rows[i][j]
                        end
                    end
                end
            end
        end
    else
        error("Nepodporovaný formát souboru: $(cesta)")
    end

    nRows, nCols = size(A)

    nonEmptyRows = falses(nRows)
    nonEmptyCols = falses(nCols)

    # VYLEPŠENÍ: Přesnější detekce prázdných buněk
    # Buňka je považována za prázdnou pokud:
    # - je missing, nothing nebo #undef
    # - je prázdný nebo whitespace string
    # - je číselná hodnota 0 nebo 0.0
    function is_empty_cell(cell)
        if ismissing(cell) || cell === nothing
            return true
        elseif cell isa AbstractString
            return isempty(strip(cell))
        elseif cell isa Number
            return iszero(cell)
        else
            return false
        end
    end

    # detekce neprázdných buněk s vylepšenou logikou
    for r in 1:nRows, c in 1:nCols
        if !is_empty_cell(A[r, c])
            nonEmptyRows[r] = true
            nonEmptyCols[c] = true
        end
    end

    # celý list prázdný
    if !any(nonEmptyRows) || !any(nonEmptyCols)
        return ""
    end

    # hranice oblasti
    firstRow = findfirst(nonEmptyRows)
    lastRow  = findlast(nonEmptyRows)
    firstCol = findfirst(nonEmptyCols)
    lastCol  = findlast(nonEmptyCols)

    # převod na adresy
    od  = sprsheetRef([firstRow, firstCol])
    do_ = sprsheetRef([lastRow, lastCol])
    rozsahN = string(od, ":", do_)

    # uložit konkrétní klíče do záložního souboru (ponechá ostatní již existující klíče)
    try
        # Kontrola zda je potřeba aktualizovat soubor
        need_update = true
        current_data = nothing
        
        if isfile(zaloznS)
            JLD2.jldopen(zaloznS, "r") do f
                if haskey(f, raw_time_key) && haskey(f, raw_roz_key)
                    try
                        if Dates.floor(f[raw_time_key], Dates.Second) == Dates.floor(TIMEsprN, Dates.Second) && f[raw_roz_key] == rozsahN
                            need_update = false  # Data jsou stejná, není třeba aktualizovat
                        end
                    catch
                        # fallback pokud uložený čas není DateTime
                        if f[raw_time_key] == TIMEsprN && f[raw_roz_key] == rozsahN
                            need_update = false
                        end
                    end
                end
                # Načteme všechna existující data pro případ, že bude třeba přepsat soubor
                if need_update
                    current_data = Dict{String,Any}()
                    for key in keys(f)
                        current_data[key] = f[key]
                    end
                end
            end
        end

        # Aktualizuj soubor pouze pokud je potřeba
        if need_update
            if isfile(zaloznS) && current_data !== nothing
                # Vytvoříme nový soubor se všemi daty
                JLD2.jldopen(zaloznS, "w") do f
                    # Nejprve zapíšeme všechna existující data kromě aktuálních klíčů
                    for (key, value) in current_data
                        if key != raw_roz_key && key != raw_time_key
                            f[key] = value
                        end
                    end
                    # Pak zapíšeme aktuální data
                    f[raw_roz_key] = rozsahN
                    f[raw_time_key] = TIMEsprN
                end
            else
                # Pokud soubor neexistuje nebo je prázdný, vytvoříme nový
                JLD2.jldopen(zaloznS, "w") do f
                    f[raw_roz_key] = rozsahN
                    f[raw_time_key] = TIMEsprN
                end
            end
        end
    catch err
        @warn "Problém při práci s .jld2 souborem: $zaloznS; Chyba: $err"
        rethrow(err)  # Pro debugování vyhodíme chybu dál
    end

    return uprav_rozsah(rozsahN, druh)
end # konec funkce

# -------------------------------------------------------------
# Pomocná funkce pro úpravu výstupu podle parametru "druh"
# -------------------------------------------------------------
function uprav_rozsah(rozsahN::String, druh::String)
    if druh == "plny"
        return rozsahN                                # vrátí celý rozsah ve formě "A1:K15"
    elseif druh == "první"
        return first(split(rozsahN, ":"))           # vrátí první adresu rozsahu (např. "A1")
    elseif druh == "poslední"
        return last(split(rozsahN, ":"))            # vrátí poslední adresu rozsahu (např. "K15")
    elseif druh == "první písmeno"
        return match(r"[A-Z]+", first(split(rozsahN, ":"))).match  # extrahuje písmeno sloupce z první adresy
    elseif druh == "první číslo"
        return match(r"\d+", first(split(rozsahN, ":"))).match    # extrahuje číslo řádku z první adresy
    elseif druh == "poslední písmeno"
        return match(r"[A-Z]+", last(split(rozsahN, ":"))).match   # extrahuje písmeno sloupce z poslední adresy
    elseif druh == "poslední číslo"
        return match(r"\d+", last(split(rozsahN, ":"))).match     # extrahuje číslo řádku z poslední adresy
    else
        error("Neznámý parametr 'druh': $druh")     # vyhodí chybu při neznámém parametru
    end
end # konec funkce
