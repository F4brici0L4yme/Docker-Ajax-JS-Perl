CREATE DATABASE IF NOT EXISTS menagerie;
USE menagerie;

CREATE TABLE IF NOT EXISTS pets (
    name VARCHAR(20),
    owner VARCHAR(20),
    species VARCHAR(20),
    sex CHAR(1),
    birth DATE,
    death DATE
);

-- Verificar si la tabla está vacía antes de insertar
INSERT INTO pets (name, owner, species, sex, birth, death)
SELECT * FROM (
    SELECT 'Fluffy' AS name, 'Harold' AS owner, 'cat' AS species, 'f' AS sex, '1993-02-04' AS birth, NULL AS death UNION ALL
    SELECT 'Claws', 'Gwen', 'cat', 'm', '1994-03-17', NULL UNION ALL
    SELECT 'Buffy', 'Harold', 'dog', 'f', '1989-05-13', NULL UNION ALL
    SELECT 'Fang', 'Benny', 'dog', 'm', '1990-08-27', NULL UNION ALL
    SELECT 'Bowser', 'Diane', 'dog', 'm', '1979-08-31', '1995-07-29' UNION ALL
    SELECT 'Chirpy', 'Gwen', 'bird', 'f', '1998-09-11', NULL UNION ALL
    SELECT 'Whistler', 'Gwen', 'bird', NULL, '1997-12-09', NULL UNION ALL
    SELECT 'Slim', 'Benny', 'snake', 'm', '1996-04-29', NULL UNION ALL
    SELECT 'Puffball', 'Diane', 'hamster', 'f', '1999-03-30', NULL
) AS tmp
WHERE NOT EXISTS (SELECT 1 FROM pets);
