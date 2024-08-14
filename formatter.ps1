$bin = Get-ChildItem -path "$HOME/.vscode/extensions/ms-vscode.cpptools*" -Recurse -Filter "clang-format.exe";

If (-not $bin) {
    return
}

$rAthena = Resolve-Path "$PSScriptRoot"
$src = Resolve-Path "$rAthena/src";
$files = Get-ChildItem -Path $src -Recurse -Filter "*.?pp";

& "$($bin.FullName)" -style="file:$rAthena/.clang-format" --Wno-error=unknown --verbose -i $files
