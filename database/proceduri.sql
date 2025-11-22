-- Procedură pentru adăugarea unui orar
DELIMITER $$
CREATE PROCEDURE AdaugaOrar (
    IN userRole ENUM('admin', 'hr'),
    IN angajatID INT,
    IN ziua ENUM('Luni', 'Marti', 'Miercuri', 'Joi', 'Vineri', 'Sambata', 'Duminica'),
    IN dataCalendaristica DATE,
    IN oraStart TIME,
    IN oraSfarsit TIME,
    IN locatie VARCHAR(100),
    IN tipOrar ENUM('generic', 'specific')
)
BEGIN
    -- Declarare variabile
    DECLARE isMedical INT;

    -- Verificare permisiuni utilizator
    IF userRole NOT IN ('admin', 'hr') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doar administratorii sau responsabilii HR pot adăuga orare!';
    END IF;

    -- Validare pentru orare specifice (doar pentru angajați medicali)
    IF tipOrar = 'specific' THEN
        SELECT COUNT(*) INTO isMedical
        FROM Angajati
        WHERE ID = angajatID AND Specialitate IS NOT NULL;

        IF isMedical = 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Orarul specific poate fi adăugat doar pentru angajați medicali!';
        END IF;
    END IF;

    -- Inserare în tabel
    INSERT INTO OrarLucru (AngajatID, Ziua, DataCalendaristica, OraStart, OraSfarsit, Locatie, TipOrar)
    VALUES (angajatID, ziua, dataCalendaristica, oraStart, oraSfarsit, locatie, tipOrar);
END $$
DELIMITER ;


-- Procedură pentru vizualizarea orarului săptămânal al tuturor medicilor
DELIMITER $$
CREATE PROCEDURE VizualizeazaOrarSaptamanal ()
BEGIN
    SELECT 
        U.Nume,
        U.Prenume,
        O.Ziua,
        O.OraStart,
        O.OraSfarsit,
        O.Locatie
    FROM OrarLucru O
    JOIN Angajati A ON O.AngajatID = A.ID
    JOIN Utilizatori U ON A.UtilizatorID = U.ID
    WHERE U.Rol IN ('admin', 'hr', 'financiar') -- Restricționare la roluri specifice
    ORDER BY O.Ziua, O.OraStart;
END $$
DELIMITER ;

-- Procedură pentru căutarea angajaților după nume, prenume sau funcție
DELIMITER $$
CREATE PROCEDURE CautaAngajati (
    IN userRole ENUM('admin', 'hr', 'financiar'),
    IN parametru VARCHAR(50)
)
BEGIN
    -- Verificare permisiuni utilizator
    IF userRole NOT IN ('admin', 'hr', 'financiar') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doar administratorii, responsabilii HR sau experții financiari pot căuta angajați!';
    END IF;

    SELECT 
        U.Nume,
        U.Prenume,
        U.Functie,
        A.Salariu
    FROM Utilizatori U
    JOIN Angajati A ON U.ID = A.UtilizatorID
    WHERE U.Nume LIKE CONCAT('%', parametru, '%')
       OR U.Prenume LIKE CONCAT('%', parametru, '%')
       OR U.Functie LIKE CONCAT('%', parametru, '%');
END $$
DELIMITER ;
-- Procedură pentru vizualizarea serviciilor medicale și prețurile lor
DELIMITER $$
CREATE PROCEDURE VizualizeazaServicii ()
BEGIN
    SELECT 
        Nume,
        Pret
    FROM ServiciiMedicale;
END $$
DELIMITER ;

-- Procedură pentru verificarea orelor disponibile ale unui medic

