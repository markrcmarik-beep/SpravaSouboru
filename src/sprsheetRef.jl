## Funkce Julia
###############################################################
## Popis funkce:
# Převádí mezi číselnými souřadnicemi tabulky a textovou adresou buňky 
# ve formátu používaném v Excel/ODS tabulkách (např. "AB3").
# Funkce umožňuje obousměrný převod:
#   [row, col] → "AB3"
#   "AB3" → [row, col]
# ver: 2025-11-20
## Funkce: []=sprsheetRef()
#
## Vzor:
## [A]=sprsheetRef(arg)
## Vstupní proměnné:
# arg - Číselné souřadnice buňky [row, col]. [numeric]
#     - Textová adresa buňky (např. "A1"). [string]
#     - Pole více adres. [Vector{String}]
## Výstupní proměnné:
# A - Textová adresa buňky (např. "AB3"). [string]
#   - Číselné souřadnice [row, col]. [Vector{Int}]
#   - Při vstupu více adres: matice Nx2 nebo pole vektorů.
## Použité balíčky
#
## Použité funkce:
#
## Příklad:
# >> sprsheetRef([1,1])
# "A1"
#
# >> sprsheetRef([3,28])
# "AB3"
#
# >> sprsheetRef("AB3")
# [3, 28]
#
# >> sprsheetRef(["A1","B2","AB3"])
# [ [1,1], [2,2], [3,28] ]

## Použité proměnné vnitřní:
# row, col  - Číselné souřadnice buňky
# letters   - Textová část adresy (A, B, AB, …)
# digits    - Číselná část adresy
# rem       - Zbytek pro výpočet znaku sloupce
# idx       - Index prvního čísla v textovém řetězci
# c         - Pomocná proměnná pro výpočet sloupce

function sprsheetRef(arg)
    
    # První případ: [řádek, sloupec] -> "AB3"
    if isa(arg, AbstractVector{<:Number}) && length(arg) == 2
        # Explicitně převedeme vstup na Int, abychom zaručili,
        # že 'rem' bude Int a Char(Int) bude platné.
        # Tím se zabrání chybě, pokud by vstup byl např. [1.0, 2.0]
        row_int, col_int = Int(arg[1]), Int(arg[2])
        letters_vec = Char[] # Vektor pro ukládání znaků sloupce
        c = col_int # Nyní je 'c' zaručeně Int
        if c <= 0
             error("Column number must be positive. Received: $c")
        end
        while c > 0
            # 'rem' je nyní zaručeně Int, protože 'c' je Int
            rem = (c - 1) % 26
            # Linter by toto již neměl podtrhávat
            push!(letters_vec, Char(65 + rem)) # 65 je ASCII kód pro 'A'
            c = (c - 1) ÷ 26 # Integer division
        end
        reverse!(letters_vec) # Obrácení pořadí znaků
        letters = join(letters_vec) # Spojení znaků do stringu
        return string(letters, row_int) # Sestavení výsledné adresy
    # Druhý případ: Více řádků (matice 2 sloupců)
    elseif isa(arg, AbstractVector{<:Number}) && size(arg, 2) == 2
        # OPRAVA 3 (Typová stabilita):
        # Také zde musíme zajistit Int pro rekurzivní volání
        return [sprsheetRef([Int(r), Int(c)]) for (r, c) in eachrow(arg)]
    # Třetí případ: "AB3" -> [řádek, sloupec]
    elseif isa(arg, AbstractString)
        idx = findfirst(isdigit, arg) # Najde index prvního čísla v řetězci
        if isnothing(idx)
            error("Invalid spreadsheet reference: Missing row number. Received: $arg")
        end
        letters = arg[1:idx-1] # Textová část (sloupec)
        digits = arg[idx:end] # Číselná část (řádek)
        col = 0 # Inicializace sloupce
        for ch in letters
            col = col * 26 + (Int(uppercase(ch)) - Int('A') + 1) # Výpočet sloupce
        end
        row = 0 # Inicializace řádku
         # Převod řádku na Int s ošetřením chyby při neplatném formátu
        try
            row = parse(Int, digits)
        catch
            error("Invalid row number format. Received: $digits")
        end
        if isempty(letters)
            error("Invalid spreadsheet reference: Missing column letters. Received: $arg")
        end
        return [row, col]
    # Čtvrtý případ: Více adres (vektor stringů)
    elseif isa(arg, Vector{String})
        return [sprsheetRef(s) for s in arg] # Rekurzivní volání pro každý prvek vektoru
    # Jiný vstup
    else
        error("Invalid input type. Must be [row,col] or String/Vector{String}")
    end
end