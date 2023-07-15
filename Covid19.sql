#calculate total deaths percentage
select date, location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid19.coviddeaths

#Look at total cases, deaths, and calculate deathpercentage in selected countries 
select date, location, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
from Covid19.coviddeaths
where location in ('United States', 'China', 'Italy')

#Look at total vaccination, tests, and positive rate
SELECT d.date, d.location, d.total_cases, d.total_deaths, v.total_tests, v.positive_rate, v.total_vaccinations
FROM Covid19.coviddeaths AS d
JOIN Covid19.covidvaccination AS v
ON d.location = v.location
where d.location in ('United States', 'China', 'Italy');

#Look at the location with total deaths
select location, max(cast(Total_deaths as SIGNED)) as totaldeathcount
from Covid19.coviddeaths
where location is not null
group by location
order by totaldeathcount desc

#top 10 countries have highest percentage of population infected, percentage of deaths
select  location, population, sum(cast(new_cases as signed))/population *100 as PercentPopulationInfected,
	sum(cast(new_deaths as signed))/population *100 as PercentPopulationDeaths 
from Covid19.coviddeaths
where continent is not null
group by  location, population
order by PercentPopulationInfected desc;

#Look at how many new vaccination in North America, and accumulate the total vaccinations
select d.date, d.location, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.date) as RollingVaccination
from Covid19.coviddeaths d
join Covid19.covidvaccination v
on d.location = v.location
and d.date = v.date
where d.continent = 'North America'
order by 1,2;

#Looking at the average vaccination in Europe Continent
SELECT deaths.continent, deaths.location, deaths.date, vaccination.new_vaccinations,
AVG(vaccination.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.date) as RollingAvg_Vaccines
FROM Covid19.coviddeaths deaths
JOIN Covid19.covidvaccination vaccination
ON deaths.location = vaccination.location
AND deaths.date = vaccination.date
WHERE deaths.continent = 'Europe'
ORDER BY location, date;

#CTE Calculating Percentage of Total Vaccinated people over Population
With TotalRollingVaccination (Date, Location, Population, Vaccine, RollingVaccination) as
(
select d.date, d.location, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.date) as RollingVaccination
from Covid19.coviddeaths d
join Covid19.covidvaccination v
on d.location = v.location
and d.date = v.date
where d.continent = 'North America'
order by 1,2
)

select *, (RollingVaccination/Population)*100 as Percent_People_Get_Vaccination from TotalRollingVaccination

#Show Previous Number of Vaccinated per day in location
With CTE as (
SELECT date, location, new_vaccinations, lag(new_vaccinations) over(partition by date and location) as Prev_Vaccinations
FROM Covid19.covidvaccination
)
Select *
from CTE