DELIMITER $$
CREATE PROCEDURE VerificaOreDisponibile (
    IN userRole ENUM('receptionist', 'admin'),
    IN medicID INT, 
    IN dataConsulta DATE
)
BEGIN
    IF userRole != 'receptionist' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doar recepționerii pot verifica orele disponibile!';
    END IF;

    SELECT DISTINCT 
        OraStart, 
        OraSfarsit
    FROM OrarLucru
    WHERE AngajatID = medicID
      AND (DataCalendaristica = dataConsulta OR DataCalendaristica IS NULL)
      AND OraStart IS NOT NULL
      AND OraSfarsit IS NOT NULL
    ORDER BY OraStart;
END $$
DELIMITER ;



-- Procedură pentru vizualizarea programărilor unui pacient
DELIMITER $$
CREATE PROCEDURE VizualizeazaProgramariPacient (
    IN pacientID INT
)
BEGIN
    SELECT 
        P.DataOra AS DataOra,
        S.Nume AS Serviciu,
        CONCAT(U.Nume, ' ', U.Prenume) AS Medic
    FROM Programari P
    JOIN ServiciiMedicale S ON P.ServiciuID = S.ID
    JOIN Angajati A ON P.MedicID = A.ID
    JOIN Utilizatori U ON A.UtilizatorID = U.ID
    WHERE P.PacientID = pacientID;
END $$
DELIMITER ;


-- Procedură pentru vizualizarea pacienților programați într-o zi
DELIMITER $$
CREATE PROCEDURE VizualizeazaPacientiProgramati(IN medicID INT)
BEGIN
    SELECT 
        p.Nume, 
        p.Prenume, 
        pr.DataOra AS DataProgramare
    FROM Programari pr
    JOIN Pacienti p ON pr.PacientID = p.ID
    WHERE pr.MedicID = medicID
    ORDER BY pr.DataOra;
END $$
DELIMITER ;


-- Procedură pentru calcularea profitului lunar
DELIMITER $$
CREATE PROCEDURE CalculeazaProfitLunar (
    IN luna DATE
)
BEGIN
    DECLARE venituriTotal DECIMAL(10, 2);
    DECLARE cheltuieliTotal DECIMAL(10, 2);

    SELECT SUM(Suma) INTO venituriTotal 
    FROM Venituri 
    WHERE MONTH(DataVenit) = MONTH(luna) AND YEAR(DataVenit) = YEAR(luna);

    SELECT SUM(Suma) INTO cheltuieliTotal 
    FROM Cheltuieli 
    WHERE MONTH(DataCheltuiala) = MONTH(luna) AND YEAR(DataCheltuiala) = YEAR(luna);

    -- Inserare/actualizare profit
    INSERT INTO Profituri (Luna, VenituriTotal, CheltuieliTotal, Profit)
    VALUES (luna, venituriTotal, cheltuieliTotal, venituriTotal - cheltuieliTotal)
    ON DUPLICATE KEY UPDATE 
        VenituriTotal = VALUES(VenituriTotal),
        CheltuieliTotal = VALUES(CheltuieliTotal),
        Profit = VALUES(Profit);

    -- Returnează doar profitul calculat
    SELECT 
        Luna, 
        VenituriTotal, 
        CheltuieliTotal, 
        Profit 
    FROM Profituri 
    WHERE Luna = luna;
END $$
DELIMITER ;


-- Adaugare raport medical
DELIMITER $$
CREATE PROCEDURE AdaugaRaportMedical (
    IN userRole ENUM('medic', 'asistent'),
    IN pacientID INT,
    IN medicID INT,
    IN asistentID INT,
    IN dataConsultatie DATE,
    IN istoric TEXT,
    IN simptome TEXT,
    IN investigatii TEXT,
    IN diagnostic TEXT,
    IN recomandari TEXT
)
BEGIN
    -- Verifică dacă utilizatorul are permisiunea de a adăuga rapoarte medicale
    IF userRole NOT IN ('medic', 'asistent') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doar medicii sau asistenții pot adăuga rapoarte medicale!';
    END IF;

    -- Adaugă raportul medical în baza de date
    INSERT INTO RapoarteMedicale (PacientID, MedicID, AsistentID, DataConsultatie, Istoric, Simptome, Investigatii, Diagnostic, Recomandari)
    VALUES (pacientID, medicID, asistentID, dataConsultatie, istoric, simptome, investigatii, diagnostic, recomandari);
