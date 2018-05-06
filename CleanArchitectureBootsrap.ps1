Param(
    [string] [Parameter(Mandatory=$true)] $SolutionName,
    [ValidateSet('netcoreapp2.1.4','netcoreapp2.1.4')]
    [string] $framework = "netcoreapp2.1.4"
)

# Create source directory and change directory to it
New-Item -ItemType Directory -Path $SolutionName | Out-Null
Set-Location -Path $SolutionName

# Set some defaults names & paths
$webProject = $SolutionName + ".Web"
$domainProject =$SolutionName + ".domain"
$persistenceProject =$SolutionName + ".persistence"
$apiProject =$SolutionName + ".api"
$servicesProject =$SolutionName + ".service"
$servicesTestProject = "$servicesProject.Tests"

$webProjectPath = "$webProject\$webProject.csproj"
$domainProjectPath = "$domainProject\$domainProject.csproj"
$persistenceProjectPath = "$persistenceProject\$persistenceProject.csproj"
$apiProjectPath = "$apiProject\$apiProject.csproj"
$servicesProjectPath = "$servicesProject\$servicesProject.csproj"
$servicesTestProjectPath = "$servicesTestProject\$servicesTestProject.csproj"

#Create all of our individual projects
dotnet new mvc --name $webProject  
dotnet new classlib --name $domainProject
dotnet new classlib --name $persistenceProject
dotnet new webapi --name $apiProject
dotnet new classlib --name $servicesProject 
dotnet new xunit --name $servicesTestProject

#Add all of our individual projects to the solution
dotnet new sln --name $SolutionName
dotnet sln add .\$webProjectPath
dotnet sln add .\$domainProjectPath 
dotnet sln add .\$persistenceProjectPath 
dotnet sln add .\$apiProjectPath 
dotnet sln add .\$servicesProjectPath
dotnet sln add .\$servicesTestProjectPath

# Add all the of the nessessary project references
dotnet add .\$webProjectPath reference .\$domainProjectPath 
dotnet add .\$webProjectPath reference .\$persistenceProjectPath 
dotnet add .\$webProjectPath reference .\$servicesProjectPath

dotnet add .\$apiProject reference .\$domainProjectPath 
dotnet add .\$apiProject reference .\$persistenceProjectPath
dotnet add .\$apiProject reference .\$servicesProjectPath

dotnet add .\$servicesProjectPath reference .\$domainProjectPath 
dotnet add .\$servicesTestProjectPath reference .\$domainProjectPath 
dotnet add .\$servicesProjectPath reference .\$persistenceProjectPath 
dotnet add .\$servicesTestProjectPath reference .\$persistenceProjectPath 
dotnet add .\$servicesTestProjectPath reference .\$servicesProjectPath


#Add EntityFrame Work Core Package to Persistence Project
dotnet add .\$persistenceProjectPath package Microsoft.EntityFrameworkCore.Design

#Add Automapper Package to WebProject
dotnet add .\$persistenceProjectPath package AutoMapper --version 6.2.2
dotnet add .\$persistenceProjectPath package AutoMapper.Extensions.Microsoft.DependencyInjection --version 3.2.0


dotnet restore
dotnet build ".\$SolutionName.sln"
dotnet test .\$servicesTestProjectPath