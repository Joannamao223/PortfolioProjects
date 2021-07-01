select * from `Prortfolio Project`.Coviddeaths order by 3,4
select * from `Prortfolio Project`.CovidVaccinations order by 3,4

#select data that we are going be using

select location, date, total_cases, new_cases, total_deaths, population 
from `Prortfolio Project`.Coviddeaths where continent is not null order by 1,2

#Looking at Total Cases vs Total deaths 
#showing likelihood of dying if you contract COVID in your country

select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage 
from `Prortfolio Project`.Coviddeaths 
where location like '%states%' 
order by 1,2

#Looking at Total cases vs Population
#Showing what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as InfectionRate 
from `Prortfolio Project`.Coviddeaths 
where continent is not null 
order by 1,2

#Looking at countries with Highest Infection Rate Compared to Population


select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationInfectionRate 
from `Prortfolio Project`.Coviddeaths 
where continent is not null 
group by location, population 
order by PopulationInfectionRate desc

#Showing Countries with highest death count per population

select location, max(total_deaths) as TotalDeathCount
from `Prortfolio Project`.Coviddeaths 
where continent is not null
group by location
order by TotalDeathCount desc

#Let's breaking things down by continent
#Showing continents with the highest death count per population

select continent, max(total_deaths) as TotalDeathCount
from `Prortfolio Project`.Coviddeaths 
where continent is not null
group by continent
order by TotalDeathCount desc

#Global numbers

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,  sum(new_deaths)/sum(new_cases)*100 as DeathsPercentage 
from `Prortfolio Project`.Coviddeaths 
group by date
order by 1,2

#Looking at Total Population vs CovidVaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from `Prortfolio Project`.Coviddeaths dea
join `Prortfolio Project`.CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not NULL
order by 2,3

#use CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from `Prortfolio Project`.Coviddeaths dea
join `Prortfolio Project`.CovidVaccinations vac
      on dea.location=vac.location 
      and dea.date=vac.date
where dea.continent is not NULL
)
select *, (RollingPeopleVaccinated/population)*100 from PopvsVac


#Temp Table

create table PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into PercentPopulationVaccinated(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from `Prortfolio Project`.Coviddeaths dea
join `Prortfolio Project`.CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date)


#creating view to store data visualizations

create view PercentPopulationVaccinated1 as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from `Prortfolio Project`.Coviddeaths dea
join `Prortfolio Project`.CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null;

select *, (RollingPeopleVaccinated/population)*100 from `Prortfolio Project`.PercentPopulationVaccinated