END $$
DELIMITER ;

-- Vizualizare istoric pacient
DELIMITER $$
CREATE PROCEDURE VizualizeazaIstoricPacient (
    IN pacientID INT
)
BEGIN
    SELECT 
        R.DataConsultatie,
        R.Istoric,
        R.Simptome,
        R.Investigatii,
        R.Diagnostic,
        R.Recomandari,
        U.Nume AS Medic,
        UA.Nume AS Asistent
    FROM RapoarteMedicale R
    JOIN Angajati AM ON R.MedicID = AM.ID
    JOIN Utilizatori U ON AM.UtilizatorID = U.ID
    LEFT JOIN Angajati AA ON R.AsistentID = AA.ID
    LEFT JOIN Utilizatori UA ON AA.UtilizatorID = UA.ID
    WHERE R.PacientID = pacientID;
END $$
DELIMITER ;

-- Adaugare bon fiscal
DELIMITER $$
CREATE PROCEDURE AdaugaBonFiscal (
    IN userRole ENUM('receptionist', 'admin'),
    IN programareID INT,
    IN sumaTotal DECIMAL(10, 2),
    IN tva DECIMAL(10, 2)
)
BEGIN
    -- Verifică dacă utilizatorul are permisiunea de a emite bonuri fiscale
    IF userRole != 'receptionist' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doar recepționerii pot emite bonuri fiscale!';
    END IF;

    -- Adaugă bonul fiscal în baza de date
    INSERT INTO BonuriFiscale (ProgramareID, SumaTotal, TVA)
    VALUES (programareID, sumaTotal, tva);
END $$
DELIMITER ;

-- Adugare utilizator
DELIMITER $$
CREATE PROCEDURE AdaugaUtilizator (
    IN userRole ENUM('super-admin', 'admin'),
    IN nume VARCHAR(50),
    IN prenume VARCHAR(50),
    IN cnp VARCHAR(13),
    IN adresa TEXT,
    IN telefon VARCHAR(15),
    IN email VARCHAR(100),
    IN contIBAN VARCHAR(34),
    IN numarContract VARCHAR(20),
    IN dataAngajare DATE,
    IN functie VARCHAR(50),
    IN parola VARCHAR(255),
    IN rol ENUM('super-admin', 'admin', 'medic', 'asistent', 'receptionist')
)
BEGIN
    -- Verifică permisiunea utilizatorului curent
    IF userRole = 'admin' AND rol IN ('super-admin', 'admin') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doar super-administratorii pot adăuga utilizatori de tip admin sau super-admin!';
    END IF;

    INSERT INTO Utilizatori (Nume, Prenume, CNP, Adresa, Telefon, Email, ContIBAN, NumarContract, DataAngajare, Functie, Parola, Rol)
    VALUES (nume, prenume, cnp, adresa, telefon, email, contIBAN, numarContract, dataAngajare, functie, parola, rol);
END $$
DELIMITER ;

DELIMITER $$

CREATE PROCEDURE StergeUtilizator (
    IN userRole ENUM('super-admin', 'admin'),
    IN utilizatorID INT
)
BEGIN
    DECLARE targetRole ENUM('super-admin', 'admin', 'medic', 'asistent', 'receptionist');
    DECLARE depCount INT DEFAULT 0;

    -- Verificăm rolul utilizatorului curent și al utilizatorului țintă
    SELECT Rol INTO targetRole FROM Utilizatori WHERE ID = utilizatorID;

    IF userRole = 'admin' AND targetRole IN ('super-admin', 'admin') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doar super-administratorii pot șterge utilizatori de tip admin sau super-admin!';
    END IF;

    -- Verificăm dacă utilizatorul există
    SELECT COUNT(*) INTO depCount FROM Utilizatori WHERE ID = utilizatorID;
    IF depCount = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Utilizatorul nu există!';
    END IF;

    -- Ștergem dependențele în ordine corectă
    DELETE FROM Angajati WHERE UtilizatorID = utilizatorID;
    DELETE FROM BonuriFiscale WHERE ReceptionerID = utilizatorID; -- Dacă există relația
    -- Adaugă alte ștergeri pentru tabele dependente, dacă e cazul

    -- Ștergem utilizatorul
    DELETE FROM Utilizatori WHERE ID = utilizatorID;
END $$

DELIMITER ;


DELIMITER $$
CREATE PROCEDURE ModificaUtilizator (
    IN userRole ENUM('super-admin', 'admin'),
    IN utilizatorID INT,
    IN nume VARCHAR(50),
    IN prenume VARCHAR(50),
    IN cnp VARCHAR(13),
    IN adresa TEXT,
    IN telefon VARCHAR(15),
    IN email VARCHAR(100),
    IN contIBAN VARCHAR(34),
    IN numarContract VARCHAR(20),
    IN dataAngajare DATE,
    IN functie VARCHAR(50),
    IN parola VARCHAR(255),
    IN rol ENUM('super-admin', 'admin', 'medic', 'asistent', 'receptionist')
)
BEGIN
    DECLARE targetRole ENUM('super-admin', 'admin', 'medic', 'asistent', 'receptionist');
    DECLARE cnt INT;

    SELECT Rol INTO targetRole FROM Utilizatori WHERE ID = utilizatorID;

    IF userRole = 'admin' AND targetRole IN ('super-admin', 'admin') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doar super-administratorii pot modifica utilizatori de tip admin sau super-admin!';
    END IF;

    SELECT COUNT(*) INTO cnt
    FROM Utilizatori
    WHERE Email = email AND ID != utilizatorID;

    IF cnt > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email-ul există deja!';
    END IF;

    UPDATE Utilizatori
    SET Nume = nume,
        Prenume = prenume,
        CNP = cnp,
        Adresa = adresa,
        Telefon = telefon,
        Email = email,
        ContIBAN = contIBAN,
        NumarContract = numarContract,
        DataAngajare = dataAngajare,
        Functie = functie,
        Parola = parola,
        Rol = rol
    WHERE ID = utilizatorID;
END $$
DELIMITER ;

-- Calculare salariu (zilele de concediu)
DELIMITER $$

CREATE PROCEDURE CalculeazaSalariuConcedii (
    IN angajatID INT,
    IN luna DATE
)
BEGIN
    DECLARE oreContract INT DEFAULT 0;
    DECLARE oreLucrate INT DEFAULT 0;
    DECLARE salariuCalculat DECIMAL(10, 2) DEFAULT 0;

    -- Obținem numărul de ore specificat în contractul de muncă pentru angajat
    SELECT NumarOreContract INTO oreContract
    FROM Angajati
    WHERE ID = angajatID;

    -- Calculăm numărul de ore lucrate efectiv, excluzând zilele de concediu
    SELECT COALESCE(SUM(TIMESTAMPDIFF(HOUR, OraStart, OraSfarsit)), 0) INTO oreLucrate
    FROM OrarLucru
    WHERE AngajatID = angajatID
      AND MONTH(DataCalendaristica) = MONTH(luna)
      AND YEAR(DataCalendaristica) = YEAR(luna)
      AND NOT EXISTS (
          SELECT 1 
          FROM Concedii 
          WHERE AngajatID = angajatID
            AND DataCalendaristica BETWEEN DataStart AND DataSfarsit
      );

    -- Calculăm salariul pe baza orelor lucrate
    SET salariuCalculat = COALESCE((oreLucrate * (SELECT Salariu FROM Angajati WHERE ID = angajatID)) / oreContract, 0);

    -- Returnăm rezultatele
    SELECT oreContract AS OreContract,
           oreLucrate AS OreLucrate,
           salariuCalculat AS SalariuCalculat;
