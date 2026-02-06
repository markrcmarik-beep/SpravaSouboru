## Funkce Julia
###############################################################
## Popis funkce:
# Zobrazí grafické menu s možností výběru položky pomocí 
# tlačítek. Uživatel klikne 
# na tlačítko volby.
# ver: 2026-02-06
## Funkce: menugui()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# SpravaSouboru/src/menu/menugui.jl
#
## Vzor:
## choice::Int, value::AbstractString = menugui(prompt::AbstractString,
##     options::Vector{<:AbstractString}; auto_choice::Union{Nothing,Int}=nothing)
## Vstupní proměnné:
# - prompt : text výzvy pro uživatele
# - options : seznam možností k výběru (vektor řetězců)
# - auto_choice : pro testy lze přímo zvolit index (0 = zrušit)
## Výstupní proměnné:
# - choice : index vybrané možnosti (číslo tlačítka)
# - value::AbstractString : text vybrané možnosti
## Použité balíčky
# Gtk
## Použité funkce:
#
## Příklad:
# choice = menugui("Vyber možnost:", ["Možnost 1", "Možnost 2", "Konec"])
###############################################################
## Použité proměnné vnitřní:
#
using Gtk, Gtk.ShortNames

function menugui(
    prompt::AbstractString,
    options::Vector{<:AbstractString};
    auto_choice::Union{Nothing,Int}=nothing,
)
    result = Channel{Tuple{Int,String}}(1)
    finished = Ref(false)

    if auto_choice !== nothing
        if auto_choice == 0
            return 0, ""
        elseif 1 <= auto_choice <= length(options)
            return auto_choice, options[auto_choice]
        else
            throw(ArgumentError("auto_choice mimo rozsah možností"))
        end
    end

    # Vytvoření okna s požadovanou velikostí
    win = Window(prompt; width=300, height=50 + 40*length(options))
    set_gtk_property!(win, :border_width, 10)

    vbox = Box(:v)
    push!(win, vbox)
    push!(vbox, Label(prompt))

    for (i, opt) in enumerate(options)
        btn = Button(opt)
        signal_connect(btn, "clicked") do _
            if !finished[]
                finished[] = true
                put!(result, (i, opt))
                destroy(win)
            end
        end
        push!(vbox, btn)
    end

    signal_connect(win, "delete-event") do _, _
        if !finished[]
            finished[] = true
            put!(result, (0, ""))
        end
        false
    end

    showall(win)

    # Čekání na volbu uživatele
    choice, value = take!(result)
    return choice, value
end
