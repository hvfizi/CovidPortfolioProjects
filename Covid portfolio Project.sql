select * 
from PortfolioProject..['CovidDeaths']
order by 3,4

--select * 
--from PortfolioProject..['CovidVacination']
--order by 3,4

-- select data that i will using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..['CovidDeaths']
order by 1,2

-- looking at total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..['CovidDeaths']
where location = 'Malaysia'
order by 1,2

-- looking at total cases vs population 
select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
from PortfolioProject..['CovidDeaths']
--where location = 'Malaysia'
order by 1,2

-- looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfection, MAX(total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..['CovidDeaths']
group by location, population
order by PercentagePopulationInfected desc

-- showing countries with highest death count per population
select location, max(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..['CovidDeaths']
where continent is not null
group by location
order by TotalDeathCount desc

-- showing continent with highest death count per population
select continent, max(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..['CovidDeaths']
where continent is not null
group by continent
order by TotalDeathCount desc

--global
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..['CovidDeaths']
where continent is not null
order by 1,2


-- Looking at total population vs vaccination
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(cast(v.new_vaccinations as bigint)) OVER(partition by d.location order by d.location, d.date) as TotalVac
from PortfolioProject..['CovidDeaths'] d
join PortfolioProject..['CovidVacination'] v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
order by 2,3

-- use CTE

with PopVsVac (Continent, location, date, population, new_vaccinations, totalVac)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(cast(v.new_vaccinations as bigint)) OVER(partition by d.location order by d.location, d.date) as TotalVac
from PortfolioProject..['CovidDeaths'] d
join PortfolioProject..['CovidVacination'] v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
)
select *, (totalVac/population)*100 as PercentVacinate
from PopVsVac

-- temp table

drop table if exists #PercentPopulationVaccinted
create table #PercentPopulationVaccinted 
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVac numeric
)

insert into #PercentPopulationVaccinted
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(cast(v.new_vaccinations as bigint)) OVER(partition by d.location order by d.location, d.date) as TotalVac
from PortfolioProject..['CovidDeaths'] d
join PortfolioProject..['CovidVacination'] v
	on d.location = v.location
	and d.date = v.date
--where d.continent is not null

select *, (totalVac/population)*100 as PercentVacinate
from #PercentPopulationVaccinted

--Create view to store data for visualization later
create view PercentPopulationVaccinted as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(cast(v.new_vaccinations as bigint)) OVER(partition by d.location order by d.location, d.date) as TotalVac
from PortfolioProject..['CovidDeaths'] d
join PortfolioProject..['CovidVacination'] v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinted
 
   
