--Covid 19 Data Report
--Skills used: Creating Views, Aggregate Functions, Converting Data Types, Windows Functions, CTE'S, join's, Temp Table

SELECT*
FROM project.dbo.['owid-covid_deaths]
WHERE location IS NOT NULL
ORDER BY 1,2

--  We'll Select Data that we are going to be starting with 

Select
Location,
date, 
total_cases,
new_cases,
total_deaths,
population
From project.dbo.['owid-covid_deaths]
Where continent is not null 
order by 1,2

--looking to see wich countries have higest number of death by covid

SELECT
location AS Country,
MAX(cast(total_deaths AS INT)) AS total_deaths_count,
--MAX((total_cases/population))*100 AS Max_Percentage_get_infected,
--date,
--total_cases,
--new_cases,
--total_deaths,
--(total_cases/population)*100 AS percentage_got_covid,
--total_vaccinations,
population
  FROM [project].[dbo].['owid-covid_deaths]
  WHERE continent IS NOT NULL
  GROUP BY  location,population-- ,total_cases,date 
ORDER BY  total_deaths_count DESC
-------So this table Showing that USA is the number one in the world that have highest number of deaths by Covid, after USA come Brazil and India-----/



--In this queery we'll see wich continent have highest number of deaths---
SELECT
--location AS Country,
MAX(cast(total_deaths AS INT)) AS total_deaths_count,
continent
--MAX((total_cases/population))*100 AS Max_Percentage_get_infected,
--date,
--total_cases,
--new_cases,
--total_deaths,
--(total_cases/population)*100 AS percentage_got_covid,
--total_vaccinations,
--population
  FROM [project].[dbo].['owid-covid_deaths]
  WHERE continent IS NOT NULL
  GROUP BY continent --population-- ,total_cases,date 
ORDER BY  total_deaths_count DESC

-- Shows likelihood of dying if you contract covid in your country

Select 
Location,
date,
total_cases,total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
From [project].[dbo].['owid-covid_deaths]
Where location =  'canada'
and continent is not null 
order by 1,2


/***************************/
--We'll be Looking to see the Numeber of New deaths and new cases Globaly 

SELECT
--location AS Country,
continent,
date,
SUM(new_cases) AS total_cases, SUM(CAST (new_deaths AS INT)) AS total_deaths
--SUM(CAST(new_deaths AS INT))/sum(new_cases)*100 as death_percentage
--total_cases,
--new_cases,
--total_deaths,
--(total_cases/population)*100 AS percentage_got_covid,
--total_vaccinations,
--population

  FROM [project].[dbo].['owid-covid_deaths]
 WHERE continent IS NOT NULL --AND continent NOT IN ('international,world,africa')
  GROUP BY date,continent --population-- ,total_cases,date 
ORDER BY 1,2

/****************************/
-- We'll be looking to this table to find out wich country scored high number of Covid infections
--and then we'll see wich country has less covid infections

SELECT
location AS Country,
max(total_cases) AS heighest_infection,
MAX((total_cases/population))*100 AS Percentage_get_infected,
date,
total_cases,
--new_cases,
--total_deaths,
--(total_cases/population)*100 AS percentage_got_covid,
--total_vaccinations,
population
FROM [project].[dbo].['owid-covid_deaths]
--WHERE location  ='CANADA' AND total_deaths IS  NOT NULL
GROUP BY  location,population,total_cases,date 
ORDER BY 1,2 DESC
--table for country who have less covid infection
SELECT
location AS Country,
MIN(total_cases) AS minimum_infection,
MIN((total_cases/population))*100 AS Percentage_get_infected,
date,
total_cases,
--new_cases,
--total_deaths,
--(total_cases/population)*100 AS percentage_got_covid,
--total_vaccinations,
population
FROM [project].[dbo].['owid-covid_deaths]
--WHERE location  ='CANADA' AND total_deaths IS  NOT NULL
GROUP BY  location,population,total_cases,date 
ORDER BY 1,2

/****************************************************/

/******total of peoples get vacinated ******/

--Now we'll be looking to see the peoples who got vacination per population,and for that we'll be joining Covid death table on covid vacination table

WITH peopVSpopu(continent,location,date,poulation,total_People_get_vacinated,new_vaccination) 
AS
(

SELECT
d.location,
d.continent,
d.date,
d.population,
v.new_vaccinations,
SUM(CONVERT(INT,v.new_vaccinations)) OVER(PARTITION by d.location) AS total_People_get_vacinated
 FROM [project].[dbo].['owid-covid_deaths] d
 JOIN project.dbo.CovidVaccinations v
 ON d.location = v.location AND d.date = v.date
  WHERE d.continent IS NOT NULL
--ORDER BY  1,2
)
SELECT*,(total_People_get_vacinated/poulation)*100 AS percentage_get_vacinated
FROM peopVSpopu

---covid GLOBAL---

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM [project].[dbo].['owid-covid_deaths]
--Where location like '%states%'
WHERE continent is not null 
--Group By date
ORDER BY 1,2

/*------------------creating view for later visualizations---------*/
CREATE VIEW  PercentPopulationVaccinated AS
SELECT 
dea.continent,
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [project].[dbo].['owid-covid_deaths] dea
JOIN  project.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 

