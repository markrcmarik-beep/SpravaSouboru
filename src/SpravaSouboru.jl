# ver: 2026-01-09
module SpravaSouboru

# Import implementací
include("sprdsheet2velkst.jl")
include("sprsheetRef.jl")
include("sprsheet2tabl.jl")
include("sync_folders.jl")
#include("menugui.jl")
include("menutext.jl")
include("zalohovat.jl")
include("copyfile_preserve_times.jl")


# Export funkcí
export sprdsheet2velkst, sprsheetRef, sprsheet2tabl, sync_folders, 
menugui, menutext, zalohovat

end # module SpravaSouboru
