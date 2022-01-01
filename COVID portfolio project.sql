/* Covid 19 Data Exploration 24-02-2020 to 29-12-2021
Skills gained and utilized:
Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
select * 
from PortfolioSQL..CovidDeaths
order by 3,4

select * 
from PortfolioSQL..CovidVaccinations
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioSQL..CovidDeaths
order by location,date

--Total cases vs total deaths in UK

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Percentage_of_Death
from PortfolioSQL..CovidDeaths
where location like '%kingdom'
order by location,date

-- Total cases vs population in UK

select location,date,total_cases,population,(total_cases/population)*100 as Percentage_of_PopulationAffected
from PortfolioSQL..CovidDeaths
where location like '%kingdom'
order by location,date

-- Countries with highest covid rate

select location,max(total_cases) as Covid_Count,population,max((total_cases/population))*100 as Percentage_of_PopulationAffected
from PortfolioSQL..CovidDeaths
group by location,population
order by Percentage_of_PopulationAffected desc

-- Countries with highest death count

select location,max(cast(total_deaths as int)) as Death_Count
from PortfolioSQL..CovidDeaths
where continent is not null
group by location
order by Death_Count desc

-- Contient-wise death count

select continent,max(cast(total_deaths as int)) as Death_Count
from PortfolioSQL..CovidDeaths
where continent is not null
group by continent
order by Death_Count desc

-- Continents with highest covid rate

select continent,max(total_cases) as Covid_Count,max((total_cases/population))*100 as Percentage_of_PopulationAffected
from PortfolioSQL..CovidDeaths
where continent is not null
group by continent
order by Percentage_of_PopulationAffected desc

-- Global deaths and cases each day as well as death percentage
select date,sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Percentage_of_Death
from PortfolioSQL..CovidDeaths
where continent is not null
group by date
order by date

-- Overall cases,deaths and death percentage in the world
select sum(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as Percentage_of_Death
from PortfolioSQL..CovidDeaths
where continent is not null
order by 1,2

--Total population vs vaccinations
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location,cd.date
) as RollingCount
from PortfolioSQL..CovidDeaths as cd
join PortfolioSQL..CovidVaccinations as cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
order by 2,3


-- Using CTE to show RollingPercentage of Population vaccinated

with pop_vac (continent,location,date,population,new_vaccinations,RollingCount)
as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location,cd.date
) as RollingCount
from PortfolioSQL..CovidDeaths as cd
join PortfolioSQL..CovidVaccinations as cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
)
select * ,(RollingCount/population)*100 as RollingPercentage
from pop_vac

-- Using temp table to show RollingPercentage of Population vaccinated
drop table if exists #RollingPercent
create table #RollingPercent
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCount numeric)

insert into #RollingPercent
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location,cd.date
) as RollingCount
from PortfolioSQL..CovidDeaths as cd
join PortfolioSQL..CovidVaccinations as cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null

select * ,(RollingCount/population)*100 as RollingPercentage
from #RollingPercent

--Creating views

create view RollingPercent as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location,cd.date
) as RollingCount
from PortfolioSQL..CovidDeaths as cd
join PortfolioSQL..CovidVaccinations as cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null


select * from RollingPercent
