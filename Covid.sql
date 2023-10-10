--Make a selection of the data we will be using
Select Location, date, total_cases, new_cases, total_deaths, population 
From CovidDeaths
Order by 1,2 

--Total Cases vs Total Deaths (Likelihood of dying if you contract covid in your country)
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
From CovidDeaths
Where location like '%states'
Order by 1,2

--Total Cases vs Population (Shows what percentage of population got Covid)
Select Location, date, population, total_cases,(total_cases/population)*100 PopulationPercentage
From CovidDeaths
Where location like '%states'
Order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select Location, population, Max(total_cases) HighestInfectionCount, Max((total_cases/population))*100 PercentPopulationInfected
From CovidDeaths
Group by location, population
Order by PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population