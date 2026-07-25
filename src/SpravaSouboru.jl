## Balíček Julia v1.12
###############################################################
## Popis balíčku
#
# ver: 2026-07-25
## Cesta uvnitř balíčku:
# SpravaSouboru/src/SpravaSouboru.jl
#
## Použité balíčky:
#
###############################################################
## Použité proměnné vnitřní:
#
module SpravaSouboru

# Import implementací
include("sprdsheet2velkst.jl")
include("sprsheetRef.jl")
include("sprsheet2tabl.jl")
include("sync_folders.jl")
include("menu/menuokno.jl")
include("menu/menutext.jl")
include("zalohovat.jl")
include("copyfile_preserve_times.jl")


# Export funkcí
export sprdsheet2velkst, sprsheetRef, sprsheet2tabl, sync_folders, 
menuokno, menutext, zalohovat

end # module SpravaSouboru
