select * from monarchs

--Inner Join using On
Select prime_ministers.country, prime_ministers.continent, prime_minister , president
from presidents
Inner join prime_ministers
on presidents.country = prime_ministers.country