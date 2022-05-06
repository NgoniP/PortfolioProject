-- convert blank cells into null values
UPDATE covid_facts.`covid deaths` SET continent = NULL WHERE continent = '';
SELECT * FROM covid_facts.`covid deaths`;

SELECT * FROM covid_facts.`covid deaths`;
SELECT location,
population,
date,
total_cases,
new_cases
total_deaths
FROM covid_facts.`covid deaths`
order by 1,2;

SELECT location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as fatality_rate
FROM covid_facts.`covid deaths`
where location like '%states%'
order by 1,2;

-- showing countries with the highest infection rates
SELECT location,
population,
max(total_cases) as total_infection,
max((total_cases/population))*100 as infection_rate
FROM covid_facts.`covid deaths`
group by location,population
order by infection_rate desc;

-- showing continents with the highest death rates
SELECT continent,
max(cast(total_deaths as UNSIGNED)) as total_deathrate
FROM covid_facts.`covid deaths`
WHERE continent is not null
group by continent
order by total_deathrate desc;

-- show all the global cases
SELECT
SUM(cast(new_deaths as UNSIGNED)) as total_deaths,
SUM(new_cases) as total_cases,
SUM(cast(new_deaths as UNSIGNED))/SUM(new_cases)*100 as death_rate
FROM covid_facts.`covid deaths`
WHERE continent is not null;

-- Looking at vaccinations
SELECT de.continent,de.location, de.date, new_vaccinations
FROM covid_facts.`covid deaths` de
join covid_facts.`covid vaccinations` vac
on de.date = vac.date
and de.location = vac.location
where de.continent is not null
order by 2,3;

-- running total on new vaccination
SELECT de.continent,de.location, de.date, new_vaccinations, de.population,SUM(cast(new_vaccinations as unsigned)) 
OVER (PARTITION by de.location order by de.location, de.date) as rolling_count
FROM covid_facts.`covid deaths` de
join covid_facts.`covid vaccinations` vac
on de.date = vac.date
and de.location = vac.location
where de.continent is not null
order by 2,3;

-- looking for vacinations as a percentage of population
-- create a temporaray 
SELECT de.continent,de.location, cast(de.date as datetime), cast(new_vaccinations as unsigned), de.population,((SUM(cast(new_vaccinations as unsigned)) 
OVER (PARTITION by de.location order by de.location, de.date))/de.population)*100 as vac_per_population
FROM covid_facts.`covid deaths` de
join covid_facts.`covid vaccinations` vac
on de.date = vac.date
and de.location = vac.location
where de.continent is not null
order by 2,3;

-- CREATING VIEWS TO STORE DATA FROM ABOVE SQL QUERIES
Create view  rollingcount_vac AS
SELECT de.continent,de.location, de.date, new_vaccinations, de.population,SUM(cast(new_vaccinations as unsigned)) 
OVER (PARTITION by de.location order by de.location, de.date) as rolling_count
FROM covid_facts.`covid deaths` de
join covid_facts.`covid vaccinations` vac
on de.date = vac.date
and de.location = vac.location
where de.continent is not null
order by 2,3;

Create view highest_infections AS
SELECT location,
population,
max(total_cases) as total_infection,
max((total_cases/population))*100 as infection_rate
FROM covid_facts.`covid deaths`
group by location,population
order by infection_rate desc;

CREATE VIEW death_rate AS
SELECT continent,
max(cast(total_deaths as UNSIGNED)) as total_deathrate
FROM covid_facts.`covid deaths`
WHERE continent is not null
group by continent
order by total_deathrate desc;

CREATE VIEW usa_daily_fatality as
SELECT location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as fatality_rate
FROM covid_facts.`covid deaths`
where location like '%states%'
order by 1,2;