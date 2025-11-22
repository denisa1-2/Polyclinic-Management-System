INSERT INTO Utilizatori (Nume, Prenume, CNP, Adresa, Telefon, Email, ContIBAN, NumarContract, DataAngajare, Functie, Parola, Rol) VALUES
('Popescu', 'Ion', '2900101123456', 'Str. Exemplu 12, București', '0721123456', 'ion.popescu@email.com', 'RO49AAAA1B31007593840000', '12345', '2010-06-01', 'medic', 'parola123', 'medic'),
('Ionescu', 'Maria', '2980102123457', 'Str. Luni 5, Cluj-Napoca', '0745123456', 'maria.ionescu@email.com', 'RO49AAAA1B31007593840001', '12346', '2015-03-15', 'asistent', 'parola456', 'asistent'),
('Georgescu', 'Alexandru', '2900103123458', 'Str. Miercuri 8, Timișoara', '0734123456', 'alex.georgescu@email.com', 'RO49AAAA1B31007593840002', '12347', '2018-08-22', 'receptionist', 'parola789', 'receptionist'),
('Dumitru', 'Ioana', '2950102123459', 'Str. Vineri 10, Brașov', '0725123456', 'ioana.dumitru@email.com', 'RO49AAAA1B31007593840003', '12348', '2016-12-11', 'medic', 'parola101', 'medic'),
('Matei', 'Florin', '2970105123450', 'Str. Luni 3, Iași', '0756123456', 'florin.matei@email.com', 'RO49AAAA1B31007593840004', '12349', '2012-07-19', 'admin', 'parola202', 'admin');

UPDATE Utilizatori 
SET Rol='super-admin'
WHERE CNP='2970105123450';

INSERT INTO Utilizatori (Nume, Prenume, CNP, Adresa, Telefon, Email, ContIBAN, NumarContract, DataAngajare, Functie, Parola, Rol) VALUES
('Radu','Zinveli','2900101093456','Str. Oasului 3, Cluj-Napoca','072817902','radu.zinveli@email.com','RO49AAAA1B31007593840000','12353','2019-01-12','super-admin','parola212','receptionist');

INSERT INTO Utilizatori (Nume, Prenume, CNP, Adresa, Telefon, Email, ContIBAN, NumarContract, DataAngajare, Functie, Parola, Rol) VALUES
('Gheorghe','Mihai','1970105173450','Str. 1 Mai, Hunedoara','0762890874','gheorghe.mihai@email.com','RO49AAAA1B31000493840003','12998','2018-07-09','financiar','parola432','financiar'),
('Popa','Mihaela','2980782123457','Str. Marului 3, Timisoara','0799076321','popa.mihaela@email.com','RO49AAAA1B31007083840003','10092','2011-08-11','hr','parola998','hr');

UPDATE Utilizatori
SET Rol = 'super-admin', Functie='receptionist'
WHERE CNP = '2900101093456';

UPDATE Utilizatori
SET Functie='super-admin'
WHERE CNP = '2900101093456';

INSERT INTO Angajati (UtilizatorID, Specialitate, Grad, CodParafa, ProcentVenituri, TipAsistent, GradAsistent, Salariu,NumarOreContract) VALUES
(1, 'Cardiologie', 'specialist', 'AB12345', 70.50, NULL, NULL, 8000.00,40),
(2, 'Radiologie', NULL, 'XY67890', 50.00, 'radiologie', 'secundar', 4000.00,35),
(3, 'Pediatrie', NULL, 'AB23456', 65.25, 'generalist', 'principal', 5000.00,60),
(4, 'Chirurgie', 'primar', 'XY98765', 80.75, NULL, NULL, 9000.00,40),
(5, 'Medicina de familie', NULL, 'XY11223', 55.00, 'laborator', 'secundar', 3500.00,55);

UPDATE Angajati
SET NumarOreContract='160'
WHERE UtilizatorId='1';

UPDATE Angajati
SET NumarOreContract='120'
WHERE UtilizatorId='2';

UPDATE Angajati
SET NumarOreContract='100'
WHERE UtilizatorId='3';

UPDATE Angajati
SET NumarOreContract='160'
WHERE UtilizatorId='4';

UPDATE Angajati
SET NumarOreContract='160'
WHERE UtilizatorId='5';

INSERT INTO Locatii (Nume, Adresa, Descriere, ProgramFunctionare) VALUES
('Spitalul Universitar București', 'Str. Luni 12, București', 'Spital universitar', '08:00-16:00');


INSERT INTO Pacienti (Nume, Prenume, DataNastere, CNP, Telefon) VALUES
('Popa', 'Larisa', '1985-05-21', '2900215123456', '0755123456'),
('Neagu', 'Elena', '1990-11-13', '2980212123457', '0742123456'),
('Stan', 'Gabriel', '1982-08-30', '2900318123457', '0737123456'),
('Cristea', 'Andrei', '1975-03-09', '2990214123457', '0722123456'),
('Iancu', 'Mihai', '1992-07-17', '2970215123457', '0738123456');

INSERT INTO ServiciiMedicale (Nume, Pret, Durata) VALUES
('Ecografie', 150.00, 30),
('Endoscopie digestivă', 300.00, 45),
('Ecocardiografie', 200.00, 40),
('Cardiologie intervențională', 500.00, 60),
('Bronhoscopie', 350.00, 50);

INSERT INTO OrarLucru (AngajatID, DataCalendaristica, OraStart, OraSfarsit)
VALUES 
    (2, '2025-01-03', '09:00:00', '12:00:00'),
    (2, '2025-01-04', '09:00:00', '12:00:00'),
    (2, '2025-01-05', '09:00:00', '11:00:00');

INSERT INTO OrarLucru (AngajatID, DataCalendaristica, OraStart, OraSfarsit)
VALUES 
    (1, '2025-01-03', '08:00:00', '16:00:00'),
    (1, '2025-01-04', '09:00:00', '17:00:00'),
    (1, '2025-01-05', '09:00:00', '11:00:00');

INSERT INTO OrarLucru (AngajatID, DataCalendaristica, OraStart, OraSfarsit)
VALUES 
    (3, '2025-01-04', '09:00:00', '14:00:00'),
    (3, '2025-01-10', '09:00:00', '18:00:00'),
    (3, '2025-01-05', '09:00:00', '13:00:00');
    
INSERT INTO Programari (PacientID, MedicID, DataOra, ServiciuID, Durata) VALUES
(1, 1, '2025-01-15 09:00:00', 1, 30),
(2, 4, '2025-01-15 10:00:00', 2, 45),
(3, 1, '2025-01-15 11:00:00', 3, 40),
(4, 2, '2025-01-15 12:00:00', 4, 60),
(5, 3, '2025-01-15 13:00:00', 5, 50);

INSERT INTO RapoarteMedicale (PacientID, MedicID, AsistentID, DataConsultatie, Istoric, Simptome, Investigatii, Diagnostic, Recomandari, Validat) VALUES
(1, 1, NULL, '2025-01-14', 'Istoric medical curent', 'Durere toracică', 'Ecografie', 'Cardiopatie ischemică', 'Tratament medicamentos', TRUE),
(2, 4, 2, '2025-01-14', 'Probleme digestive recente', 'Dureri abdominale', 'Endoscopie', 'Gastrită acută', 'Medicamente antiinflamatoare', FALSE),
(3, 1, NULL, '2025-01-14', 'Probleme cu respirația', 'Tuse persistentă', 'Ecocardiografie', 'Asma bronșică', 'Inhalatoare', TRUE),
(4, 2, 3, '2025-01-14', 'Istoric de hipertensiune', 'Durere în piept', 'Cardiologie intervențională', 'Insuficiență cardiacă', 'Intervenție chirurgicală', FALSE),
(5, 3, NULL, '2025-01-14', 'Istoric de diabet', 'Durere în gât', 'Bronhoscopie', 'Faringită cronică', 'Tratament simptomatic', TRUE);

INSERT INTO BonuriFiscale (ProgramareID, SumaTotal, TVA) VALUES
(1, 150.00, 19.00),
(2, 300.00, 19.00),
(3, 200.00, 19.00),
(4, 500.00, 19.00),
(5, 350.00, 19.00);

