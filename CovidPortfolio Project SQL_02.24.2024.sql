Select*
From PortfolioProject..CovidDeaths
where continent is not Null
order by  3,4


Select*
From PortfolioProject..CovidVaccinations
where continent is not Null
order by  3,4
--column add
--shows the likelyhood of dying if you contract in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like 'sri lanka'
order by  1,2

--Looking at total case vs population
--shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%states%'
where continent is not Null
order by  1,2

--looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not Null
Group by location, Population
order by PercentPopulationInfected desc

--showing countries with highest death count per population
Select location, population, MAX(total_deaths) as HighestDeaths, MAX((total_deaths/population))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not Null
Group by location, Population
order by DeathPercentage desc

--this didn't give the correct decending order due to data type so we changet the total deaths column data to integer in next query
Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not Null
Group by location
order by TotalDeathCount desc


--let's BREAK DOWN BY CONTINENT
--Showing continents with the highest death count per population

Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is Null
Group by location
order by TotalDeathCount desc


--Showing continents with the highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not Null
Group by continent
order by TotalDeathCount desc

--Global numbers

Select SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not Null
--Group by date
order by 1,2

Select*
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--looking at total populations and Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--looking at total populations and new -Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast (vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) 
--as RollingPeopleVaccinated,

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USW CTE
with PopvsVac (continent, location, Date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast (vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) 
--as RollingPeopleVaccinated,

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select*, (RollingPeopleVaccinated/population) *100
from PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric

)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(cast (vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) 
--as RollingPeopleVaccinated,

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select*, (RollingPeopleVaccinated/population) *100
from #PercentPopulationVaccinated



--Creating view to store data for later visualizations 

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert (int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date) 
as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
--Select*, (RollingPeopleVaccinated/population) *100
--from #PercentPopulationVaccinated

--Work table to use Tablau
Select*
From PercentPopulationVaccinated