END $$

DELIMITER ;

-- Calculare salariu negociat medic
DELIMITER $$

CREATE PROCEDURE CalculeazaSalariuMedicCombinat (
    IN medicID INT,
    IN luna DATE
)
BEGIN
    DECLARE salariuNegociat DECIMAL(10, 2) DEFAULT 0;
    DECLARE venituriBonus DECIMAL(10, 2) DEFAULT 0;
    DECLARE salariuFinal DECIMAL(10, 2) DEFAULT 0;

    -- Verificăm dacă angajatul este medic
    IF (SELECT COUNT(*) FROM Angajati A JOIN Utilizatori U ON A.UtilizatorID = U.ID WHERE A.ID = medicID AND U.Rol = 'medic') = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Angajatul specificat nu este de tip medic!';
    END IF;

    -- Obținem salariul de bază al medicului
    SELECT Salariu INTO salariuNegociat
    FROM Angajati
    WHERE ID = medicID;

    -- Calculăm veniturile din bonus pentru luna specificată
    SELECT COALESCE(SUM(Suma), 0) INTO venituriBonus
    FROM Venituri
    WHERE MedicID = medicID
      AND MONTH(DataVenit) = MONTH(luna)
      AND YEAR(DataVenit) = YEAR(luna);

    -- Calculăm salariul final
    SET salariuFinal = salariuNegociat + venituriBonus;

    -- Returnăm rezultatele
    SELECT salariuNegociat AS SalariuNegociat,
           venituriBonus AS VenituriBonus,
           salariuFinal AS SalariuFinal;
END $$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE AdaugaProgramare(
    IN userRole ENUM('receptionist'),
    IN pacientID INT,
    IN medicID INT,
    IN dataOra DATETIME,
    IN serviciuID INT,
    IN durata INT
)
BEGIN
    -- Verificăm dacă utilizatorul are rolul de "receptionist"
    IF userRole != 'receptionist' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Doar recepționerii pot adăuga programări!';
    END IF;

    -- Adăugăm programarea în baza de date
    INSERT INTO Programari (PacientID, MedicID, DataOra, ServiciuID, Durata)
    VALUES (pacientID, medicID, dataOra, serviciuID, durata);
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE RepartizeazaMedici (
    IN medicID INT,
    IN cabinetID INT,
    IN dataStart DATE,
    IN dataSfarsit DATE
)
BEGIN
    -- Verificăm dacă medicul este deja repartizat în aceeași perioadă
    IF EXISTS (
        SELECT 1
        FROM OrarLucru
        WHERE AngajatID = medicID
          AND Locatie = (SELECT LocatieID FROM Cabinete WHERE ID = cabinetID)
          AND ((DataCalendaristica BETWEEN dataStart AND dataSfarsit)
               OR (DataCalendaristica IS NULL))
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Medicul este deja repartizat în această perioadă!';
    END IF;

    -- Inserăm repartizarea în tabelul `OrarLucru`
    INSERT INTO OrarLucru (AngajatID, DataCalendaristica, OraStart, OraSfarsit, Locatie, TipOrar)
    SELECT medicID, dataStart, '08:00:00', '16:00:00', LocatieID, 'specific'
    FROM Cabinete
    WHERE ID = cabinetID;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE PersonalizeazaServicii (
    IN medicID INT,
    IN serviciuID INT,
    IN pretPersonalizat DECIMAL(10, 2),
    IN durataPersonalizata INT
)
BEGIN
    -- Inserăm sau actualizăm serviciul medical personalizat
    INSERT INTO ServiciiPersonalizate (MedicID, ServiciuID, PretPersonalizat, DurataPersonalizata)
    VALUES (medicID, serviciuID, pretPersonalizat, durataPersonalizata)
    ON DUPLICATE KEY UPDATE
        PretPersonalizat = VALUES(PretPersonalizat),
        DurataPersonalizata = VALUES(DurataPersonalizata);
END $$

DELIMITER ;
