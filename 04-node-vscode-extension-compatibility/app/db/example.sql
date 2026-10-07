CREATE TABLE IF NOT EXISTS developers (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL
);

SELECT id, name
FROM developers
ORDER BY name;
