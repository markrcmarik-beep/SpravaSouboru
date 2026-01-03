# ver: 2026-01-03
using SpravaSouboru

cest = @__DIR__
SpravaSouboru.copyfile_preserve_times(joinpath(cest,"menugui_test.jl"), 
    joinpath(cest,"a","menugui_test.jl"))