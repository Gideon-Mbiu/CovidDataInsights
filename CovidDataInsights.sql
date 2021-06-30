--Checking Data sets

SELECT * FROM CovidData..CovidDeaths ORDER BY 3,4
SELECT * FROM CovidData..CovidVaccinations ORDER BY 3,4

--Selecting relevant data

SELECT location, date, total_cases, new_cases, total_deaths, population FROM CovidData..CovidDeaths ORDER BY 1,2

--Total cases Vs Total Deaths (percentage death rate)
--Likelihood of an individual dying after contracting Covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageDeaths 
FROM CovidData..CovidDeaths ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageDeaths 
FROM CovidData..CovidDeaths WHERE location LIKE 'Africa' ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageDeaths 
FROM CovidData..CovidDeaths WHERE location LIKE 'Kenya' ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageDeaths 
FROM CovidData..CovidDeaths WHERE location LIKE '%States%' ORDER BY 1,2

--Total cases vs Population (Population percentage with Covid)

SELECT location, date, total_cases, population, (total_cases/population)*100 AS ContractionRate 
FROM CovidData..CovidDeaths ORDER BY 1,2

SELECT location, date, total_cases, population, (total_cases/population)*100 AS ContractionRate 
FROM CovidData..CovidDeaths WHERE location LIKE 'Africa' ORDER BY 1,2

SELECT location, date, total_cases, population, (total_cases/population)*100 AS ContractionRate 
FROM CovidData..CovidDeaths WHERE location LIKE 'Kenya' ORDER BY 1,2

--Highest Infection rate

SELECT location, population, MAX(total_cases) AS total_cases_per_million, MAX((total_cases/population))*100 AS ContractionRate 
FROM CovidData..CovidDeaths GROUP BY location, population ORDER BY ContractionRate DESC

--Lowest Infection Rate
SELECT location, population, MAX(total_cases) AS total_cases_per_million, MAX((total_cases/population))*100 AS ContractionRate 
FROM CovidData..CovidDeaths GROUP BY location, population ORDER BY ContractionRate ASC

--Highest Death Rate
SELECT location, population, MAX(total_deaths) AS total_deaths_per_million, MAX((total_deaths/population))*100 AS DeathRate 
FROM CovidData..CovidDeaths GROUP BY location, population ORDER BY DeathRate DESC

--Highest Deaths per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_deaths_per_population FROM CovidData..CovidDeaths 
GROUP BY location ORDER BY Total_deaths_per_population DESC

SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_deaths_per_population FROM CovidData..CovidDeaths 
WHERE continent IS NOT NULL GROUP BY location ORDER BY Total_deaths_per_population DESC

--Continent wise
SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_deaths_per_population FROM CovidData..CovidDeaths 
WHERE continent IS NULL GROUP BY location ORDER BY Total_deaths_per_population DESC

SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_deaths_per_population FROM CovidData..CovidDeaths 
WHERE continent IS NOT NULL GROUP BY continent ORDER BY Total_deaths_per_population DESC

--Continent with highest death count
SELECT continent, MAX(total_deaths) AS HighestDeaths FROM CovidData..CovidDeaths WHERE continent IS NOT NULL
GROUP BY continent

--Global daily cases
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 
AS PercentageDeaths FROM CovidData..CovidDeaths WHERE continent IS NOT NULL GROUP BY date ORDER BY 1,2

--Total Cases in the world as it stands
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 
AS PercentageDeaths FROM CovidData..CovidDeaths WHERE continent IS NOT NULL ORDER BY 1,2


--**VACCINATIONS**

SELECT * FROM CovidData..CovidVaccinations

--Joinining Both tables

SELECT * FROM CovidData..CovidDeaths Dea JOIN CovidData..CovidVaccinations Vacc ON
Dea.location = Vacc.location AND Dea.date = Vacc.date

