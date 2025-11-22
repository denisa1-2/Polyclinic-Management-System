import javax.swing.*;
import java.awt.*;
import java.sql.*;

public class HRModule extends JFrame {
    private int userId;
    private String role;

    public HRModule(int userId, String role) {
        this.userId = userId;
        this.role = role;
        setTitle("Modul HR");
        setSize(600, 500);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        initializeUI();
    }

    private void initializeUI() {
        JPanel panel = new JPanel(new GridLayout(4, 1, 10, 10));

        JButton assignDoctorButton = new JButton("Repartizare Medici");
        JButton customizeServiceButton = new JButton("Personalizare Servicii");
        JButton manageSchedulesButton = new JButton("Gestionare Orar");
        JButton manageLeavesButton = new JButton("Gestionare Concedii");

        assignDoctorButton.addActionListener(e -> assignDoctorToCabinet());
        customizeServiceButton.addActionListener(e -> customizeMedicalService());
        manageSchedulesButton.addActionListener(e -> manageSchedules());
        manageLeavesButton.addActionListener(e -> manageLeaves());

        panel.add(assignDoctorButton);
        panel.add(customizeServiceButton);
        panel.add(manageSchedulesButton);
        panel.add(manageLeavesButton);

        add(panel);
    }

    private void assignDoctorToCabinet() {
        String medicId = JOptionPane.showInputDialog(this, "Introduceți ID-ul medicului:");
        String cabinetId = JOptionPane.showInputDialog(this, "Introduceți ID-ul cabinetului:");
        String dataStart = JOptionPane.showInputDialog(this, "Introduceți data de început (YYYY-MM-DD):");
        String dataSfarsit = JOptionPane.showInputDialog(this, "Introduceți data de sfârșit (YYYY-MM-DD):");

        if (medicId == null || cabinetId == null || dataStart == null || dataSfarsit == null ||
                medicId.trim().isEmpty() || cabinetId.trim().isEmpty() ||
                dataStart.trim().isEmpty() || dataSfarsit.trim().isEmpty()) {
            JOptionPane.showMessageDialog(this, "Toate câmpurile sunt obligatorii!", "Eroare", JOptionPane.ERROR_MESSAGE);
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "{CALL RepartizeazaMedici(?, ?, ?, ?)}";
            CallableStatement stmt = conn.prepareCall(query);

            stmt.setInt(1, Integer.parseInt(medicId));
            stmt.setInt(2, Integer.parseInt(cabinetId));
            stmt.setString(3, dataStart);
            stmt.setString(4, dataSfarsit);

            stmt.execute();
            JOptionPane.showMessageDialog(this, "Medicul a fost repartizat cu succes!", "Succes", JOptionPane.INFORMATION_MESSAGE);
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "Eroare la repartizarea medicului: " + ex.getMessage(), "Eroare", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void customizeMedicalService() {
        String medicId = JOptionPane.showInputDialog(this, "Introduceți ID-ul medicului:");
        String serviciuId = JOptionPane.showInputDialog(this, "Introduceți ID-ul serviciului:");
        String pretPersonalizat = JOptionPane.showInputDialog(this, "Introduceți prețul personalizat:");
        String durataPersonalizata = JOptionPane.showInputDialog(this, "Introduceți durata personalizată (în minute):");

        if (medicId == null || serviciuId == null || pretPersonalizat == null || durataPersonalizata == null ||
                medicId.trim().isEmpty() || serviciuId.trim().isEmpty() ||
                pretPersonalizat.trim().isEmpty() || durataPersonalizata.trim().isEmpty()) {
            JOptionPane.showMessageDialog(this, "Toate câmpurile sunt obligatorii!", "Eroare", JOptionPane.ERROR_MESSAGE);
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "{CALL PersonalizeazaServicii(?, ?, ?, ?)}";
            CallableStatement stmt = conn.prepareCall(query);

            stmt.setInt(1, Integer.parseInt(medicId));
            stmt.setInt(2, Integer.parseInt(serviciuId));
            stmt.setDouble(3, Double.parseDouble(pretPersonalizat));
            stmt.setInt(4, Integer.parseInt(durataPersonalizata));

            stmt.execute();
            JOptionPane.showMessageDialog(this, "Serviciul medical a fost personalizat cu succes!", "Succes", JOptionPane.INFORMATION_MESSAGE);
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "Eroare la personalizarea serviciului medical: " + ex.getMessage(), "Eroare", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void manageSchedules() {
        String angajatID = JOptionPane.showInputDialog(this, "Introduceți ID-ul angajatului:");
        String ziua = JOptionPane.showInputDialog(this, "Introduceți ziua (Luni, Marti, etc.):");
        String dataCalendaristica = JOptionPane.showInputDialog(this, "Introduceți data specifică (YYYY-MM-DD) sau lăsați gol pentru orar generic:");
        String oraStart = JOptionPane.showInputDialog(this, "Introduceți ora de început (HH:MM):");
        String oraSfarsit = JOptionPane.showInputDialog(this, "Introduceți ora de sfârșit (HH:MM):");
        String locatie = JOptionPane.showInputDialog(this, "Introduceți locația:");
        String tipOrar = (dataCalendaristica == null || dataCalendaristica.isEmpty()) ? "generic" : "specific";

        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "CALL AdaugaOrar(?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setString(1, role);
            stmt.setInt(2, Integer.parseInt(angajatID));
            stmt.setString(3, ziua);
            stmt.setString(4, dataCalendaristica.isEmpty() ? null : dataCalendaristica);
            stmt.setString(5, oraStart);
            stmt.setString(6, oraSfarsit);
            stmt.setString(7, locatie);
            stmt.setString(8, tipOrar);

            stmt.execute();
            JOptionPane.showMessageDialog(this, "Orarul a fost gestionat cu succes!", "Succes", JOptionPane.INFORMATION_MESSAGE);
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "Eroare la gestionarea orarului!", "Eroare", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void manageLeaves() {
        String angajatID = JOptionPane.showInputDialog(this, "Introduceți ID-ul angajatului:");
        String dataStart = JOptionPane.showInputDialog(this, "Introduceți data de început a concediului (YYYY-MM-DD):");
        String dataSfarsit = JOptionPane.showInputDialog(this, "Introduceți data de sfârșit a concediului (YYYY-MM-DD):");
        String motiv = JOptionPane.showInputDialog(this, "Introduceți motivul concediului:");

        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "INSERT INTO Concedii (AngajatID, DataStart, DataSfarsit, Motiv) VALUES (?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(query);
            stmt.setInt(1, Integer.parseInt(angajatID));
            stmt.setString(2, dataStart);
            stmt.setString(3, dataSfarsit);
            stmt.setString(4, motiv);

            stmt.execute();
            JOptionPane.showMessageDialog(this, "Concediul a fost gestionat cu succes!", "Succes", JOptionPane.INFORMATION_MESSAGE);
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "Eroare la gestionarea concediului!", "Eroare", JOptionPane.ERROR_MESSAGE);
        }
    }

}
