--Find the total amount of cases in North America, and total people vaccinated

SELECT
	Deaths.continent,
	MAX(Deaths.population) AS total_population,
	MAX(Vaccines.people_fully_vaccinated) AS Vaccinated

FROM CovidDeaths AS Deaths
INNER JOIN CovidVaccines Vaccines
ON
Vaccines.country = Deaths.country
AND
Vaccines.date = Deaths.date
GROUP BY
	Deaths.continent


--Find the country with most covid cases in North America

SELECT
	country, 
	max(deaths.total_cases) AS total_cases
FROM
	CovidDeaths deaths
GROUP BY 
	country
Order by
	total_cases desc
	

--Find the country with the most individuals that are fully vaccinated

SELECT
	Vaccines.country,
	MAX(Vaccines.people_fully_vaccinated) AS total_vaccinated_individuals
FROM
	CovidVaccines Vaccines
GROUP BY
	Vaccines.country
Order by
	 total_vaccinated_individuals DESC



-- Compare the overall percentage of people that contracted covid and the overall percentage of people that died from covid

SELECT
	Deaths.country,
	Deaths.population,
	MAX(Deaths.total_cases) case_count,
	MAX(Deaths.total_deaths) death_per_country,
	(MAX(Deaths.total_cases)/Deaths.population)*100 AS infected_percentage, 
	(MAX(Deaths.total_deaths/ Deaths.population))*100 AS death_percentage,
	CASE
		WHEN MAX(Deaths.total_deaths) >= 1000000 THEN 'Death Range: 1,000,000+'
		WHEN MAX(Deaths.total_deaths) < 1000000 AND MAX(Deaths.total_deaths)>= 100000 THEN 'Death Range: 100,000 - 999,999+'
		ELSE 'Death Range: Less than 100,000 deaths'
	END AS death_range
FROM CovidDeaths AS Deaths
LEFT JOIN CovidVaccines Vaccines 
ON
Vaccines.country = Deaths.country
WHERE total_tests > 0
GROUP BY 
	Deaths.country,
	Deaths.population
ORDER BY 
	death_per_country DESC, infected_percentage desc



--Find the country with the highest and lowest fully vaccinated indviduals in North America

SELECT
	Deaths.country,
	MAX(Deaths.population) AS total_population,
	MAX(Vaccines.people_fully_vaccinated) AS Vaccinated,
	MAX(Vaccines.people_fully_vaccinated)/(MAX(Deaths.population))*100 AS Num_of_individuals_fully_vaccinated
FROM CovidDeaths AS Deaths
INNER JOIN CovidVaccines Vaccines
ON
Vaccines.country = Deaths.country
AND
Vaccines.date = Deaths.date
GROUP BY
	Deaths.country
ORDER BY 
	total_population DESC, Num_of_individuals_fully_vaccinated desc



--Find the increment/decrement in deaths and around the time deaths stopped occuring in the US.

WITH CovidDataCTE AS (
	SELECT
		Deaths.date,
		Deaths.country,
		SUM(Vaccines.new_vaccinations) OVER (Partition by deaths.country ORDER BY deaths.country, deaths.date) AS DailyIncreaseInVaccinations,
		Deaths.new_deaths,
		CASE
        WHEN LAG(Deaths.new_deaths) OVER (PARTITION BY deaths.country ORDER BY deaths.country) IS NULL THEN 0
        ELSE deaths.new_deaths - LAG(deaths.new_deaths) OVER (PARTITION BY deaths.country ORDER BY deaths.date)
    END AS DailyFluctuationInDeaths
	FROM CovidDeaths AS Deaths
	INNER JOIN CovidVaccines Vaccines
	ON
	Vaccines.country = Deaths.country
	AND
	Vaccines.date = Deaths.date
	WHERE Deaths.country = 'United States'
	GROUP BY
		Deaths.date,
		Deaths.country,
		Vaccines.new_vaccinations,
		Deaths.country,
		Deaths.new_deaths
)
SELECT
	date,
	country,
	DailyIncreaseInVaccinations,
	new_deaths,
	DailyFluctuationInDeaths 
FROM
	CovidDataCTE
GROUP BY
	date,country,DailyIncreaseInVaccinations,new_deaths,DailyFluctuationInDeaths 







	