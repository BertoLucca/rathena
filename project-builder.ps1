$rAthena = Resolve-Path "$PSScriptRoot";

Write-Host "Stating build proccess.";

if (Test-Path "$rAthena/build") {
    Remove-Item "$rAthena/build/*" -verbose -Force -Recurse;
} else {
    New-Item -ItemType Directory -Path $rAthena -Name "build"
}

$( $images = docker image inspect rag-msvc-compiler:latest | ConvertFrom-Json ) 2>&1 | Out-Null;
if ($images.length -eq 0) {
    Write-Host "Image not found. Starting image build.";
    docker build -t rag-msvc-compiler:latest -f "$rAthena/Dockerfile" $rAthena;
}

Write-Host "Starting compilation.";
docker run --rm `
    --entrypoint /rag/build.bat `
    --mount "type=bind,source=$rAthena,target=C:/rag-ro,readonly" `
    --mount "type=bind,source=$rAthena/build,target=C:/rag/build" `
    rag-msvc-compiler:latest |
Tee-Object -file "$rAthena/.vs/build.log";
