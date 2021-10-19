SELECT * 
FROM PortofolioCovidProject .. CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortofolioCovidProject .. CovidVaccine
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortofolioCovidProject .. CovidDeaths
ORDER BY 1,2

-- Persentasi kematian jika terkena Covid-19 dari semua negara
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortofolioCovidProject .. CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Persentasi kematian jika terkena Covid-19 dari negara Indonesia
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortofolioCovidProject .. CovidDeaths
WHERE location like 'Indonesia'
ORDER BY 2

--Persentasi penduduk yang terkena Covid-19 dari semua negara
SELECT location,date,population,total_cases, (total_cases/population)*100 AS Infected_by_Covid19_Percentage
FROM PortofolioCovidProject .. CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Persentasi penduduk yang terkena Covid-19 dari negara Indonesia
SELECT location,date,population,total_cases, (total_cases/population)*100 AS InfectedPercentage
FROM PortofolioCovidProject .. CovidDeaths
WHERE location like 'Indonesia'
ORDER BY 2

--Perbandingan persentasi penduduk yang terinfeksi Covid-19 dari semua negara, diurutkan berdasarkan persentasi paling besar
SELECT location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) *100 
AS InfectedPopulationPercentage
FROM PortofolioCovidProject .. CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY InfectedPopulationPercentage desc

--Negara dengan angka kematian tertinggi
SELECT location, MAX(cast (total_deaths as int)) as HighestDeathCount
FROM PortofolioCovidProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount desc

--Benua dengan angka kematian tertinggi
SELECT continent, MAX(cast (total_deaths as int)) as HighestDeathCount
FROM PortofolioCovidProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc

--Benua dengan kasus Covid-19 tertinggi
SELECT continent,MAX(cast (total_cases as int)) as HighestInfectedCount
FROM PortofolioCovidProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestInfectedCount desc

--Persentasi kematian penduduk dunia setiap harinya karena Covid-19
SELECT date,SUM(new_cases) AS total_cases ,
SUM(cast(new_deaths as int)) AS total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS globalDeathPercentage
FROM PortofolioCovidProject .. CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1

--total Persentasi kematian penduduk dunia  karena Covid-19
SELECT SUM(new_cases) AS total_cases ,
SUM(cast(new_deaths as int)) AS total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS globalDeathPercentage
FROM PortofolioCovidProject .. CovidDeaths
WHERE continent is not null

-- Jumlah penduduk dari semua negara yang di vaksin per harinya
SELECT dth.continent,dth.location, dth.date,dth.population,vcc.new_vaccinations
FROM PortofolioCovidProject..CovidDeaths dth
JOIN PortofolioCovidProject..CovidVaccine vcc
ON dth.location =vcc.location
AND dth.date=vcc.date
WHERE dth.continent is not null
ORDER BY 1,2,3

-- Pertumbuhan angka penduduk yang divaksin dari semua negara
SELECT dth.continent,dth.location, dth.date,dth.population,vcc.new_vaccinations, 
SUM (CONVERT(int,vcc.new_vaccinations)) OVER (Partition by dth.location 
ORDER BY dth.location, dth.date ) AS GrowingNumberVaccinated
FROM PortofolioCovidProject..CovidDeaths dth
JOIN PortofolioCovidProject..CovidVaccine vcc
ON dth.location =vcc.location
AND dth.date=vcc.date
WHERE dth.continent is not null
ORDER BY 2,3

-- Persentasi pertumbuhan angka penduduk yang divaksin dari semua negara
WITH PopulVacc (Continent, Location, Date, Population, new_vaccinations,GrowingNumberVaccinated)
as(
SELECT dth.continent,dth.location, dth.date,dth.population,vcc.new_vaccinations, 
SUM (CONVERT(int,vcc.new_vaccinations)) OVER (Partition by dth.location 
ORDER BY dth.location, dth.date ) AS GrowingNumberVaccinated
FROM PortofolioCovidProject..CovidDeaths dth
JOIN PortofolioCovidProject..CovidVaccine vcc
ON dth.location =vcc.location
AND dth.date=vcc.date
WHERE dth.continent is not null
)
SELECT * ,( GrowingNumberVaccinated/ Population) *100 as GrowingVaccinatedPercentage
FROM PopulVacc
ORDER BY 2,3

Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
GrowingNumberVaccinated numeric
)

Insert into PercentPopulationVaccinated
SELECT dth.continent,dth.location, dth.date,dth.population,vcc.new_vaccinations, 
SUM (CONVERT(int,vcc.new_vaccinations)) OVER (Partition by dth.location 
ORDER BY dth.location, dth.date ) AS GrowingNumberVaccinated
FROM PortofolioCovidProject..CovidDeaths dth
JOIN PortofolioCovidProject..CovidVaccine vcc
ON dth.location =vcc.location
AND dth.date=vcc.date

Create View PercentPopulationVaccinated as
SELECT dth.continent,dth.location, dth.date,dth.population,vcc.new_vaccinations, 
SUM (CONVERT(int,vcc.new_vaccinations)) OVER (Partition by dth.location 
ORDER BY dth.location, dth.date ) AS GrowingNumberVaccinated
FROM PortofolioCovidProject..CovidDeaths dth
JOIN PortofolioCovidProject..CovidVaccine vcc
ON dth.location =vcc.location
AND dth.date=vcc.date
WHERE dth.continent is not null

SELECT*
FROM PercentPopulationVaccinated
