--Make a selection of the data we will be using

Select  Location, date, total_cases, new_cases, total_deaths, population 
From Covid19..CovidDeaths
Order by 1,2 



--Total Cases vs Total Deaths (Likelihood of dying if you contract covid in your country)

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
From Covid19..CovidDeaths
Where location like '%states'
Order by 1,2



--Total Cases vs Population (Shows what percentage of population got Covid)

Select Location, date, population, total_cases,(total_cases/population)*100 PopulationPercentage
From Covid19..CovidDeaths
Where location like '%states'
Order by 1,2



-- Countries with Highest Infection Rate compared to Population

Select Location, population, Max(total_cases) HighestInfectionCount, Max((total_cases/population))*100 PercentPopulationInfected
From Covid19..CovidDeaths
Where continent is not null
Group by location, population
Order by PercentPopulationInfected DESC



-- Countries with Highest Death Count per Population

Select Location, Max(total_deaths) TotalDeathCount
From Covid19..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount DESC



-- Continents with Highest Deaths Count 

Select location, Max(total_deaths) TotalDeathCount
From Covid19..CovidDeaths
Where continent is null
and location not like '%income'
Group by location, population
Order by TotalDeathCount DESC



-- Global Statistics

Select SUM(new_cases) total_cases, SUM(new_deaths) total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 DeathPercentage
From Covid19..CovidDeaths
where continent is not null 
order by 1,2



-- Total Population vs Vaccinations (Shows Count of People who has recieved at least one Covid Vaccine)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(vac.new_vaccinations) over (partition by dea.location Order by dea.location, dea.date) CumulativePeopleVaccinated
From Covid19..CovidDeaths dea
Join Covid19..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



-- Using CTE to perform Calculation for Percentage of Population that has recieved at least one Covid Vaccine

With PopvsVac As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(vac.new_vaccinations) over (partition by dea.location Order by dea.location, dea.date) CumulativePeopleVaccinated
From Covid19..CovidDeaths dea
Join Covid19..CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
)
Select  *, (CumulativePeopleVaccinated/ population)*100 VaccinatedPeoplePercent
From PopvsVac
Order By location, date



-- Using Temp Table to perform Calculation for Percentage of Population that has recieved at least one Covid Vaccine

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativePeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) CumulativePeopleVaccinated
From Covid19..CovidDeaths dea
Join Covid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (CumulativePeopleVaccinated/Population)*100 VaccinatedPeoplePercent
From #PercentPopulationVaccinated
Order By location, date



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) CumulativePeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19..CovidDeaths dea
Join Covid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
