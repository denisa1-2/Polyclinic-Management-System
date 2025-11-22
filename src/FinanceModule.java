import javax.swing.*;
import java.awt.*;
import java.sql.*;

public class FinanceModule extends JFrame {
    private int userId;
    private String role;

    public FinanceModule(int userId, String role) {
        this.userId = userId;
        this.role = role;
        setTitle("Modul Financiar");
        setSize(600, 400);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        initializeUI();
    }

    private void initializeUI() {
        JPanel panel = new JPanel(new GridLayout(2, 1, 10, 10));

        JButton viewProfitsButton = new JButton("Vizualizare Profituri");
        JButton viewSalariesButton = new JButton("Vizualizare Salarii");

        viewProfitsButton.addActionListener(e -> viewProfits());
        viewSalariesButton.addActionListener(e -> viewSalaries());

        panel.add(viewProfitsButton);
        panel.add(viewSalariesButton);

        add(panel);
    }

    private void viewProfits() {
        String luna = JOptionPane.showInputDialog(this, "Introduceți luna (YYYY-MM):");

        if (luna == null || luna.trim().isEmpty()) {
            JOptionPane.showMessageDialog(this, "Luna este obligatorie!", "Eroare", JOptionPane.ERROR_MESSAGE);
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "CALL CalculeazaProfitLunar(?)";
            CallableStatement stmt = conn.prepareCall(query);
            stmt.setString(1, luna + "-01");
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                String result = "Luna: " + rs.getString("Luna") +
                        "\nVenituri: " + rs.getDouble("VenituriTotal") +
                        "\nCheltuieli: " + rs.getDouble("CheltuieliTotal") +
                        "\nProfit: " + rs.getDouble("Profit");
                JOptionPane.showMessageDialog(this, result, "Raport Financiar", JOptionPane.INFORMATION_MESSAGE);
            } else {
                JOptionPane.showMessageDialog(this, "Nu există date pentru această lună!", "Eroare", JOptionPane.ERROR_MESSAGE);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            JOptionPane.showMessageDialog(this, "Eroare la încărcarea profitului: " + ex.getMessage(), "Eroare", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void viewSalaries() {
        String angajatIdInput = JOptionPane.showInputDialog(this, "Introduceți ID-ul angajatului:");
        String lunaInput = JOptionPane.showInputDialog(this, "Introduceți luna pentru calcul (YYYY-MM):");

        if (angajatIdInput == null || lunaInput == null || angajatIdInput.trim().isEmpty() || lunaInput.trim().isEmpty()) {
            JOptionPane.showMessageDialog(this, "ID-ul angajatului și luna sunt obligatorii!", "Eroare", JOptionPane.ERROR_MESSAGE);
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            // Verificăm rolul angajatului
            String roleQuery = "SELECT U.Rol FROM Utilizatori U JOIN Angajati A ON U.ID = A.UtilizatorID WHERE A.ID = ?";
            try (PreparedStatement roleStmt = conn.prepareStatement(roleQuery)) {
                roleStmt.setInt(1, Integer.parseInt(angajatIdInput));
                try (ResultSet roleRs = roleStmt.executeQuery()) {
                    if (roleRs.next()) {
                        String rol = roleRs.getString("Rol");
                        if ("medic".equalsIgnoreCase(rol)) {
                            calculateCombinedSalary(Integer.parseInt(angajatIdInput), lunaInput + "-01");
                        } else if ("asistent".equalsIgnoreCase(rol) || "receptionist".equalsIgnoreCase(rol)) {
                            calculateSalaryWithLeave(Integer.parseInt(angajatIdInput), lunaInput + "-01");
                        } else {
                            JOptionPane.showMessageDialog(this, "Rolul angajatului nu este suportat pentru calculul salariului.", "Eroare", JOptionPane.ERROR_MESSAGE);
                        }
                    } else {
                        JOptionPane.showMessageDialog(this, "Angajatul specificat nu există!", "Eroare", JOptionPane.ERROR_MESSAGE);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(this, "Eroare la calcularea salariului: " + e.getMessage(), "Eroare", JOptionPane.ERROR_MESSAGE);
        }
    }


    private void calculateCombinedSalary(int medicId, String luna) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "{CALL CalculeazaSalariuMedicCombinat(?, ?)}";
            CallableStatement stmt = conn.prepareCall(query);

            stmt.setInt(1, medicId);
            stmt.setString(2, luna);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                double salariuNegociat = rs.getDouble("SalariuNegociat");
                double venituriBonus = rs.getDouble("VenituriBonus");
                double salariuFinal = rs.getDouble("SalariuFinal");

                JOptionPane.showMessageDialog(this,
                        "Salariu Negociat: " + salariuNegociat +
                                "\nBonus: " + venituriBonus +
                                "\nSalariu Final: " + salariuFinal,
                        "Calcul Salariu Combinat", JOptionPane.INFORMATION_MESSAGE);
            } else {
                JOptionPane.showMessageDialog(this, "Nu s-au găsit date pentru medicul specificat!", "Eroare", JOptionPane.ERROR_MESSAGE);
            }
        } catch (Exception e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(this, "Eroare la calcularea salariului: " + e.getMessage(), "Eroare", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void calculateSalaryWithLeave(int angajatId, String luna) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "{CALL CalculeazaSalariuConcedii(?, ?)}";
            CallableStatement stmt = conn.prepareCall(query);

            stmt.setInt(1, angajatId);
            stmt.setString(2, luna);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                int oreContract = rs.getInt("OreContract");
                int oreLucrate = rs.getInt("OreLucrate");
                double salariuCalculat = rs.getDouble("SalariuCalculat");

                JOptionPane.showMessageDialog(this,
                        "Ore Contractuale: " + oreContract +
                                "\nOre Lucrate: " + oreLucrate +
                                "\nSalariu Calculat: " + salariuCalculat,
                        "Calcul Salariu cu Concediu", JOptionPane.INFORMATION_MESSAGE);
            } else {
                JOptionPane.showMessageDialog(this, "Nu s-au găsit date pentru angajatul specificat!", "Eroare", JOptionPane.ERROR_MESSAGE);
            }
        } catch (Exception e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(this, "Eroare la calcularea salariului: " + e.getMessage(), "Eroare", JOptionPane.ERROR_MESSAGE);
        }
    }

}
