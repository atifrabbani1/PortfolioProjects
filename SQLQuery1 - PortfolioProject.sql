Select *
From PortfolioPrjoject..CovidDeaths
order by 3,4


--Select *
--From PortfolioPrjoject..CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioPrjoject..CovidDeaths
order by 1,2

-- Total cases vs Total Deaths

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioPrjoject..CovidDeaths
Where location = 'Pakistan'
order by 1,2

-- Total Cases vs Population

Select location, date ,population , total_cases ,(total_cases/population)*100 as AffectedPercentage
From PortfolioPrjoject..CovidDeaths
Where location = 'Pakistan'
order by 1,2

-- Looking at countries with highest infection rate compared to population.

Select location, population , MAX(total_cases) as HighestInfectionCount , MAX((total_cases/population))*100 as AffectedPercentage
From PortfolioPrjoject..CovidDeaths
--Where location = 'Pakistan'
Group by location,population
order by AffectedPercentage DESC


-- Countries with highes death count per population.

Select location, MAX(cast(total_deaths as int)) as TotalDeathCOunt
From PortfolioPrjoject..CovidDeaths
--Where location = 'Pakistan'
where continent is not null
Group by location
order by TotalDeathCOunt DESC

-- Lets break things down by continent


-- Showing the continent with highest death count.


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioPrjoject..CovidDeaths
--Where location = 'Pakistan'
where continent is not null
Group by continent
order by TotalDeathCOunt DESC


-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioPrjoject..CovidDeaths
--Where location = 'Pakistan'
where continent is not null
--Group by date
order by 1,2


-- Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioPrjoject..CovidDeaths dea
JOIN PortfolioPrjoject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioPrjoject..CovidDeaths dea
JOIN PortfolioPrjoject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioPrjoject..CovidDeaths dea
JOIN PortfolioPrjoject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioPrjoject..CovidDeaths dea
JOIN PortfolioPrjoject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated



