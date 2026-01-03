## Funkce Julia
###############################################################
## Popis funkce:
# Kopíruje soubor ze zdrojové cesty na cílovou cestu se zachováním
# původních časových atributů (mtime, atime, creation time).
# Funguje na Linux, macOS i Windows.
# ver: 2025-11-19
## Funkce: []=copyfile_preserve_times()
#
## Vzor:
## []=copyfile_preserve_times(src, dst)
## Vstupní proměnné:
# src - Cesta ke zdrojovému souboru. [string]
# dst - Cesta k cílovému souboru nebo adresáři. [string]
## Výstupní proměnné:
#
## Použité balíčky
#
## Použité funkce:
#
## Příklad:
# >> copyfile_preserve_times("zdroj.txt", "cil.txt")

## Použité proměnné vnitřní:
#
"""
    copyfile_preserve_times(src::AbstractString, dst::AbstractString)

Zkopíruje soubor `src` do `dst` se zachováním původních časových atributů.
Funguje na Linux, macOS i Windows.

- Zachovává mtime, atime, creation time (pokud OS umožní).
- `dst` může být cesta k cílovému souboru nebo adresáři.
"""
function copyfile_preserve_times(src::AbstractString, dst::AbstractString)
    # Ověření, zda zdroj existuje a je soubor
    if !isfile(src)
        throw(ArgumentError("Zdroj není soubor: $src"))
    end
    # Ujistíme se, že cílový adresář existuje
    mkpath(isdir(dst) ? dst : dirname(dst))
    ###########################################################################
    # 1) Kopie souboru (bez ohledu na OS)
    ###########################################################################
    # Base.cp kopíruje obsah, nikoli metadata – ta nastavíme po kopii.
    cp(src, dst; force=true)
    ###########################################################################
    # 2) Obnovení časových atributů podle OS
    ###########################################################################
    if Sys.iswindows()
        #######################################################################
        # WINDOWS — použijeme PowerShell a nastavíme:
        # CreationTime, LastWriteTime (mtime), LastAccessTime (atime)
        #######################################################################
        ps_cmd = """
        \$s = Get-Item -LiteralPath '$src';
        \$d = Get-Item -LiteralPath '$dst';
        \$d.CreationTime      = \$s.CreationTime;
        \$d.LastWriteTime     = \$s.LastWriteTime;
        \$d.LastAccessTime    = \$s.LastAccessTime;
        """
        run(`powershell -NoProfile -Command $ps_cmd`)
    elseif Sys.isunix()
        #######################################################################
        # LINUX / macOS — nejlepší je "cp --preserve=timestamps" nebo "touch -r"
        #######################################################################
        try
            # Nejprve se pokusíme zachovat časy přímo
            run(`cp --preserve=timestamps "$src" "$dst"`)
        catch
            # Fallback – obnovíme časy příkazem touch -r
            try
                run(`touch -r "$src" "$dst"`)
            catch e
                @warn "Nepodařilo se obnovit časové atributy: $e"
            end
        end
    else
        @warn "Neznámý operační systém, nelze zachovat časové atributy."
    end

    return nothing
end