
SELECT DISTINCT location 
FROM PortfolioProject..CovidDeaths 
WHERE location is not null 


SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null 
ORDER BY 3,4 




--Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
order by 1, 2 

-- Looking at Total Cases vs Total Deaths 

--shows likelihood of dying if you contract COVID in your country 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
order by 1, 2 


-- Looking at the Total Cases vs the Population
--shows what Percentage of population got Covid 
SELECT location, date, population, total_cases,  (total_cases/population) * 100 as PercentPopulationInfected 
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
order by 1, 2 

-- looking at Countries with Highest Infection Rate compared to Population 

SELECT location,  population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population)) * 100 
as PercentPopulationInfected 
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population 
order by PercentPopulationInfected desc 

-- Showing Country with Highest Death Count per Population 
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL 
GROUP BY location 
order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT 


--showing continents with highest death count 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL 
GROUP BY continent
order by TotalDeathCount desc 



--GLOBAL NUMBERS 
SELECT  date, SUM(new_cases) as total_case , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage  
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date 
ORDER BY 1, 2 



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date ) as RollingPeopleVaccinated
 
FROM PortfolioProject.dbo.CovidDeaths as dea 
JOIN PortfolioProject.dbo.CovidVaccinations vac 
ON dea.location = vac.location  
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3 





SELECT * 
FROM PortfolioProject.dbo.CovidDeaths as dea 
JOIN PortfolioProject.dbo.CovidVaccinations vac 
ON dea.location = vac.location  
AND dea.date = vac.date 


--Use CTE  

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date ) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths as dea 
JOIN PortfolioProject.dbo.CovidVaccinations vac 
ON dea.location = vac.location  
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3 
) 
SELECT *, (RollingPeopleVaccinated/population) * 100 
FROM PopvsVac




--Temp Table 
DROP Table if exists #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths as dea 
JOIN PortfolioProject.dbo.CovidVaccinations vac 
ON dea.location = vac.location  
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3 

SELECT *, (RollingPeopleVaccinated/population) *100 
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations 

CREATE View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths as dea 
JOIN PortfolioProject.dbo.CovidVaccinations vac 
ON dea.location = vac.location  
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3






