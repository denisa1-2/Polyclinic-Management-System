
-- View pentru raportul financiar lunar
CREATE VIEW RaportFinanciarLunar AS
SELECT 
    P.Luna,
    P.Locație,
    P.Specialitate,
    P.VenituriTotal,
    P.CheltuieliTotal,
    P.Profit
FROM Profituri P;

-- View pentru lista medicilor cu specialități și programul lor
CREATE VIEW ListaMediciSpecialitati AS
SELECT 
    U.Nume AS NumeMedic,
    U.Prenume AS PrenumeMedic,
    S.Nume AS Specialitate,
    O.Ziua,
    O.OraStart,
    O.OraSfarsit,
    O.Locatie
FROM Angajati A
JOIN Utilizatori U ON A.UtilizatorID = U.ID
JOIN Specialitati S ON A.Specialitate = S.Nume
JOIN OrarLucru O ON O.AngajatID = A.ID;

-- vedere profit specialiatti
CREATE VIEW ProfitSpecialitati AS
SELECT 
    S.Nume AS Specialitate,
    SUM(V.Suma) AS Venituri,
    SUM(C.Suma) AS Cheltuieli,
    (SUM(V.Suma) - SUM(C.Suma)) AS Profit
FROM Specialitati S
JOIN ServiciiMedicale SM ON S.ID = SM.ID
JOIN Venituri V ON SM.ID = V.ServiciuID
JOIN Cheltuieli C ON V.MedicID = C.AngajatID
GROUP BY S.Nume;

