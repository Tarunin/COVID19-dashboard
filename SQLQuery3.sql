-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidProject..CovidDeaths$
where continent is not null 
order by 1,2


-- 2. 

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  ROUND(Max((total_cases/population))*100,2) as PercentPopulationInfected
From CovidProject..CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population, CONVERT(date,date) AS date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths$
Group by Location, Population, date
order by PercentPopulationInfected desc

--5.

WITH PopVSVac (location, date, continent, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT death.location, death.date, death.continent, death.population, vaccine.new_vaccinations, SUM(CONVERT(bigint,vaccine.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths$ death
JOIN CovidProject..CovidVaccinations$ vaccine
ON death.location = vaccine.location
AND death.date = vaccine.date
WHERE death.continent IS NOT NULL AND vaccine.new_vaccinations IS NOT NULL
)
SELECT location, continent, population, new_vaccinations, RollingPeopleVaccinated, (RollingPeopleVaccinated/population*100) AS VaccinatedPecentage, MAX(CONVERT(date,date)) AS date
FROM PopVSVac
Group by location, continent, population, new_vaccinations, RollingPeopleVaccinated, (RollingPeopleVaccinated/population*100)
ORDER BY location,date