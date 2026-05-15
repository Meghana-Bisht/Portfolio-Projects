
SELECT *
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProjects..CovidVaccinations$
--ORDER BY 3,4;

-- COVID DEATHS TABLE
--Select data that we are going to be using

SELECT location, date, total_cases,new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths$
WHERE continent IS NOT NULL
order by 1,2
;

--Looking at the Total Cases Vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases) * 100) AS 'Death_Percentage'
FROM PortfolioProjects..CovidDeaths$
WHERE location LIKE '%India%' AND continent IS NOT NULL
order by 1,2
;

--Looking at Total cases vs Population
--Shows what percentage of population got covid

SELECT location, date,  population, total_cases,((total_cases/population) * 100) AS 'Percentage_population_affected'
FROM PortfolioProjects..CovidDeaths$
-- WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
order by 1,2
;

--Looking at countries with Hightest Infection rate compared to population

SELECT location, population, MAX(total_cases) AS HightestInfectionCount,(MAX((total_cases/population)) * 100) AS 'Percentage_population_affected'
FROM PortfolioProjects..CovidDeaths$
--WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
GROUP BY location, population
order by Percentage_population_affected DESC
;

--Showing the countries with Highest Death Count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths$
--WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
GROUP BY location
order by TotalDeathCount DESC
;

-- let's break things down by Continents

-- Showing the continent with highest death counts

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProjects..CovidDeaths$
--WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
GROUP BY continent
order by TotalDeathCount DESC
;

-- Breaking Global Numbers

SELECT SUM(new_cases) AS TotalNewCases, SUM(cast(new_deaths as int)) AS TotalNewDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases)*100) AS 'Death_Percentage'
FROM PortfolioProjects..CovidDeaths$
--WHERE location LIKE '%India%' 
WHERE continent IS NOT NULL
--GROUP BY date
order by 1,2
;

--COVID VACCINAION TABLE

-- Looking at Total population Vs Vaccinations

SELECT *
FROM PortfolioProjects..CovidVaccinations$
ORDER BY 3,4;

SELECT cd.continent, cd.location,  cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) --SUM(CONVERT(INT,new_vaccinations))
OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingVaccinations
--(RollingVaccinations)/Population * 100
FROM PortfolioProjects..CovidDeaths$ AS cd
JOIN PortfolioProjects..CovidVaccinations$ AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3
;

--USE CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingVaccinations)
AS
(
SELECT cd.continent, cd.location,  cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) --SUM(CONVERT(INT,new_vaccinations))
OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingVaccinations
--(RollingVaccinations)/Population * 100
FROM PortfolioProjects..CovidDeaths$ AS cd
JOIN PortfolioProjects..CovidVaccinations$ AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingVaccinations/Population)*100 AS RollingVacPercentage
FROM PopVsVac
;

-- TEMP TABLE

DROP TABLE if exists #PercntPopulationVaccinated
CREATE TABLE #PercntPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vacciantions numeric,
RollingVaccinations numeric
)
INSERT INTO #PercntPopulationVaccinated
SELECT cd.continent, cd.location,  cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) --SUM(CONVERT(INT,new_vaccinations))
OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingVaccinations
--(RollingVaccinations)/Population * 100
FROM PortfolioProjects..CovidDeaths$ AS cd
JOIN PortfolioProjects..CovidVaccinations$ AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
--WHERE cd.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingVaccinations/Population)*100 AS RollingVacPercentage
FROM #PercntPopulationVaccinated
;


-- Creating View to store data for later visualiazations

CREATE View #PercntPopulationVaccinated AS
SELECT cd.continent, cd.location,  cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) --SUM(CONVERT(INT,new_vaccinations))
OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingVaccinations
--(RollingVaccinations)/Population * 100
FROM PortfolioProjects..CovidDeaths$ AS cd
JOIN PortfolioProjects..CovidVaccinations$ AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
--ORDER BY 2,3
;

SELECT *
FROM #PercntPopulationVaccinated;