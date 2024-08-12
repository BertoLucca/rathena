$rAthena = Resolve-Path "$PSScriptRoot";

if (Test-Path "$rAthena/build/*") {
    Remove-Item "$rAthena/build/*" -verbose -Force -Recurse;
}

$( $images = docker image inspect rag-msvc-compiler:latest | ConvertFrom-Json ) 2>&1 | Out-Null;
if ($images.length -eq 0) {
    docker build -t rag-msvc-compiler:latest -f "$rAthena/Dockerfile" $rAthena;
}

docker run --rm `
    --entrypoint /rag/build.bat `
    --mount "type=bind,source=$rAthena,target=C:/rag-ro,readonly" `
    --mount "type=bind,source=$rAthena/build,target=C:/rag/build" `
    rag-msvc-compiler:latest;
