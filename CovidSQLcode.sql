Select *
from PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

Select *
from PortfolioProject..CovidVaccinations
order by 3,4

-- Select data that we are going to be using

Select continent, location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at the total cases vs total deaths
-- Shows the likelyhood of dying if you contract covid in the United Kingdom
Select continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%Kingdom%'
order by 1,2

-- Looking at the total cases vs population
-- Shows what percentage of population got Covid
Select continent, location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Where location like '%Kingdom%'
order by 1,2

-- Looking at which country has the highest infection rate compared to population

Select continent,location, population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%Kingdom%'
Group by continent, location, population
order by PercentPopulationInfected desc

-- Showing the countries with the highest Death count per population

Select continent,location, population, MAX(cast(total_deaths as int)) as HighestDeathCount, MAX((total_deaths/population))*100 as PercentDeathPopulation
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent, location, population
order by HighestDeathCount desc

-- Showing contients with the highest death count

Select continent, location, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by continent, location
order by HighestDeathCount desc

-- Showing the contients with the highest death count

Select continent, location, max(cast(total_deaths as int)) as Highestdeathcount
from PortfolioProject..CovidDeaths
Where continent is not null
group by continent, location
order by Highestdeathcount desc



-- Global numbers of cases & deaths

SELECT date SUM(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- total global number of cases and deaths 

SELECT SUM(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Joining CovidDeath and Covid Vaccinations table

Select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
	

-- looking at total populations vs vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (rollingpeoplevaccinated/new_vaccination)
from PortfolioProject..CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- Temp table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (rollingpeoplevaccinated/new_vaccination)
from PortfolioProject..CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


	
-- Creating View to store data for later visulisations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- (rollingpeoplevaccinated/new_vaccination)
from PortfolioProject..CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

