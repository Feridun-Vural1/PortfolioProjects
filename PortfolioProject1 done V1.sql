Select * From PortfolioProject1..CovidDeaths
Where continent is not null
order by 3,4


Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%turkey%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, date, total_cases, population, (NULLIF(CONVERT(float, total_cases / population), 0))*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
Where location like '%turkey%'
order by 1,2

--Countries with highest infection rate compared to population

Select Location, population, MAX(Convert(bigint, total_cases)) as HighestInfectionCount, Max((Convert(bigint, total_cases) / population))*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers by date
Select date, SUM(new_cases) as total_cses, SUM(CAST(new_deaths as int)) as total_deaths, NULLIF(SUM(CAST(new_deaths as int))/SUM(new_cases)*100, 0) as DeathPercentage
From PortfolioProject1..CovidDeaths
--Where location like '%turkey%'
Where continent is not null
Group by date
order by 1,2

--Global Numbers
Select SUM(new_cases) as total_cses, SUM(CAST(new_deaths as int)) as total_deaths, NULLIF(SUM(CAST(new_deaths as int))/SUM(new_cases)*100, 0) as DeathPercentage
From PortfolioProject1..CovidDeaths
--Where location like '%turkey%'
Where continent is not null
order by 1,2


--Total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
Where dea.continent is not null
Order by 2,3

--CTE created
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp table
DROP Table IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated--,(RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Created View to store data for later visualizations
USE PortfolioProject1
Go
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated 