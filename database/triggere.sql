
-- Trigger pentru validarea programărilor fără suprapuneri

DROP TRIGGER IF EXISTS VerificaSuprapunereProgramari;

DELIMITER $$

CREATE TRIGGER VerificaSuprapunereProgramari
BEFORE INSERT ON Programari
FOR EACH ROW
BEGIN
    DECLARE overlap INT;

    SELECT COUNT(*) INTO overlap
    FROM Programari
    WHERE MedicID = NEW.MedicID
      AND (
          (NEW.DataOra >= DataOra AND NEW.DataOra < DATE_ADD(DataOra, INTERVAL Durata MINUTE)) OR
          (DATE_ADD(NEW.DataOra, INTERVAL NEW.Durata MINUTE) > DataOra AND 
           DATE_ADD(NEW.DataOra, INTERVAL NEW.Durata MINUTE) <= DATE_ADD(DataOra, INTERVAL Durata MINUTE)) OR
          (NEW.DataOra <= DataOra AND DATE_ADD(NEW.DataOra, INTERVAL NEW.Durata MINUTE) >= DATE_ADD(DataOra, INTERVAL Durata MINUTE))
      );

    IF overlap > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Programarea se suprapune cu o alta programare!';
    END IF;
END $$

DELIMITER ;




DROP TRIGGER IF EXISTS VerificaProgramLocatie;
DELIMITER $$
CREATE TRIGGER VerificareProgramLocatie
BEFORE INSERT ON OrarLucru
FOR EACH ROW
BEGIN
    DECLARE program_start TIME ;
    DECLARE program_end TIME;

    -- Obține programul locației
    SELECT SUBSTRING_INDEX(ProgramFunctionare, ':', 1),
           SUBSTRING_INDEX(ProgramFunctionare, ':', -1)
    INTO program_start, program_end
    FROM Locatii
    WHERE Nume = NEW.Locatie;

    -- Verifică dacă ora este compatibilă
    IF NEW.OraStart < program_start OR NEW.OraSfarsit > program_end THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Orarul nu este compatibil cu programul locației!';
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER ValideazaCompetente
BEFORE INSERT ON Programari
FOR EACH ROW
BEGIN
    DECLARE valid INT;
    SELECT COUNT(*) INTO valid
    FROM CompetenteMedici
    WHERE MedicID = NEW.MedicID
      AND Competenta = (SELECT Nume FROM ServiciiMedicale WHERE ID = NEW.ServiciuID);
    IF valid = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Medicul nu are competențele necesare!';
    END IF;
END $$ ;
DELIMITER ;
