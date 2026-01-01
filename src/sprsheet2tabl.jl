## Funkce Julia
###############################################################
## Popis funkce:
# Převede spreadsheet tabulku do tabulky v daném rozsahu. Uloží proměnné do
# .jld2 souboru, pokud .jld2 soubor neexistuje nebo jsou proměnné odlišné od
# dříve uložených.
#
# ver: 2025-11-01
## Funkce: [Var_X, Var_Y, Var1] = sprsheet2tabl(cesta01, soubory, list, rozsahy)
#
## Vzor:
# [rozsah] = sprsheet2tabl(cesta, soubory, list, rozsahy)
## Vstupní proměnné:
# cesta01 - Cesta k souborům. [string]
# soubory - Pole [soubor tabulky, soubor .jld2] [Vector{String}]
# list    - Název listu v souboru. [string]
# rozsahy - Pole tří textových rozsahů [Vector{String}]
#            [nadpis X, nadpis Y, tabulka dat]
## Výstupní proměnné:
# Var_X, Var_Y, Var1 - Načtená data z tabulky
#
## Použité balíčky:
# XLSX, OdsIO, FileIO, JLD2, Dates
#
## Použité uživatelské funkce:
# sprsheetRef()
## Příklad:
# cesta = "slozka1/data2" # Cesta k souborům
# soubory = ["sprdsheet2velkst_test.ods", "sprdsheet2velkst_test.jld2"] # Pole se jmény souborů
# list  = "List1" # Název listu v souboru
# rozsahy = ["A1", "B1", "A2:B5"] # Pole s rozsahy
# [Var_X, Var_Y, Var1] = sprsheet2tabl(cesta, soubory, list, rozsahy)
#   vrátí načtená data z tabulky
# => Var_X = [...], Var_Y = [...], Var1 = [...]
#
###############################################################

using XLSX, OdsIO, JLD2, Dates, FileIO

function sprsheet2tabl(cesta01::String, soubory::Vector{String}, list::String, rozsahy::Vector{String})

    # --- Dekompozice vstupů ---
    # Validate caller provided expected inputs
    if !(isa(soubory, AbstractVector{String}) || isa(soubory, Vector{String}))
        error("Argument 'soubory' musí být Vector{String} s alespoň dvěma položkami: [soubor_tab, soubor_dat].")
    end
    if length(soubory) < 2
        error("Argument 'soubory' musí obsahovat alespoň 2 prvky: [soubor_tab, soubor_dat]. Dostali jsme: $(length(soubory)).")
    end
    if !(isa(rozsahy, AbstractVector{String}) || isa(rozsahy, Vector{String}))
        error("Argument 'rozsahy' musí být Vector{String} obsahující 3 rozsahy: [Var_X, Var_Y, Var1].")
    end
    if length(rozsahy) < 3
        error("Argument 'rozsahy' musí obsahovat 3 rozsahy: [Var_X, Var_Y, Var1]. Dostali jsme: $(length(rozsahy)).")
    end

    soubor_tab = joinpath(cesta01, soubory[1])
    soubor_dat = joinpath(cesta01, soubory[2])

    # --- Kontrola existence zdrojového souboru ---
    if !isfile(soubor_tab)
        error("Soubor $(soubory[1]) nebyl nalezen v cestě: $cesta01")
    end

    # --- Kontrola keše .jld2 ---
    nacti_z_cache = false
    if isfile(soubor_dat)
        time_tab = unix2datetime(stat(soubor_tab).mtime)
        time_dat = unix2datetime(stat(soubor_dat).mtime)
        if time_dat >= time_tab
            nacti_z_cache = true
        end
    end

    # --- Pokud existuje aktuální keš ---
    if nacti_z_cache
        @load soubor_dat Var_X Var_Y Var1
        return Var_X, Var_Y, Var1
    end

    # --- Rozlišení podle typu souboru ---
    ext = lowercase(splitext(soubor_tab)[2])
    Var_X = Var_Y = Var1 = nothing

    if ext == ".xlsx"
        xf = XLSX.readxlsx(soubor_tab)
        sheetnames = XLSX.sheetnames(xf)
        if !(list in sheetnames)
            error("List '$list' nebyl nalezen v souboru $(soubory[1]).")
        end
        sheet = xf[list]

    # funkce pro čtení rozsahu z XLSX (lokální closure aby se předešlo problémům se scopem)
    get_data = r -> sheet[r]

    Var_X = get_data(rozsahy[1])
    Var_Y = get_data(rozsahy[2])
    Var1  = get_data(rozsahy[3])

    elseif ext == ".ods"
        # Robust ODS reader: try known read functions exported by OdsIO
        function read_ods_safe(path::AbstractString; sheetName::AbstractString="", retType::AbstractString="Matrix")
            # prefer ods_read, but accept alternative names if present
            if hasproperty(OdsIO, :ods_read)
                return OdsIO.ods_read(path; sheetName=sheetName, retType=retType)
            elseif hasproperty(OdsIO, :readods)
                # older/alternate name
                return OdsIO.readods(path; sheetName=sheetName, retType=retType)
            elseif hasproperty(OdsIO, :read_ods)
                return OdsIO.read_ods(path; sheetName=sheetName, retType=retType)
            else
                available = join(string.(names(OdsIO, all=true)), ", ")
                error("OdsIO does not expose a known read function (tried :ods_read, :readods, :read_ods). Available names: $available.\nPlease update OdsIO or install its Python dependency `ezodf` (e.g. `python -m pip install ezodf`).")
            end
        end

        # Read whole sheet as a matrix using a safe wrapper
        data = read_ods_safe(soubor_tab; sheetName=list, retType="Matrix")
        A = Array(data)

        # Funkce pro čtení rozsahu z ODS ve formátu "A1" nebo "A1:B3" (lokální closure)
        get_data = function(r::String)
            parts = split(r, ":")
            if length(parts) == 1
                idx = sprsheetRef(parts[1])
                return A[Int(idx[1]), Int(idx[2])]
            elseif length(parts) == 2
                start = sprsheetRef(parts[1])
                stop  = sprsheetRef(parts[2])
                r1, c1 = Int(start[1]), Int(start[2])
                r2, c2 = Int(stop[1]),  Int(stop[2])
                return A[r1:r2, c1:c2]
            else
                error("Neplatný rozsah: $r")
            end
        end

        Var_X = get_data(rozsahy[1])
        Var_Y = get_data(rozsahy[2])
        Var1  = get_data(rozsahy[3])
    else
        error("Nepodporovaný formát souboru: $ext")
    end

    # --- Uložení do keše (.jld2) ---
    @save soubor_dat Var_X Var_Y Var1

    return Var_X, Var_Y, Var1
end