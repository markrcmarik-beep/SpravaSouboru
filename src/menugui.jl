## Funkce Julia
###############################################################
## Popis funkce:
# Zobrazí grafické menu s možností výběru položky pomocí tlačítek. Uživatel klikne 
# na tlačítko volby.
# ver: 2025-11-13
## Funkce: menugui()
#
## Vzor:
## choice::Int = menugui(prompt::String, options::Vector{String})
## Vstupní proměnné:
# - prompt : text výzvy pro uživatele
# - options : seznam možností k výběru (vektor řetězců)
## Výstupní proměnné:
# - choice : index vybrané možnosti (číslo tlačítka)
# - options::Vector{String} : seznam možností k výběru
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

function menugui(prompt::AbstractString, options::Vector{<:AbstractString})
    result = Channel{Tuple{Int,String}}(1)

    # Vytvoření okna s požadovanou velikostí
    win = Window(prompt; width=300, height=50 + 40*length(options))
    set_gtk_property!(win, :border_width, 10)

    vbox = Box(:v)
    push!(win, vbox)
    push!(vbox, Label(prompt))

    for (i, opt) in enumerate(options)
        btn = Button(opt)
        signal_connect(btn, "clicked") do _
            put!(result, (i, opt))
            destroy(win)
        end
        push!(vbox, btn)
    end

    showall(win)

    # Čekání na volbu uživatele
    choice, value = take!(result)
    return choice, value
end