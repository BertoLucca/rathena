# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["cmd", "/s", "/c"]

WORKDIR /rag
RUN mkdir C:\BuildTools && `
    mkdir C:\rag-ro && `
    echo xcopy /s /e C:\rag-ro C:\rag > build.bat && `
    echo msbuild .\rAthena.sln /p:PlatformToolset=v143 >> build.bat

RUN mkdir C:\TEMP && `
    echo @echo off > C:\TEMP\install.cmd && `
    echo call %* >> C:\TEMP\install.cmd && `
    echo if "%ERRORLEVEL%"=="3010" ( >> C:\TEMP\install.cmd && `
    echo     exit /b 0 >> C:\TEMP\install.cmd && `
    echo ) else ( >> C:\TEMP\install.cmd && `
    echo     if not "%ERRORLEVEL%"=="0" ( >> C:\TEMP\install.cmd && `
    echo         set ERR=%ERRORLEVEL% >> C:\TEMP\install.cmd && `
    echo         call C:\TEMP\collect.exe -zip:C:\vslogs.zip >> C:\TEMP\install.cmd && `
    echo         exit /b !ERR! >> C:\TEMP\install.cmd && `
    echo     ) >> C:\TEMP\install.cmd && `
    echo ) >> C:\TEMP\install.cmd

ADD https://aka.ms/vscollect.exe C:\TEMP\collect.exe
ADD https://aka.ms/vs/17/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe
ADD https://aka.ms/vs/17/release/channel C:\TEMP\VisualStudio.chman

# https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2022
RUN C:\TEMP\Install.cmd C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --channelUri C:\TEMP\VisualStudio.chman `
    --installChannelUri C:\TEMP\VisualStudio.chman `
    --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended `
    --installPath C:\BuildTools

RUN del /q C:\TEMP && `
    setx /M path "%path%;C:\BuildTools\MSBuild\Current\Bin"

ENTRYPOINT [ "cmd", "/c", "ping", "-t", "localhost", ">", "NUL" ]
