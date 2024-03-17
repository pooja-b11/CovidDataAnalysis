-- DECLARE @datetable TABLE(VaccinationDate DATE, iso_code NVARCHAR(50))
 
-- INSERT INTO @datetable
-- SELECT cast(convert(varchar, [date]) as date) VC, iso_code FROM CovidVaccinations

-- UPDATE dbo.CovidVaccinations SET VaccinationDate = dt.VaccinationDate
-- FROM @datetable dt
-- INNER JOIN dbo.CovidVaccinations cv ON CV.iso_code = DT.iso_code 

-- ALTER TABLE dbo.CovidVaccinations drop COLUMN [date]

-- SELECT * FROM CovidVaccinations

SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- SELECT location, date, total_cases, new_cases, total_deaths, population
-- FROM PortfolioProject.dbo.CovidDeaths
-- ORDER BY 1,2

--Looking at the Total_cases vs Total_deaths
--Showing likelihood of dying if you contact covid in your country
SELECT location, date, total_cases, total_deaths,((total_deaths*1.0) / (total_cases*1.0))*100 as death_percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at Total cases vs population
--what % of population got covid
SELECT location, date, total_cases,population,((total_cases*1.0) / (population*1.0))*100 as percentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location LIKE '%states%'
ORDER BY 1,2


--Highest infected rate country
SELECT location,population, MAX(total_cases) as HighestInfectionCount, MAX(((total_cases*1.0) / (population*1.0)))*100 as percentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY percentPopulationInfected DESC   


--highest death count per population
SELECT location, MAX(total_deaths) as TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
-- WHERE location LIKE '%states%'
GROUP BY location
ORDER BY TotalDeathCount DESC   

-- BREAK THINGS BY CONTINENT
--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(total_deaths) as TotalDeathCount 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
-- WHERE location LIKE '%states%'
GROUP BY continent
ORDER BY TotalDeathCount DESC   


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, (SUM(new_deaths)*1.0/SUM(new_cases)*1.0)*100 as death_percentage
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY death_percentage DESC

-- Total death and cases around the world
SELECT SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, (SUM(new_deaths)*1.0/SUM(new_cases)*1.0)*100 as death_percentage
FROM PortfolioProject.dbo.CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1,2;

-- JOINING BOTH TABLES
--Looking at total population vs vaccinations
--USE CTE

With  PopVsVac (continent, location, date, population,new_vaccinations,rolling_vaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = dea.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)
SELECT *,(rolling_vaccinations*1.0/population*1.0)*100
FROM PopVsVac



--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_vaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = dea.date
-- WHERE dea.continent IS NOT NULL
ORDER BY 2,3
SELECT *,(rolling_vaccinations*1.0/population*1.0)*100
FROM #PercentPopulationVaccinated

--creating view for later visuals

CREATE VIEW PercentPopulationVaccinated  AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinations
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = dea.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT*
FROM PercentPopulationVaccinated