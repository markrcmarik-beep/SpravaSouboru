## Funkce Julia
###############################################################
## Popis funkce:
# Zobrazí textové menu s možností výběru položky.
# Uživatel zadá číslo volby a funkce vrátí index i text zvolené položky.
# ver: 2025-11-13
## Funkce: menutext()
#
## Vzor:
## choice::Int, value::String = menutext(prompt::String, options::Vector{String})
## Vstupní proměnné:
# - prompt::String : text výzvy pro uživatele
# - options::Vector{String} : seznam možností k výběru
## Výstupní proměnné:
# - choice::Int : index vybrané možnosti
# - value::String : text vybrané možnosti
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
function menutext(prompt::String, options::Vector{String})
    reset = "\033[0m"; bold = "\033[1m"; green = "\033[32m"; red = "\033[31m"; cyan = "\033[36m"

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
            choice = parse(Int, input)
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