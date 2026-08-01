## Balíček Julia v1.12
###############################################################
## Popis balíčku
#
# ver: 2026-08-01
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
# menu
include("menu/menuokno.jl")
include("menu/menutext.jl")

include("sprsheet2tabl/sprsheet2tabl.jl")
include("sprsheet2velkst/sprsheet2velkst.jl")
include("sprsheetRef.jl")
include("sync_folders.jl")
include("zalohovat.jl")
include("copyfile_preserve_times.jl")


# Export funkcí
export 
# menu
menuokno, menutext,
# výchozí src
sprsheet2tabl, sprsheet2velkst, sprsheetRef, sync_folders, 
 zalohovat

end # module SpravaSouboru
