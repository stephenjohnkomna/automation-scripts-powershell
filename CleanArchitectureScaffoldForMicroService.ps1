Param(
    [string] [Parameter(Mandatory=$true)] $SolutionName,
    [ValidateSet('netcoreapp2.1.4','netcoreapp2.1.4')]
    [string] $framework = "netcoreapp2.1.4"
)

# Create source directory and change directory to it
New-Item -ItemType Directory -Path $SolutionName | Out-Null
Set-Location -Path $SolutionName

# Set some defaults names & paths
$domainProject =$SolutionName + ".domain"
$persistenceProject =$SolutionName + ".persistence"
$apiProject =$SolutionName + ".api"
$servicesProject =$SolutionName + ".service"
$servicesTestProject = "$servicesProject.Tests"


$domainProjectPath = "$domainProject\$domainProject.csproj"
$persistenceProjectPath = "$persistenceProject\$persistenceProject.csproj"
$apiProjectPath = "$apiProject\$apiProject.csproj"
$servicesProjectPath = "$servicesProject\$servicesProject.csproj"
$servicesTestProjectPath = "$servicesTestProject\$servicesTestProject.csproj"

#Create all of our individual projects 
dotnet new classlib --name $domainProject
dotnet new classlib --name $persistenceProject
dotnet new webapi --name $apiProject
dotnet new classlib --name $servicesProject 
dotnet new xunit --name $servicesTestProject

#Add all of our individual projects to the solution
dotnet new sln --name $SolutionName
dotnet sln add .\$domainProjectPath 
dotnet sln add .\$persistenceProjectPath 
dotnet sln add .\$apiProjectPath 
dotnet sln add .\$servicesProjectPath
dotnet sln add .\$servicesTestProjectPath

# Add all the of the nessessary project references

dotnet add .\$apiProject reference .\$domainProjectPath 
dotnet add .\$apiProject reference .\$persistenceProjectPath
dotnet add .\$apiProject reference .\$servicesProjectPath

dotnet add .\$persistenceProject reference .\$domainProjectPath

dotnet add .\$servicesProjectPath reference .\$domainProjectPath 
dotnet add .\$servicesTestProjectPath reference .\$domainProjectPath 
dotnet add .\$servicesProjectPath reference .\$persistenceProjectPath 
dotnet add .\$servicesTestProjectPath reference .\$persistenceProjectPath 
dotnet add .\$servicesTestProjectPath reference .\$servicesProjectPath


#Add EntityFrame Work Core Package to Persistence Project
dotnet add .\$persistenceProjectPath package Microsoft.EntityFrameworkCore.Design

#Add Swagger Package to the WebAPI Project
dotnet add .\$apiProjectPath package Swashbuckle.AspNetCore

#Add Cors(Cross Origin Request) Package to the WebAPI Project
dotnet add .\$apiProjectPath package Microsoft.AspNetCore.Cors -Version 2.0.2

dotnet restore
dotnet build ".\$SolutionName.sln"
dotnet test .\$servicesTestProjectPath