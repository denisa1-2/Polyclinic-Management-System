import javax.swing.*;
import java.awt.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class OperationsModule extends JFrame {
    private int userId;
    private String role;

    public OperationsModule(int userId, String role) {
        this.userId = userId;
        this.role = role;
        setTitle("Modul Operațional");
        setSize(600, 400);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        initializeUI();
    }

    private void initializeUI() {
        JPanel panel = new JPanel(new GridLayout(8, 1, 10, 10));

        JButton servicesButton = new JButton("Vizualizare Servicii");
        JButton patientHistoryButton = new JButton("Vizualizare Istoric Pacienți");
        JButton specificAppointmentsButton = new JButton("Vizualizare Programări Pacient");
        JButton fiscalReceiptButton = new JButton("Adăugare Bon Fiscal");
        JButton checkHoursButton = new JButton("Verificare Ore Disponibile");
        JButton completeReportsButton = new JButton("Completare Rapoarte Medicale");
        JButton viewScheduledPatientsButton = new JButton("Vizualizare Pacienți Programați");
        JButton manageAppointmentsButton = new JButton("Gestionare Programări");

        servicesButton.addActionListener(e -> viewServices());
        patientHistoryButton.addActionListener(e -> viewPatientHistory());
        specificAppointmentsButton.addActionListener(e -> viewSpecificAppointments());
        fiscalReceiptButton.addActionListener(e -> addFiscalReceipt());
        checkHoursButton.addActionListener(e -> checkAvailableHours());
        completeReportsButton.addActionListener(e -> completeMedicalReports());
        viewScheduledPatientsButton.addActionListener(e -> viewScheduledPatients());
        manageAppointmentsButton.addActionListener(e -> manageAppointments());

        if (!role.equals("receptionist")) {
            fiscalReceiptButton.setEnabled(false);
            checkHoursButton.setEnabled(false);
            manageAppointmentsButton.setEnabled(false);
        }
        if (!role.equals("medic") && !role.equals("asistent")) {
            patientHistoryButton.setEnabled(false);
            specificAppointmentsButton.setEnabled(false);
            completeReportsButton.setEnabled(false);
        }

        panel.add(servicesButton);
        panel.add(patientHistoryButton);
        panel.add(specificAppointmentsButton);
        panel.add(fiscalReceiptButton);
        panel.add(checkHoursButton);
        panel.add(completeReportsButton);
        panel.add(viewScheduledPatientsButton);
        panel.add(manageAppointmentsButton);

        add(panel);
    }

    private void viewServices() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "CALL VizualizeazaServicii()";
            PreparedStatement stmt = conn.prepareStatement(query);
            ResultSet rs = stmt.executeQuery();

            StringBuilder services = new StringBuilder("Servicii disponibile:\n\n");
            while (rs.next()) {
                services.append("Serviciu: ").append(rs.getString("Nume"))
                        .append(", Pret: ").append(rs.getDouble("Pret"))
                        .append(" lei\n");
            }

            JOptionPane.showMessageDialog(this, services.toString(), "Servicii", JOptionPane.INFORMATION_MESSAGE);
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "Eroare la încărcarea serviciilor!", "Eroare", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void viewPatientHistory() {
        String pacientId = JOptionPane.showInputDialog(this, "Introduceți ID-ul pacientului:");
        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "CALL VizualizeazaIstoricPacient(?)";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, Integer.parseInt(pacientId));
            ResultSet rs = stmt.executeQuery();

            StringBuilder history = new StringBuilder("Istoric pacient:\n\n");
            while (rs.next()) {
                history.append("Data consultație: ").append(rs.getDate("DataConsultatie"))
                        .append(", Istoric: ").append(rs.getString("Istoric"))
                        .append(", Simptome: ").append(rs.getString("Simptome"))
                        .append(", Diagnostic: ").append(rs.getString("Diagnostic"))
                        .append("\n");
            }

            JOptionPane.showMessageDialog(this, history.toString(), "Istoric Pacient", JOptionPane.INFORMATION_MESSAGE);
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "Eroare la încărcarea istoricului!", "Eroare", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void viewSpecificAppointments() {
        String pacientId = JOptionPane.showInputDialog(this, "Introduceți ID-ul pacientului:");
        if (pacientId == null || pacientId.trim().isEmpty()) {
            JOptionPane.showMessageDialog(this, "ID-ul pacientului este obligatoriu!", "Eroare", JOptionPane.ERROR_MESSAGE);
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "CALL VizualizeazaProgramariPacient(?)";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, Integer.parseInt(pacientId));
            ResultSet rs = stmt.executeQuery();

            StringBuilder appointments = new StringBuilder("Programări pacient:\n\n");
            while (rs.next()) {
                appointments.append("Data: ").append(rs.getTimestamp("DataOra"))
                        .append(", Serviciu: ").append(rs.getString("Serviciu"))
                        .append(", Medic: ").append(rs.getString("Medic"))
                        .append("\n");
            }

            JOptionPane.showMessageDialog(this, appointments.toString(), "Programări Pacient", JOptionPane.INFORMATION_MESSAGE);
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Eroare la vizualizarea programărilor: " + ex.getMessage(), "Eroare", JOptionPane.ERROR_MESSAGE);
            ex.printStackTrace();
        }
    }

    private void addFiscalReceipt() {
        String programareId = JOptionPane.showInputDialog(this, "Introduceți ID-ul programării:");
        String sumaTotal = JOptionPane.showInputDialog(this, "Introduceți suma totală:");
        String tva = JOptionPane.showInputDialog(this, "Introduceți TVA-ul:");

        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "CALL AdaugaBonFiscal(?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(query);

            stmt.setString(1, role); // Trimite rolul utilizatorului
            stmt.setInt(2, Integer.parseInt(programareId));
            stmt.setDouble(3, Double.parseDouble(sumaTotal));
            stmt.setDouble(4, Double.parseDouble(tva));

            stmt.execute();
            JOptionPane.showMessageDialog(this, "Bon fiscal adăugat cu succes!", "Succes", JOptionPane.INFORMATION_MESSAGE);
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "Eroare la adăugarea bonului fiscal!", "Eroare", JOptionPane.ERROR_MESSAGE);
        }
    }
    private void checkAvailableHours() {
        String medicId = JOptionPane.showInputDialog(this, "Introduceți ID-ul medicului:");
        String dataConsulta = JOptionPane.showInputDialog(this, "Introduceți data consultației (YYYY-MM-DD):");

        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "CALL VerificaOreDisponibile(?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(query);

            stmt.setString(1, role); // Trimite rolul utilizatorului
            stmt.setInt(2, Integer.parseInt(medicId));
            stmt.setString(3, dataConsulta);

            ResultSet rs = stmt.executeQuery();

            StringBuilder hours = new StringBuilder("Ore disponibile:\n\n");
            while (rs.next()) {
                hours.append("Ora start: ").append(rs.getTime("OraStart"))
                        .append(", Ora sfârșit: ").append(rs.getTime("OraSfarsit"))
                        .append("\n");
            }

            JOptionPane.showMessageDialog(this, hours.toString(), "Ore Disponibile", JOptionPane.INFORMATION_MESSAGE);
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "Eroare la verificarea orelor disponibile!", "Eroare", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void completeMedicalReports() {
        String pacientID = JOptionPane.showInputDialog(this, "Introduceți ID-ul pacientului:");
        String medicID = JOptionPane.showInputDialog(this, "Introduceți ID-ul medicului:");
        String asistentID = JOptionPane.showInputDialog(this, "Introduceți ID-ul asistentului (sau lăsați gol):");
        String dataConsultatie = JOptionPane.showInputDialog(this, "Introduceți data consultației (YYYY-MM-DD):");
        String istoric = JOptionPane.showInputDialog(this, "Introduceți istoricul pacientului:");
        String simptome = JOptionPane.showInputDialog(this, "Introduceți simptomele:");
        String investigatii = JOptionPane.showInputDialog(this, "Introduceți investigațiile efectuate:");
        String diagnostic = JOptionPane.showInputDialog(this, "Introduceți diagnosticul:");
        String recomandari = JOptionPane.showInputDialog(this, "Introduceți recomandările:");

        // Validare date obligatorii
        if (pacientID == null || medicID == null || dataConsultatie == null || simptome == null || diagnostic == null) {
            JOptionPane.showMessageDialog(this, "Toate câmpurile obligatorii trebuie completate!", "Eroare", JOptionPane.ERROR_MESSAGE);
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "CALL AdaugaRaportMedical(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(query);

            // Setăm parametrii procedurii
            stmt.setString(1, role); // Rolul utilizatorului (e.g., 'medic' sau 'asistent')
            stmt.setInt(2, Integer.parseInt(pacientID));
            stmt.setInt(3, Integer.parseInt(medicID));
            stmt.setObject(4, asistentID != null && !asistentID.isEmpty() ? Integer.parseInt(asistentID) : null);
            stmt.setString(5, dataConsultatie);
            stmt.setString(6, istoric);
            stmt.setString(7, simptome);
            stmt.setString(8, investigatii);
            stmt.setString(9, diagnostic);
            stmt.setString(10, recomandari);

            // Executăm procedura
            stmt.execute();
            JOptionPane.showMessageDialog(this, "Raport medical adăugat cu succes!", "Succes", JOptionPane.INFORMATION_MESSAGE);
        } catch (NumberFormatException e) {
            JOptionPane.showMessageDialog(this, "ID-urile trebuie să fie numere valide!", "Eroare", JOptionPane.ERROR_MESSAGE);
            e.printStackTrace();
        } catch (Exception ex) {
            JOptionPane.showMessageDialog(this, "Eroare la adăugarea raportului medical: " + ex.getMessage(), "Eroare", JOptionPane.ERROR_MESSAGE);
            ex.printStackTrace();
        }
    }

    private void viewScheduledPatients() {
        String medicId = JOptionPane.showInputDialog(this, "Introduceți ID-ul medicului:");

        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "CALL VizualizeazaPacientiProgramati(?)";
            PreparedStatement stmt = conn.prepareStatement(query);

            // Trimite parametrul medicID către procedura stocată
            stmt.setInt(1, Integer.parseInt(medicId));

            ResultSet rs = stmt.executeQuery();

            StringBuilder scheduledPatients = new StringBuilder("Pacienți programați:\n\n");
            while (rs.next()) {
                scheduledPatients.append("Nume: ").append(rs.getString("Nume"))
                        .append(", Prenume: ").append(rs.getString("Prenume"))
                        .append(", Data programării: ").append(rs.getTimestamp("DataProgramare"))
                        .append("\n");
            }

            JOptionPane.showMessageDialog(this, scheduledPatients.toString(), "Pacienți Programați", JOptionPane.INFORMATION_MESSAGE);
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "Eroare la vizualizarea pacienților programați!", "Eroare", JOptionPane.ERROR_MESSAGE);
        }
    }

    public void manageAppointments() {
            if (!role.equals("receptionist")) {
                JOptionPane.showMessageDialog(this, "Doar recepționerii pot adăuga programări!", "Eroare", JOptionPane.ERROR_MESSAGE);
                return;
            }

            String pacientId = JOptionPane.showInputDialog(this, "Introduceți ID-ul pacientului:");
            String medicId = JOptionPane.showInputDialog(this, "Introduceți ID-ul medicului:");
            String dataOra = JOptionPane.showInputDialog(this, "Introduceți data și ora programării (YYYY-MM-DD HH:MM:SS):");
            String serviciuId = JOptionPane.showInputDialog(this, "Introduceți ID-ul serviciului:");
            String durata = JOptionPane.showInputDialog(this, "Introduceți durata programării (în minute):");

            try (Connection conn = DatabaseConnection.getConnection()) {
                String query = "CALL AdaugaProgramare(?, ?, ?, ?, ?, ?)";
                PreparedStatement stmt = conn.prepareStatement(query);

                stmt.setString(1, role); // Rolul utilizatorului
                stmt.setInt(2, Integer.parseInt(pacientId));
                stmt.setInt(3, Integer.parseInt(medicId));
                stmt.setString(4, dataOra);
                stmt.setInt(5, Integer.parseInt(serviciuId));
                stmt.setInt(6, Integer.parseInt(durata));

                stmt.execute();
                JOptionPane.showMessageDialog(this, "Programare adăugată cu succes!", "Succes", JOptionPane.INFORMATION_MESSAGE);
            } catch (Exception ex) {
                ex.printStackTrace();
                JOptionPane.showMessageDialog(this, "Eroare la adăugarea programării: " + ex.getMessage(), "Eroare", JOptionPane.ERROR_MESSAGE);
            }
        }

    }
