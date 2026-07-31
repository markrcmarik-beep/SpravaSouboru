# ver: 2026-07-31
using Documenter
using SpravaSouboru

makedocs(
    sitename = "SpravaSouboru",
    modules = [SpravaSouboru],
    pages = [
        "Uvod" => "index.md",
        # menu
        "menuokno" => "menu/menuokno.md",
        "menutext" => "menu/menutext.md",

        "zalohovat" => "zalohovat.md",
        "Pouziti balicku" => "pouziti.md",
        "API" => "api.md"
    ],
)
