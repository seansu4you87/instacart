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
