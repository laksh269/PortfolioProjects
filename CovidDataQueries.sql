Select *
from CovidProjectDatabase..CovidDeaths
where continent is not null
order by 3,4

--Select Data that is being used in project
Select location, date, total_cases, new_cases, total_deaths, population
from CovidProjectDatabase..CovidDeaths
where continent is not null
order by 1,2

--Looking at total_cases vs total_deaths in UK
--Shows likelihood of dying if you contract covid if you contract covid in your country
Select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
from CovidProjectDatabase..CovidDeaths
where location like 'United Kingdom'
order by 1,2

--Looking at Total Cases vs Population in UK
Select location, date, total_cases, population, (total_cases/ population)*100 as InfectedPercentage
from CovidProjectDatabase..CovidDeaths
where location like 'United Kingdom'
order by 1,2

--LET'S COMPARE COUNTRIES

--Looking at countries with highest infection rate by population
Select location, MAX(total_cases) as HighestInfectionCount, population, max(total_cases/ population)*100 as InfectedPercentage
from CovidProjectDatabase..CovidDeaths
where continent is not null
group by location, population
order by InfectedPercentage desc

-- Looking at countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as DeathCount, population, max(total_deaths/ population)*100 as DeathPercentage
from CovidProjectDatabase..CovidDeaths
where continent is not null
group by location, population
order by DeathCount desc

-- Looking at countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as DeathCount, population, max(total_deaths/ population)*100 as DeathPercentage
from CovidProjectDatabase..CovidDeaths
where continent is not null
group by location, population
order by DeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continent with highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from CovidProjectDatabase..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
--Death Percentage Per Day
Select date, 
sum(new_cases) as TotalCases, 
sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidProjectDatabase..CovidDeaths
where continent is not null
group by date
order by 1,2 

--Looking at Total Population vs Vaccinations
-- Using CTE
with PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RolllingPeopleVaccinated
From CovidProjectDatabase..CovidDeaths dea
Join CovidProjectDatabase..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *
From PopvsVac
Order by 1,2

-- Using Temp Table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RolllingPeopleVaccinated
From CovidProjectDatabase..CovidDeaths dea
Join CovidProjectDatabase..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
from #PercentPopulationVaccinated

--Create views for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RolllingPeopleVaccinated
From CovidProjectDatabase..CovidDeaths dea
Join CovidProjectDatabase..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
from CovidProjectDatabase..PercentPopulationVaccinated