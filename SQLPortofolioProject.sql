

SELECT continent, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths;



-- Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
where location like '%states%'
order by 1,2;

-- Looking at Total cases vs Population 
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM coviddeaths
where location like '%states%'
order by 1,2;

-- Looking at countries with highest infection rates comapred to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM coviddeaths
Group by location, population
order by PercentagePopulationInfected desc;

-- Showing coutries with Highest Death count per population
-- Looking at Total Cases vs Total Deaths
SELECT location, MAX(CAST(total_deaths as signed integer)) as TotalDeaths
FROM coviddeaths
where not continent = ''  -- To skip the null continents
Group by location
order by TotalDeaths desc;

-- Arrange things by Continents
-- Showing Continents with highest death count

SELECT continent, MAX(CAST(total_deaths as signed integer)) as TotalDeaths
FROM coviddeaths
WHERE not continent = '' -- To skip the null continents
Group by continent
order by TotalDeaths desc;


-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths))/(SUM(new_cases))*100 as DeathPercentage
FROM coviddeaths
where not continent = ''
Group by date
order by 1,2;


-- Vaccinations ; 

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (Partition by d.location order by d.location, d.date) as RollingPeopleVaccinated 
FROM coviddeaths D 
JOIN covidvaccinations v
	ON d.location = v.location 
    and d.date = v.date
WHERE not d.continent = ''
order by 2,3; 

-- CTE 
With PopvVac (Continent, Location, Date, Population , NewVaccinations, RollingPeopleVaccinated)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (Partition by d.location order by d.location, d.date) as RollingPeopleVaccinated 
FROM coviddeaths D 
JOIN covidvaccinations v
	ON d.location = v.location 
    and d.date = v.date
WHERE not d.continent = ''
)
select * , (RollingPeopleVaccinated/Population)*100
FROM PopvVac


-- Temp Table

DROP Table if exists PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations Text, 
RollingPeopleVaccinated numeric
)
Insert into PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (Partition by d.location order by d.location, d.date) as RollingPeopleVaccinated 
FROM coviddeaths D 
JOIN covidvaccinations v
	ON d.location = v.location 
    and d.date = v.date
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated;

-- Create  View to store data for later visualization
CREATE VIEW PercentagePopulationVaccinated as 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(v.new_vaccinations) OVER (Partition by d.location order by d.location, d.date) as RollingPeopleVaccinated 
FROM coviddeaths D 
JOIN covidvaccinations v
	ON d.location = v.location 
    and d.date = v.date
WHERE not d.continent = ''












