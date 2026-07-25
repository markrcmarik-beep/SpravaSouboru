## Funkce Julia
###############################################################
## Popis funkce:
# Zobrazí grafické menu s možností výběru položky pomocí 
# tlačítek. Uživatel klikne 
# na tlačítko volby.
# ver: 2026-07-25
## Funkce: menuokno()
## Autor: Martin
#
## Cesta uvnitř balíčku:
# SpravaSouboru/src/menu/menuokno.jl
#
## Vzor:
## choice::Int, value::AbstractString = menuokno(prompt::AbstractString,
##     options::Vector{<:AbstractString}; auto_choice::Union{Nothing,Int}=nothing)
## Vstupní proměnné:
# - prompt : text výzvy pro uživatele
# - options : seznam možností k výběru (vektor řetězců)
# - auto_choice : pro testy lze přímo zvolit index (0 = zrušit)
## Výstupní proměnné:
# - choice : index vybrané možnosti (číslo tlačítka)
# - value::AbstractString : text vybrané možnosti
## Použité balíčky
# Gtk4
## Použité funkce:
#
## Příklad:
# choice = menuokno("Vyber možnost:", ["Možnost 1", "Možnost 2", "Konec"])
###############################################################
## Použité proměnné vnitřní:
#
using Gtk4

function menuokno(
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

    # GtkWindow accepts the initial width and height as positional arguments.
    win = GtkWindow(prompt, 300, 50 + 40 * length(options))

    vbox = GtkBox(:v)
    vbox.spacing = 6
    vbox.margin_top = 10
    vbox.margin_bottom = 10
    vbox.margin_start = 10
    vbox.margin_end = 10
    win[] = vbox
    push!(vbox, GtkLabel(prompt))

    for (i, opt) in enumerate(options)
        value = String(opt)
        btn = GtkButton(value)
        btn.hexpand = true
        signal_connect(btn, "clicked") do _
            if !finished[]
                finished[] = true
                put!(result, (i, value))
                destroy(win)
            end
        end
        push!(vbox, btn)
    end

    signal_connect(win, "close-request") do _
        if !finished[]
            finished[] = true
            put!(result, (0, ""))
        end
        false
    end

    show(win)

    # Čekání na volbu uživatele
    choice, value = take!(result)
    return choice, value
end
