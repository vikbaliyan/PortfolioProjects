select *
from Porfolio.dbo.CovidDeaths
order by 3,4

--select *
--from Porfolio.dbo.CovidVaccinations
--order by 3,4

--select data that I'm going to use

select location,date,total_cases, new_cases, total_deaths, population
from Porfolio..CovidDeaths
order by 1,2

--Looking at total cases vs total Deaths in india
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from Porfolio..CovidDeaths
where location like '%india%'
order by 1,2

--total cases vs population
--percentage of population got covid
select location,date,total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
from Porfolio..CovidDeaths
where location like '%india%'
order by 1,2

--countries with highest infection rate compared to population
select location,population,max(total_cases) as HighestinfectionCount,population, max((total_cases/population))*100 as PercentPopulationInfected
from Porfolio..CovidDeaths
--where location like '%india%'
group by location,population
order by PercentPopulationInfected desc


--countries with highest death count per population
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Porfolio..CovidDeaths
where continent is not null
--where location like '%india%'
group by location
order by TotalDeathCount desc

------continents with highest death count per population
select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from Porfolio..CovidDeaths
where continent is not null
--where location like '%india%'
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
select sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from Porfolio..CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2


--total population vs total vaccination
--USE CTE
with PopvsVac (continent, Location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Porfolio..CovidDeaths dea 
join Porfolio..CovidVaccinations vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)


select* , (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from Porfolio..CovidDeaths dea 
join Porfolio..CovidVaccinations vac
on dea.location=vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

select*, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



 --CREATING VIEW TO STORE DATA FOR VISUALIZATION
drop view if exists PercentPeopleVaccinated
CREATE VIEW PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from Porfolio..CovidDeaths dea 
join Porfolio..CovidVaccinations vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select*
from PercentPeopleVaccinated
