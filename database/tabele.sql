CREATE DATABASE IF NOT EXISTS Policlinica;
USE Policlinica;

-- Tabel pentru utilizatori
CREATE TABLE Utilizatori (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Nume VARCHAR(50),
    Prenume VARCHAR(50),
    CNP VARCHAR(13) UNIQUE,
    Adresa TEXT,
    Telefon VARCHAR(15),
    Email VARCHAR(100) UNIQUE,
    ContIBAN VARCHAR(34),
    NumarContract VARCHAR(20),
    DataAngajare DATE,
    Functie VARCHAR(50),
    Parola VARCHAR(255),
    Rol ENUM('admin', 'medic', 'asistent', 'receptionist') NOT NULL
);

-- Tabel pentru angajati
CREATE TABLE Angajati (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    UtilizatorID INT,
    Specialitate VARCHAR(100),
    Grad ENUM('specialist', 'primar', 'profesor') NULL,
    CodParafa VARCHAR(50) NULL,
    ProcentVenituri DECIMAL(5, 2) NULL,
    TipAsistent ENUM('generalist', 'laborator', 'radiologie') NULL,
    GradAsistent ENUM('secundar', 'principal') NULL,
    Salariu DECIMAL(10, 2),
    FOREIGN KEY (UtilizatorID) REFERENCES Utilizatori(ID)
);

-- Tabel pentru pacienti
CREATE TABLE Pacienti (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Nume VARCHAR(50),
    Prenume VARCHAR(50),
    DataNastere DATE,
    CNP VARCHAR(13) UNIQUE,
    Telefon VARCHAR(15)
);

-- Tabel pentru servicii medicale
CREATE TABLE ServiciiMedicale (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Nume VARCHAR(100),
    Pret DECIMAL(10, 2),
    Durata INT
);

-- Tabel pentru programari
CREATE TABLE Programari (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    PacientID INT,
    MedicID INT,
    DataOra DATETIME,
    ServiciuID INT,
    Durata INT,
    FOREIGN KEY (PacientID) REFERENCES Pacienti(ID),
    FOREIGN KEY (MedicID) REFERENCES Angajati(ID),
    FOREIGN KEY (ServiciuID) REFERENCES ServiciiMedicale(ID)
);

-- Tabel pentru rapoarte medicale
CREATE TABLE RapoarteMedicale (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    PacientID INT,
    MedicID INT,
    AsistentID INT NULL,
    DataConsultatie DATE,
    Istoric TEXT,
    Simptome TEXT,
    Investigatii TEXT,
    Diagnostic TEXT,
    Recomandari TEXT,
    Validat BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (PacientID) REFERENCES Pacienti(ID),
    FOREIGN KEY (MedicID) REFERENCES Angajati(ID),
    FOREIGN KEY (AsistentID) REFERENCES Angajati(ID)
);

-- Tabel pentru bonuri fiscale
CREATE TABLE BonuriFiscale (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ProgramareID INT,
    SumaTotal DECIMAL(10, 2),
    TVA DECIMAL(10, 2),
    DataEmitere TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProgramareID) REFERENCES Programari(ID)
);

-- Tabel pentru orar de lucru
CREATE TABLE OrarLucru (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    AngajatID INT,
    Ziua ENUM('Luni', 'Marti', 'Miercuri', 'Joi', 'Vineri', 'Sambata', 'Duminica') NOT NULL,
    DataCalendaristica DATE NULL,
    OraStart TIME,
    OraSfarsit TIME,
    Locatie VARCHAR(100),
    TipOrar ENUM('generic', 'specific') NOT NULL,
    FOREIGN KEY (AngajatID) REFERENCES Angajati(ID)
);

-- Tabel pentru concedii
CREATE TABLE Concedii (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    AngajatID INT,
    DataStart DATE,
    DataSfarsit DATE,
    Motiv TEXT,
    FOREIGN KEY (AngajatID) REFERENCES Angajati(ID)
);

-- Tabel pentru venituri
CREATE TABLE Venituri (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    DataVenit DATE,
    Suma DECIMAL(10, 2),
    ServiciuID INT,
    MedicID INT,
    Locație VARCHAR(100),
    FOREIGN KEY (ServiciuID) REFERENCES ServiciiMedicale(ID),
    FOREIGN KEY (MedicID) REFERENCES Angajati(ID)
);

-- Tabel pentru cheltuieli
CREATE TABLE Cheltuieli (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    DataCheltuiala DATE,
    AngajatID INT,
    Suma DECIMAL(10, 2),
    Descriere TEXT,
    FOREIGN KEY (AngajatID) REFERENCES Angajati(ID)
);

-- Tabel pentru profituri
CREATE TABLE Profituri (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Locație VARCHAR(100),
    Specialitate VARCHAR(100),
    Luna DATE,
    VenituriTotal DECIMAL(10, 2),
    CheltuieliTotal DECIMAL(10, 2),
    Profit DECIMAL(10, 2)
);

-- Tabel pentru locatii
CREATE TABLE Locatii (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Nume VARCHAR(100),
    Adresa TEXT,
    Descriere TEXT,
    ProgramFunctionare TEXT
);

-- Tabel pentru specialitati
CREATE TABLE Specialitati (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Nume VARCHAR(100)
);

-- Tabel pentru competentele medicilor
CREATE TABLE CompetenteMedici (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    MedicID INT,
    Competenta VARCHAR(100),
    FOREIGN KEY (MedicID) REFERENCES Angajati(ID)
);

SET FOREIGN_KEY_CHECKS=0;

ALTER TABLE Angajati
ADD CONSTRAINT CK_GradAsistent CHECK (TipAsistent IS NULL OR GradAsistent IS NOT NULL);

ALTER TABLE BonuriFiscale
ADD ReceptionerID INT,
ADD FOREIGN KEY (ReceptionerID) REFERENCES Utilizatori(ID);

ALTER TABLE Angajati
ADD NumarOreContract INT NOT NULL;

ALTER TABLE Angajati
ADD PostDidactic ENUM('preparator', 'asistent', 'lector', 'conferențiar', 'profesor') NULL;

ALTER TABLE Utilizatori MODIFY COLUMN Rol ENUM('super-admin', 'admin', 'medic', 'asistent', 'receptionist') NOT NULL;

CREATE TABLE DoctorSpecialitati (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    MedicID INT,
    SpecialitateID INT,
    Grad ENUM('specialist', 'primar', 'profesor'),
    FOREIGN KEY (MedicID) REFERENCES Angajati(ID),
    FOREIGN KEY (SpecialitateID) REFERENCES Specialitati(ID)
);


CREATE TABLE ServiciiPersonalizate (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    MedicID INT,
    ServiciuID INT,
    PretPersonalizat DECIMAL(10, 2),
    DurataPersonalizata INT,
    FOREIGN KEY (MedicID) REFERENCES Angajati(ID),
    FOREIGN KEY (ServiciuID) REFERENCES ServiciiMedicale(ID)
);

CREATE TABLE Cabinete (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    LocatieID INT,
    NumeCabinet VARCHAR(50),
    TipEchipament TEXT NULL,
    FOREIGN KEY (LocatieID) REFERENCES Locatii(ID)
);

ALTER TABLE Utilizatori
MODIFY COLUMN Rol ENUM('super-admin', 'admin', 'hr', 'financiar', 'medic', 'asistent', 'receptionist') NOT NULL;

ALTER TABLE OrarLucru
ADD CONSTRAINT CK_OraFuncționare
CHECK (OraStart < OraSfarsit);

UPDATE Programari
SET DataOra = DATE_FORMAT(DataOra, '%Y-%m-%d %H:%i:00');