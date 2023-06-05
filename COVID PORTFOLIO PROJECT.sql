select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths$
order by 1,2

--total cases vs total deaths

select Location, date, total_cases, total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths$
where location like '%states'
order by 1,2

--total cases vs population
select Location, date,Population, total_cases,(Total_cases/Population)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths$
where location like '%india%'
order by 1,2

-- Countries with Highest Infection Rate in comparison with population
select Location,Population, max(total_cases) as HighInfectionCount,max(Total_cases/Population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths$
group by Location,Population
order by PercentPopulationInfected desc

--Countried with highest Death Count per population
select Location ,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths$
group by Location,Population
order by TotalDeathCount desc

-- dividing by continents
-- continents with highest death counts
select  continent ,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths$
where continent is not null
order by 1,2

--total population vs vaccination
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated

from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--using CTE
with PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated

from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

)
select *,(RollingPeopleVaccinated/Population)*100 from PopvsVac

--temporary table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated

from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
select *,(RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated

--creating view  to store data

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated

from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject.dbo.CovidVaccinations$ vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated

