# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/s", "/c"]

WORKDIR /rag
RUN mkdir C:\rag-ro && `
    echo xcopy /s /e C:\rag-ro C:\rag > build.bat && `
    echo msbuild .\rAthena.sln /p:PlatformToolset=v143 >> build.bat

RUN `
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe `
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
        --installPath "C:\BuildTools" `
        --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
        --add Microsoft.VisualStudio.Component.VC.CoreBuildTools `
        --add Microsoft.VisualStudio.Component.Windows10SDK.20348 `
        || IF "%ERRORLEVEL%"=="3010" EXIT 0) `
    && del /q vs_buildtools.exe
RUN setx /M path "%path%;C:\BuildTools\MSBuild\Current\Bin"

ENTRYPOINT [ "cmd", "/c", "ping", "-t", "localhost", ">", "NUL" ]
