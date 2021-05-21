select*
from CovidDeaths$
where continent is not null
order by 3,4

select*
from CovidVaccinations$
where continent is not null
order by 3,4

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
where continent is not null
order by 1,2

--looking at Total Cases VS Total Deaths 
-- shows the likelihood of dying if you contract Covid in the United Kingdom

select location, date, total_cases, total_deaths, (total_deaths / total_cases)* 100 as DeathPercentage 
from CovidDeaths$
where location like '% United Kingdom%' and continent is not null
order by 1,2 

-- looking at the Total Cases vs Population
--shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population)* 100 as PercentageOfPopulationInfected 
from CovidDeaths$
where location like '%United Kingdom%' and continent is not null
order by 1,2 

-- Looking at countries with Highest Infection Rate compared to Population 

select location, population, MAX (total_cases) as HighestInfectionCount, Max((total_cases/population))* 100 as PercentageOfPopulationInfected 
from CovidDeaths$
--where location like '%United Kingdom%'
group by location, population
order by PercentageOfPopulationInfected desc

--showing countries with Highest Death count per Population 

select location, max(cast (total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like '%United Kingdom%'
where continent is not null
group by location
order by TotalDeathCount desc

-- Highest Death by countinent
select location, max(cast (total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like '%United Kingdom%'
where continent is null
group by location
order by TotalDeathCount desc

-- showing countinent with the highest death count per population 

select continent, max(cast (total_deaths as int)) as TotalDeathCount
from CovidDeaths$
--where location like '%United Kingdom%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBER

select 
		sum(new_cases) as total_cases, 
		sum(cast(new_deaths as int)) as total_deaths,  
		sum(cast(new_deaths as int))/ sum(new_cases)* 100 as DeathPercentage 
from CovidDeaths$
--where location like '%United Kingdom%'
where continent is not null
--group by date
order by 1,2


-- getting all information on Vaccinations 

select*
from CovidVaccinations$

-- join CovidDeaths and CovidVaccinations tables.

select*
from CovidDeaths$ as dea join CovidVaccinations$ as vac 
	on dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population VS vaccinations

select	dea.continent, 
		dea.location, 
		dea.date, dea.population, 
		vac.new_vaccinations,
		sum(convert(int, vac.new_vaccinations))
			over (partition by dea.location order by dea.location,dea.date) 
			as RollingPeopleVaccinated
from CovidDeaths$ as dea join CovidVaccinations$ as vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


---USE CTE

With PopvsVac (Continent, Location, Date,Population, new_vaccinations, RollingPeopleVaccinated)
as
(select	dea.continent, 
		dea.location, 
		dea.date, dea.population, 
		vac.new_vaccinations,
		sum(convert(int, vac.new_vaccinations))
			over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from CovidDeaths$ as dea join CovidVaccinations$ as vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select*, (RollingPeopleVaccinated/Population)*100 as percentageOfPopulationVaccinated
from popvsvac 

----TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
	continent nvarchar(255),
	Location nvarchar(255),
	Date  datetime,
	population numeric, 
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select	dea.continent, 
		dea.location, 
		dea.date, dea.population, 
		vac.new_vaccinations,
		sum(convert(int, vac.new_vaccinations))
			over (partition by dea.location order by dea.location,dea.date) 
			as RollingPeopleVaccinated
from CovidDeaths$ as dea join CovidVaccinations$ as vac 
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


select*, (RollingPeopleVaccinated/Population)*100 as percentageOfPopulationVaccinated
from  #PercentPopulationVaccinated

-- creating view to store data for later visualizations

create View PercentPopulationVaccinated as 
select	dea.continent, 
		dea.location, 
		dea.date, dea.population, 
		vac.new_vaccinations,
		sum(convert(int, vac.new_vaccinations))
			over (partition by dea.location order by dea.location,dea.date) 
			as RollingPeopleVaccinated
from CovidDeaths$ as dea join CovidVaccinations$ as vac 
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from PercentPopulationVaccinated