--Total Population Vs Vaccinations

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations 
FROM CovidData..CovidDeaths Dea JOIN CovidData..CovidVaccinations Vacc 
ON Dea.location = Vacc.location AND Dea.date = Vacc.date 
WHERE Dea.continent IS NOT NULL ORDER BY 1,2,3

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations 
FROM CovidData..CovidDeaths Dea JOIN CovidData..CovidVaccinations Vacc 
ON Dea.location = Vacc.location AND Dea.date = Vacc.date 
WHERE Dea.continent IS NOT NULL ORDER BY 2,3

--Total Vaccinations Per Day

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations, 
SUM(CAST(Vacc.new_vaccinations AS INT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS TotalVaccinations
FROM CovidData..CovidDeaths Dea JOIN CovidData..CovidVaccinations Vacc 
ON Dea.location = Vacc.location AND Dea.date = Vacc.date 
WHERE Dea.continent IS NOT NULL ORDER BY 2,3

--Extracting Total Population Vs Total Number Vaccinated

--Using CTE

WITH PopVsVacc (continent, location, date, population, new_vaccinations, TotalVaccinations) 
as (
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations, 
SUM(CAST(Vacc.new_vaccinations AS INT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS TotalVaccinations
FROM CovidData..CovidDeaths Dea JOIN CovidData..CovidVaccinations Vacc 
ON Dea.location = Vacc.location AND Dea.date = Vacc.date 
WHERE Dea.continent IS NOT NULL
)
SELECT * FROM PopVsVacc

--Percentage rate of vaccination

WITH PopVsVacc (continent, location, date, population, new_vaccinations, TotalVaccinations) 
as (
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations, 
SUM(CAST(Vacc.new_vaccinations AS INT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS TotalVaccinations
FROM CovidData..CovidDeaths Dea JOIN CovidData..CovidVaccinations Vacc 
ON Dea.location = Vacc.location AND Dea.date = Vacc.date 
WHERE Dea.continent IS NOT NULL
)
SELECT *, (TotalVaccinations/population)*100 AS PercentageVaccinations FROM PopVsVacc

--Using Temp Table

--DROP TABLE IF EXISTS #PercentagePopVacc
CREATE TABLE #PercentagePopVacc 
( 
continent VARCHAR(255),
location VARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
total_vaccinations NUMERIC
)
INSERT INTO #PercentagePopVacc
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations, 
SUM(CAST(Vacc.new_vaccinations AS INT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS TotalVaccinations
FROM CovidData..CovidDeaths Dea JOIN CovidData..CovidVaccinations Vacc 
ON Dea.location = Vacc.location AND Dea.date = Vacc.date 
WHERE Dea.continent IS NOT NULL

SELECT *, (total_vaccinations/population)*100 AS PercentageVaccinations FROM #PercentagePopVacc

--VIEW CREATION

CREATE VIEW GlobalDailyCases AS
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 
AS PercentageDeaths FROM CovidData..CovidDeaths 
WHERE continent IS NOT NULL GROUP BY date --ORDER BY 1,2

SELECT * FROM GlobalDailyCases


CREATE VIEW PercentagePopVacc AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations, 
SUM(CAST(Vacc.new_vaccinations AS INT)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) AS TotalVaccinations
FROM CovidData..CovidDeaths Dea JOIN CovidData..CovidVaccinations Vacc 
ON Dea.location = Vacc.location AND Dea.date = Vacc.date 
WHERE Dea.continent IS NOT NULL

SELECT * FROM PercentagePopVacc

CREATE VIEW PercentageDeathRate AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageDeaths 
FROM CovidData..CovidDeaths --ORDER BY 1,2

SELECT * FROM PercentageDeathRate

CREATE VIEW VaccinatedPopulation AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, Vacc.new_vaccinations 
FROM CovidData..CovidDeaths Dea JOIN CovidData..CovidVaccinations Vacc 
ON Dea.location = Vacc.location AND Dea.date = Vacc.date 
WHERE Dea.continent IS NOT NULL --ORDER BY 2,3

SELECT * FROM VaccinatedPopulation







