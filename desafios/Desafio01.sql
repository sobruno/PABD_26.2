-- 1. Resumo por piloto/temporada
DROP MATERIALIZED VIEW IF EXISTS mv_driver_season_summary;
CREATE MATERIALIZED VIEW mv_driver_season_summary AS
SELECT
    r.year AS ano,
    d.name AS piloto,
    COUNT(*) AS total_corridas,
    COUNT(CASE WHEN rd.position_number = 1 THEN 1 END) AS total_vitorias,
    COUNT(CASE WHEN rd.position_number <= 3 THEN 1 END) AS total_podios,
    COUNT(CASE WHEN rd.race_reason_retired IS NOT NULL THEN 1 END) AS total_abandonos,
    COALESCE(SUM(rd.race_points), 0)::DECIMAL(10,2) AS total_pontos
FROM race_data rd
JOIN race r
  ON r.id = rd.race_id
JOIN driver d
  ON d.id = rd.driver_id
WHERE rd.type = 'RACE_RESULT'
GROUP BY r.year, d.name;

DROP INDEX  IF EXISTS mv_driver_season_summary_idx;
CREATE UNIQUE INDEX mv_driver_season_summary_idx
    ON mv_driver_season_summary (ano, piloto);

REFRESH MATERIALIZED VIEW CONCURRENTLY mv_driver_season_summary;

-- Teste: últimas 10 temporadas de Ayrton Senna
SELECT *
FROM mv_driver_season_summary
WHERE piloto = 'Ayrton Senna'
ORDER BY ano DESC
LIMIT 10;


-----------------------------------------------------------------------------------------------------------------------------
-- 2. Auditoria de pontos do campeonato
DROP TABLE IF EXISTS points_adjustment_audit;
CREATE TABLE points_adjustment_audit (
    id         SERIAL PRIMARY KEY,
    year       INT NOT NULL,
    driver_id  VARCHAR(100) NOT NULL,
    old_points DECIMAL(8,2),
    new_points DECIMAL(8,2),
    changed_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION adjustment_audit()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS $$
    BEGIN
        IF NEW.points IS DISTINCT FROM OLD.points THEN
            INSERT INTO points_adjustment_audit (year, driver_id, old_points, new_points)
            VALUES (NEW.year, NEW.driver_id, OLD.points, NEW.points);
        END IF;

    RETURN NEW;
    END;
$$;

CREATE TRIGGER trg_adjustment_audit
BEFORE UPDATE ON season_driver_standing
FOR EACH ROW
EXECUTE FUNCTION adjustment_audit();

-- Teste: incrementar pontos da temporada 1993 de Ayrton Senna em 100
UPDATE season_driver_standing
SET points = points + 100
WHERE year = 1993
  AND driver_id = (
      SELECT id
      FROM driver
      WHERE LOWER(full_name) = 'ayrton senna'
         OR LOWER(name) = 'ayrton senna'
      LIMIT 1
  );

SELECT *
FROM points_adjustment_audit
ORDER BY changed_at DESC
LIMIT 10;


-----------------------------------------------------------------------------------------------------------------------------
-- 3. Impedir exclusão de piloto com histórico

CREATE OR REPLACE FUNCTION no_reg_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM race_data rd
        WHERE rd.driver_id = OLD.id
    ) THEN
        RAISE EXCEPTION 'Não foi possível excluir o piloto % porque existem registros na tabela race_data.', OLD.name;
    END IF;

    RETURN OLD;
END;
$$;

CREATE TRIGGER trg_no_reg_delete
BEFORE DELETE ON driver
FOR EACH ROW
EXECUTE FUNCTION no_reg_delete();

-- Teste 1: bloquear exclusão de Ayrton Senna
DELETE FROM driver
WHERE LOWER(name) = 'ayrton senna'
   OR LOWER(full_name) = 'ayrton senna';

-- Teste 2: excluir um piloto sem histórico em race_data
DELETE FROM driver
WHERE id = (
    SELECT d.id
    FROM driver d
    LEFT JOIN race_data rd ON rd.driver_id = d.id
    WHERE rd.driver_id IS NULL
    LIMIT 1
);
