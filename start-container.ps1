$rAthena = Resolve-Path "$PSScriptRoot";

if (Test-Path "$rAthena/build/*") {
    Remove-Item "$rAthena/build/*" -verbose -Force -Recurse;
}

$_ = $( $images = docker image inspect rag-msvc:latest | ConvertFrom-Json ) 2>&1;
if ($images.length -eq 0) {
    docker build --no-cache -t rag-msvc:latest -f "$rAthena/Dockerfile" $rAthena ;
}

docker run --rm `
    --entrypoint /rag/build.bat `
    --mount "type=bind,source=$rAthena/build,target=C:/rag/build" `
    rag-msvc:latest;
