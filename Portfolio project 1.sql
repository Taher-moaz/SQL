use [PortfolioProjects]
select *
from
	[dbo].[CovidDeaths$]
order by 3,4
--select *
--from
--	[dbo].[CovidVaccinations$]
--order by 3,4
select location,date,total_cases,new_cases,total_deaths,population
from [dbo].[CovidDeaths$]
order by 1,2
-- looking at total cases vs total deaths
-- show liklihood of dying if you contract covit in you country
select location,date,total_cases,new_cases,total_deaths,format((total_deaths/total_cases)*100,'N') as deathpercentage
from [dbo].[CovidDeaths$]
where location like '%gypt%'
order by 1,2

-- looking at total cases vs population
-- shows what percentage of population got Covid
select location,date,total_cases,
new_cases,
format(population,'N0') as population,
format((total_cases/population)*100,'N') as infectionpercentage
from [dbo].[CovidDeaths$]
where location like '%gypt%'
order by 1,2


-- Countries with the hightest infection rate per the population
select 
	location,max(total_cases)as highestInfectionCount,
	
	format(population,'N0') as pop,
	format(max((total_cases/population))*100,'N') as Maxinfectionpercentage
from [dbo].[CovidDeaths$]
-- where location like '%gypt%'
group by
	location,population
order by 
	Maxinfectionpercentage desc

-- show the countreies with the highest death per population
select *
from [dbo].[CovidDeaths$];
select 
	location,max(total_cases)as highestInfectionCount,
	max((cast(total_deaths as int)/population))*100 as total_death,
	format(population,'N0') as pop,
	format(max((total_cases/population))*100,'N') as Maxinfectionpercentage
from [dbo].[CovidDeaths$]
-- where location like '%gypt%'
group by
	location,population
order by 
	total_death desc
-- show the countreies with the highest death count
select *
from [dbo].[CovidDeaths$]
where 
	location  = 'world'
select 
	location,format(max(cast(total_deaths as int)),'N0')as highestDeathCount,
	format(population,'N0') as pop
from [dbo].[CovidDeaths$]
-- where location like '%gypt%'
 where
	continent IS NOT NULL
	
group by
	location,population
order by 
	max(cast(total_deaths as int)) desc
-- let break them down by continent

select 
	location,format(max(cast(total_deaths as int)),'N0')as highestDeathCount
from [dbo].[CovidDeaths$]
where
	continent IS NULL
	
group by
	location
order by 
	max(cast(total_deaths as int)) desc

-- global new cases
select 
	date,format(sum(cast(new_cases as int)),'N0')as new_cases,
	format(sum(cast(new_deaths as int)),'N0') as new_deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100
from [dbo].[CovidDeaths$]
where
	continent IS not NULL
	
group by
	date
order by 
	1,2 desc


-- looking and  the total population vs total vacination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location)
from [dbo].[CovidDeaths$] as dea
join [dbo].[CovidVaccinations$] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
order by 2,3


-- use a cte called vaccination vs populaition
with PopVsVac as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date,dea.location) as rollingVacination
from [dbo].[CovidDeaths$] as dea
join [dbo].[CovidVaccinations$] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null

)

select *,(rollingVacination/population)*100
from PopVsVac
-- temp table
drop table if exists #percentPopulationVacinated
create table #percentPopulationVacinated
(
continent varchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingVacination numeric)

Insert into #percentPopulationVacinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date,dea.location) as rollingVacination
from [dbo].[CovidDeaths$] as dea
join [dbo].[CovidVaccinations$] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
--order by 2,3

select *,(rollingVacination/population)*100
from #percentPopulationVacinated

-- create data to store data for later review
create view percentPopulationVacinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date,dea.location) as rollingVacination
from [dbo].[CovidDeaths$] as dea
join [dbo].[CovidVaccinations$] as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
--order by 2,3