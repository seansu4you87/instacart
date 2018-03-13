# Analysis Script
This contains blah blah blah

How to run:
```
```

# Notes
Ok, so doing the group by in SQL is way more performant than using the ORM:
```
~/Desktop/instacart/analysis master * >  ruby compute.rb "2014-07-01" "2015-09-21"
Fetching data between 2014-07-01 and 2015-09-21

via SQL
Took 1.849611 seconds

via ORM
Took 45.251969 seconds

via ORM plucked
Took 28.646828 seconds
```
I've confirmed that my ORM based results are correct with the output on
HackerRank, but for some reason, my SQL based results are bad.  Need to
work on fixing that.

UPDATE: ok fixed the problem

Query will look something like:
```
SELECT
  COUNT(*),
  STRFTIME('%W %Y', created_at, 'localtime', 'weekday 0', '-6 days') AS week,
  created_at,
  workflow_state
FROM applicants
WHERE
  created_at BETWEEN '2014-07-01' AND '2014-09-01'
GROUP BY workflow_state;
```

Count between a range
```
SELECT
  COUNT(*)
FROM applicants
WHERE
  created_at BETWEEN '2014-07-01' AND '2014-09-01';
```

Testing out given sample data
```
SELECT
  COUNT(*)
FROM applicants
WHERE
  created_at BETWEEN '2014-07-14' AND '2014-07-21' AND
  workflow_state is 'hired';
```

Some sample applicants between a range
```
SELECT
  id,
  created_at,
  workflow_state
FROM applicants
WHERE
  created_at BETWEEN '2014-07-01' AND '2014-09-01'
LIMIT 10;
```
