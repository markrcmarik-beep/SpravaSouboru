## Funkce Julia
###############################################################
## Popis funkce:
# Zobrazí textové menu s možností výběru položky.
# Uživatel zadá číslo volby a funkce vrátí index i text zvolené položky.
# ver: 2026-02-06
## Funkce: menutext()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# SpravaSouboru/src/menu/menutext.jl
#
## Vzor:
## choice::Int, value::AbstractString = menutext(prompt::AbstractString,
##     options::Vector{<:AbstractString}; auto_choice::Union{Nothing,Int}=nothing)
## Vstupní proměnné:
# - prompt::AbstractString : text výzvy pro uživatele
# - options::Vector{<:AbstractString} : seznam možností k výběru
# - auto_choice : pro testy lze přímo zvolit index (0 = zrušit)
## Výstupní proměnné:
# - choice::Int : index vybrané možnosti
# - value::AbstractString : text vybrané možnosti
## Použité balíčky
#
## Použité funkce:
#
## Příklad:
# idx, volba = menutext("Vyber možnost:", ["Možnost 1", "Možnost 2", "Konec"])
# println("Vybral jsi možnost $idx: $volba")
###############################################################
## Použité proměnné vnitřní:
#
function menutext(
    prompt::AbstractString,
    options::Vector{<:AbstractString};
    auto_choice::Union{Nothing,Int}=nothing,
)
    reset = "\033[0m"; bold = "\033[1m"; green = "\033[32m"; red = "\033[31m"; cyan = "\033[36m"

    if isempty(options)
        println("$(red)❌ Seznam možností je prázdný.$(reset)")
        return 0, ""
    end

    if auto_choice !== nothing
        if auto_choice == 0
            return 0, ""
        elseif 1 <= auto_choice <= length(options)
            return auto_choice, options[auto_choice]
        else
            throw(ArgumentError("auto_choice mimo rozsah možností"))
        end
    end

    while true
        println("\n$(bold)$(cyan)$prompt$(reset)")
        println("──────────────────────────────")
        for (i, opt) in enumerate(options)
            println("  $(green)$i)$(reset) $opt")
        end
        print("\nZadej číslo volby: ")
        flush(stdout)

        try
            input = readline()
        catch e
            if e isa InterruptException
                println("\n$(red)❌ Přerušeno uživatelem.$(reset)")
                return 0, ""
            else
                rethrow(e)
            end
        end

        if isempty(strip(input))
            println("$(red)❌ Musíš zadat číslo.$(reset)")
            continue
        end

        try
            choice = parse(Int, strip(input))
            if 1 ≤ choice ≤ length(options)
                value = options[choice]
                println("$(green)✔ Vybral jsi: '$value'$(reset)")
                return choice, value
            else
                println("$(red)❌ Číslo mimo rozsah.$(reset)")
            end
        catch
            println("$(red)❌ Neplatný vstup – zadej číslo.$(reset)")
        end
    end
end
