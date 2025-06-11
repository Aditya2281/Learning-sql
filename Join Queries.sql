select * from monarchs

--Inner Join using On
SELECT
	PRIME_MINISTERS.COUNTRY,
	PRIME_MINISTERS.CONTINENT,
	PRIME_MINISTER,
	PRESIDENT
FROM
	PRESIDENTS
	INNER JOIN PRIME_MINISTERS ON PRESIDENTS.COUNTRY = PRIME_MINISTERS.COUNTRY

--Inner Join using Aliased Tables 
Select p2.country , p2.continent, prime_minister, president 
from presidents as p1
INNER JOIN Prime_ministers as p2
on p1.country = p2.country
