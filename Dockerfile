FROM microsoft/iis

# Install Chocolatey
RUN @powershell NoProfile -InputFormat None -ExecutionPolicy unrestricted -Command "(iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

#Install Build Tools
RUN powershell add-windowsfeature web-asp-net45 \
&& choco install microsoft-build-tools -y -version 15.9.23 \
&& choco install dotnet4.8-targetpack -y \
&& choco install nuget.commandline -y \
&& nuget install MSBuild.Microsoft.VisualStudio.Web.targets -Version 15.9.23 \
&& nuget install WebConfigTransformRunner -Version 1.0.0.1

#Copy Files

RUN md c:\dockerappbuild
WORKDIR c:/dockerappbuild
COPY . c:/dockerappbuild

# Restore package, build, copy
RUN nuget restore \
    && "c:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin\MSBuild.exe" /p:VSToolPath=c:\Program Files (x86)\Jenkins\workspace\MS_Build_Job\ASPPageApp\ASPPageApp.sln \
	&& 	xcopy c:\Program Files (x86)\Jenkins\workspace\MS_Build_Job\ASPPageApp\ASPPageApp\* c:\inetpub\wwwroot\HelloDockerApp /s
	
ENTRYPOINT powershell .\InitializeContainer