INSERT INTO Venituri (DataVenit, Suma, ServiciuID, MedicID, Locație) VALUES
('2025-01-01', 1500.00, 1, 1, 'București'),
('2025-01-02', 3000.00, 2, 4, 'Cluj-Napoca'),
('2025-01-03', 2500.00, 3, 1, 'Timișoara'),
('2025-01-04', 4000.00, 4, 2, 'Brașov'),
('2025-01-05', 3500.00, 5, 3, 'Iași');

INSERT INTO Cheltuieli (DataCheltuiala, AngajatID, Suma, Descriere) VALUES
('2025-01-01', 1, 500.00, 'Achiziție echipamente medicale'),
('2025-01-02', 2, 300.00, 'Costuri laboratoare de analize'),
('2025-01-03', 3, 200.00, 'Achiziție consumabile medicale'),
('2025-01-04', 4, 100.00, 'Salarii personal administrativ'),
('2025-01-05', 5, 150.00, 'Reparații echipamente');

INSERT INTO Profituri (Locație, Specialitate, Luna, VenituriTotal, CheltuieliTotal, Profit) VALUES
('București', 'Cardiologie', '2025-01-01', 1500.00, 500.00, 1000.00),
('Cluj-Napoca', 'Radiologie', '2025-01-01', 3000.00, 300.00, 2700.00),
('Timișoara', 'Pediatrie', '2025-01-01', 2500.00, 200.00, 2300.00),
('Brașov', 'Chirurgie', '2025-01-01', 4000.00, 100.00, 3900.00),
('Iași', 'Medicina de familie', '2025-01-01', 3500.00, 150.00, 3350.00);

INSERT INTO Locatii (Nume, Adresa, Descriere, ProgramFunctionare) VALUES
('Spitalul Universitar București', 'Str. Luni 12, București', 'Spital universitar de referință', 'Luni - Vineri: 08:00 - 20:00'),
('Spitalul Județean Cluj', 'Str. Vasile 8, Cluj-Napoca', 'Spital județean cu diverse specialități', 'Luni - Vineri: 08:00 - 18:00'),
('Spitalul Municipal Timișoara', 'Str. Mărțișor 5, Timișoara', 'Spital municipal de urgență', 'Luni - Vineri: 07:00 - 19:00'),
('Spitalul Brașov', 'Str. Octombrie 10, Brașov', 'Spital general cu servicii multiple', 'Luni - Vineri: 09:00 - 17:00'),
('Spitalul Iași', 'Str. Mai 3, Iași', 'Spital de urgență cu secții diverse', 'Luni - Vineri: 08:00 - 20:00');

INSERT INTO Specialitati (Nume) VALUES
('Cardiologie'),
('Radiologie'),
('Pediatrie'),
('Chirurgie'),
('Medicina de familie');

INSERT INTO CompetenteMedici (MedicID, Competenta) VALUES
(1, 'Cardiologie intervențională'),
(2, 'Radiologie imagistică'),
(3, 'Pediatrie generală'),
(4, 'Chirurgie toracică'),
(5, 'Medicina de familie');

INSERT INTO DoctorSpecialitati (MedicID, SpecialitateID, Grad) VALUES
(1, 1, 'specialist'),
(2, 2, 'primar'),
(3, 3, 'specialist'),
(4, 4, 'specialist'),
(5, 5, 'primar');

INSERT INTO ServiciiPersonalizate (MedicID, ServiciuID, PretPersonalizat, DurataPersonalizata) VALUES
(1, 1, 130.00, 30),
(2, 2, 290.00, 45),
(3, 3, 180.00, 40),
(4, 4, 450.00, 60),
(5, 5, 320.00, 50);

INSERT INTO Cabinete (LocatieID, NumeCabinet, TipEchipament) VALUES
(1, 'Cabinet Cardiologie', 'ECG, Ecocardiograf'),
(2, 'Cabinet Radiologie', 'Radiograf, Tomograf'),
(3, 'Cabinet Pediatrie', 'Stetoscop, Ecograf'),
(4, 'Cabinet Chirurgie', 'Laser, Instrumentar chirurgical'),
(5, 'Cabinet Medicina de familie', 'Electrocardiograf, Termometru digital');
