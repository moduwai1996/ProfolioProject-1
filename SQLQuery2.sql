select * from dbo.Sheet1$
select location, date,total_cases, new_cases,total_deaths, population from dbo.Sheet1$

--looking  at total cases vs total Death 

SELECT
    location,
    date,
    total_cases,
    total_deaths,
    CASE
        WHEN total_cases > 0 THEN total_deaths * 1.0 / total_cases
        ELSE NULL
    END AS death_rate
FROM
    dbo.Sheet1$
ORDER BY
    location,
    date;

--SELECT
--    location,
--    date,
--    CONVERT(INT, total_cases) AS total_cases,
--    CONVERT(INT, total_deaths) AS total_deaths,
--    CASE
--        WHEN total_cases > 0 THEN CONVERT(FLOAT, total_deaths) / total_cases
--        ELSE NULL
--    END AS death_rate
--FROM
--    dbo.Sheet1$
--ORDER BY
--    location,
--    date;

select 
 location,
    date,
    total_cases,
    total_deaths,
	population from dbo.Sheet1$
	where location = 'Liberia'

	-- looking at the total cases vs the population 
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    population,
    CASE
        WHEN population > 0 THEN (total_deaths * 100.0) / population
        ELSE NULL
    END AS DeathParcentage 
FROM
    dbo.Sheet1$
WHERE
    location = 'Liberia'
ORDER BY
    1, 2;

	--checking country with highest infection rate 
	
SELECT
    location,
    population,
    MAX(CAST(total_cases AS INT)) AS HighestInfectionCount,
    MAX(CAST(total_cases AS FLOAT) * 100.0 / NULLIF(CAST(population AS FLOAT), 0)) AS PopulationPercentageInfected
FROM
    dbo.sheet1$
	--where location = 'liberia'
GROUP BY
    location, population
ORDER BY
    population DESC;

select location, max(cast(total_deaths as int)) As TotalDeath from dbo.Sheet1$
Where continent is null
group by Location 

order by TotalDeath desc 

-- breaking things down by continent 

select continent, max(cast(total_deaths as int)) As TotalDeath from dbo.Sheet1$
Where continent is not null
group by continent

order by TotalDeath desc 

--globel checking 
select sum(new_cases) as TotalCases, 
sum(cast(new_deaths as int)) as totaldeath,
sum(cast(new_deaths as int))
/ sum(new_cases) * 100 as TotalDeathParcentage 
from dbo.Sheet1$
where continent is not null
order by 1,2

--looking at total populaton vs vaccinations 

SELECT
    continent,
    location,
   population
    new_vaccinations,
    SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY location ORDER BY date) AS total_vaccinations_per_location
FROM
    dbo.Sheet1$
WHERE
    continent IS NOT NULL
ORDER BY
    location, population


	--checking rolling vaccinations per_polulaton

	with PovVac ( 
	continent,
    location,
	date,
   population,
    new_vaccinations,
	rollingPeoplevaccinated)
	as
	(
	
	SELECT
    continent,
    location,
	date,
   population,
    new_vaccinations,
    SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY location ORDER BY date) As rollingPeoplevaccinated
FROM
    dbo.Sheet1$
WHERE
    continent IS NOT NULL
--ORDER BY
)
select *,( rollingPeoplevaccinated/population) *100 as parcentagevaccinated
from PovVac


--tem TABLE
drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated 
(
continent nvarchar(255),
    location nvarchar(255),
	date datetime,
   population numeric,
    new_vaccinations numeric,
	rollingPeoplevaccinated numeric
	)
	insert into  #PercentPopulationVaccinated 
	SELECT
    continent,
    location,
	date,
   population,
    new_vaccinations,
	--rollingPeoplevaccinated,
    SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY location ORDER BY date) As rollingPeoplevaccinated
FROM
    dbo.Sheet1$
WHERE
    continent IS NOT NULL
--ORDER BY

select *,( rollingPeoplevaccinated/population) *100 as parcentagevaccinated
from #PercentPopulationVaccinated 

select * from #PercentPopulationVaccinated 


--crerating view to store data for later 



create view PercentPopulationVaccinated  AS


	SELECT
    continent,
    location,
	date,
   population,
    new_vaccinations,
    SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY location ORDER BY date) As rollingPeoplevaccinated
FROM
    dbo.Sheet1$
WHERE
    continent IS NOT NULL
--ORDER BY