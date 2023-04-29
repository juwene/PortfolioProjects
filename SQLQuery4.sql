select *
from PortfolioProject..['covid deaths$']
order by 3,4;

--select *
--from PortfolioProject..['covid vaccinations$']
--order by 3,4; 

-- selecting the data we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..['covid deaths$']
order by 1,2;

-- checking the total cases vs the total deaths

select location, date, total_cases, total_deaths, cast(total_deaths as float)/cast(total_cases as float) * 100 as deathpercentage
from PortfolioProject..['covid deaths$']
where location like '%nigeria%'
order by 1,2;

-- comparing the total cases to population

select location, date, total_cases, population, cast(total_cases as float)/cast(population as float) * 100 as PercentagePopulationInfected
from PortfolioProject..['covid deaths$']
--where location like '%nigeria%'
order by 1,2 desc;


-- the country with the highest infection rate
select location, date, population, max(total_cases) as highestInfectionCount, max(cast(total_cases as float)/cast(population as float)) * 100 as PercentagePopulationInfected
from PortfolioProject..['covid deaths$']
group by location, date, population
order by PercentagePopulationInfected desc;

-- checking if it was correct
select location,date, population,total_cases, max(total_cases) as maximumcase
from PortfolioProject..['covid deaths$']
where location like '%cyprus%'
group by population, location, date, total_cases
order by date desc;

-- making it much cleaner(the country with the highest infection rate)
select location,  population, max(total_cases) as highestInfectionCount, max(cast(total_cases as float)/cast(population as float)) * 100 as PercentagePopulationInfected
from PortfolioProject..['covid deaths$']
group by location, date, population
order by PercentagePopulationInfected desc;


-- showing the country with highest death count per Population

select location,   max(total_deaths) as TotalDeathCounts
from PortfolioProject..['covid deaths$']
group by location
order by 1 

select location,   max(total_deaths) as TotalDeathCounts
from PortfolioProject..['covid deaths$']
where location like '%state%'
group by location
order by TotalDeathCounts desc

select location,   max(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject..['covid deaths$']
where continent is not NULL
group by location
order by 1 

-- Checking why vatican is null
select location, date ,  max(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject..['covid deaths$']
where continent is not NULL and location like '%vatican%'
group by location, date
order by 1 

--- checking the continent
select continent,   max(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject..['covid deaths$']
where continent is not NULL
group by continent
order by 1

-- Global numbers

select date, sum(new_cases) as Total_cases,  sum(cast(new_deaths as int)) as Total_death, sum(cast(new_deaths as int)) /nullif(sum(new_cases),0)* 100 as deathpercentage
from PortfolioProject..['covid deaths$']
where continent is not null 
group by date
order by 1,2;

-- loking at the total people vaccinated in the world

select *
from PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as PeopleVacinated
from PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--- by using cte
with popvsvac(continent,location,date,population,new_vaccinations,PeopleVacinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as PeopleVacinated
from PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *, (PeopleVacinated/population)*100 as PopulationVaccinePercentage
from popvsvac

-- temp table
Drop Table if exists PercentagePopulationVaccinated
Create Table PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)
insert into PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *, (PeopleVaccinated/Population) *100 as VaccinatedPeoplePercentage
from PercentagePopulationVaccinated

--Creating view to store data for visualisation later

 Create view PercentagePopulationVaccines as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProject..['covid deaths$'] dea
join PortfolioProject..['covid vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


select *
from PercentagePopulationVaccines