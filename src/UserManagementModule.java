import javax.management.relation.Role;
import javax.swing.*;
import java.awt.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;

public class UserManagementModule extends JFrame {
    private int userId;
    private String role;

    private JTextField usernameField;
    private JTextField passwordField;
    private JTextField roleField;

    public UserManagementModule(int userId, String role) {
        this.userId = userId;
        this.role = role;
        setTitle("Gestionare Utilizatori");
        setSize(600, 400);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        initializeUI();
    }

    private void initializeUI() {
        JPanel panel = new JPanel(new GridLayout(5, 1, 10, 10));

        // Câmpuri pentru adăugarea/actualizarea utilizatorului
        usernameField = new JTextField();
        passwordField = new JTextField();
        roleField = new JTextField();

        // Butoane pentru operațiile de gestionare utilizatori
        JButton addUserButton = new JButton("Adăugare Utilizator");
        JButton deleteUserButton = new JButton("Ștergere Utilizator");
        JButton updateUserButton = new JButton("Modificare Utilizator");

        // Adăugare butoane și câmpuri în panou
        panel.add(new JLabel("Username:"));
        panel.add(usernameField);
        panel.add(new JLabel("Password:"));
        panel.add(passwordField);
        panel.add(new JLabel("Role:"));
        panel.add(roleField);

        addUserButton.addActionListener(e -> addUser());  // Nu mai sunt necesari parametrii
        deleteUserButton.addActionListener(e -> deleteUser(userId,role));  // Se va folosi `userId` existent
        updateUserButton.addActionListener(e -> {
            String userIdInput = JOptionPane.showInputDialog(this, "Introduceți ID-ul utilizatorului de modificat:");
            if (userIdInput != null && !userIdInput.trim().isEmpty()) {
                try {
                    int userId = Integer.parseInt(userIdInput.trim());
                    new EditUserFrame(userId).setVisible(true); // Deschide fereastra de editare
                } catch (NumberFormatException ex) {
                    JOptionPane.showMessageDialog(this, "ID-ul trebuie să fie un număr valid!", "Eroare", JOptionPane.ERROR_MESSAGE);
                }
            }
        });




        panel.add(addUserButton);
        panel.add(deleteUserButton);
        panel.add(updateUserButton);

        add(panel);
    }

    // Metodă de verificare a autentificării utilizatorului
    public boolean checkUserCredentials(String username, String password) throws SQLException {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "SELECT * FROM Utilizatori WHERE Email = ? AND Parola= ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, username);
                stmt.setString(2, password);
                try (ResultSet rs = stmt.executeQuery()) {
                    return rs.next(); // Dacă utilizatorul există în baza de date
                }
            }
        }
    }

    // Metodă de adăugare a unui utilizator (fără parametri expliciți)
    public void addUser() {
        try {
            String username = usernameField.getText();
            String password = passwordField.getText();
            String role = roleField.getText();

            try (Connection conn = DatabaseConnection.getConnection()) {
                String sql = "INSERT INTO Utilizatori(Email, Parola, Rol) VALUES (?, ?, ?)";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, username);
                    stmt.setString(2, password);
                    stmt.setString(3, role);
                    stmt.executeUpdate();
                    JOptionPane.showMessageDialog(this, "Utilizator adăugat cu succes!");
                }
            }
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(this, "Eroare la adăugarea utilizatorului: " + e.getMessage());
        }
    }

    // Metodă de actualizare a unui utilizator (fără parametri expliciți)
    public void updateUser() {
        String newEmail = usernameField.getText();
        String newPassword = passwordField.getText();
        String newRole = roleField.getText();

        // Validare date
        if (newEmail.isEmpty() || newPassword.isEmpty() || newRole.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Toate câmpurile sunt obligatorii!", "Eroare", JOptionPane.ERROR_MESSAGE);
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            // Verifică dacă email-ul este utilizat de alt utilizator
            String checkEmailSQL = "SELECT COUNT(*) FROM Utilizatori WHERE Email = ? AND ID != ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkEmailSQL)) {
                checkStmt.setString(1, newEmail);
                checkStmt.setInt(2, userId);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    rs.next();
                    if (rs.getInt(1) > 0) {
                        JOptionPane.showMessageDialog(this, "Email-ul există deja la un alt utilizator!", "Eroare", JOptionPane.ERROR_MESSAGE);
                        return;
                    }
                }
            }

            // Actualizează utilizatorul în baza de date
            String updateSQL = "UPDATE Utilizatori SET Email = ?, Parola = ?, Rol = ? WHERE ID = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateSQL)) {
                stmt.setString(1, newEmail);
                stmt.setString(2, newPassword);
                stmt.setString(3, newRole);
                stmt.setInt(4, userId);

                int rowsUpdated = stmt.executeUpdate();
                if (rowsUpdated > 0) {
                    JOptionPane.showMessageDialog(this, "Utilizator actualizat cu succes!", "Succes", JOptionPane.INFORMATION_MESSAGE);
                } else {
                    JOptionPane.showMessageDialog(this, "Utilizatorul nu a fost găsit!", "Eroare", JOptionPane.ERROR_MESSAGE);
                }
            }
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, "Eroare la actualizarea utilizatorului: " + e.getMessage(), "Eroare", JOptionPane.ERROR_MESSAGE);
            e.printStackTrace();
        }
    }


    // Metodă de ștergere a unui utilizator (fără parametri expliciți)
    public void deleteUser(int userId, String userRole) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false); // Începem o tranzacție

            // Verificăm rolul utilizatorului țintă
            String targetRole = null;
            try (PreparedStatement stmt = conn.prepareStatement("SELECT Rol FROM Utilizatori WHERE ID = ?")) {
                stmt.setInt(1, userId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        targetRole = rs.getString("Rol");
                    } else {
                        JOptionPane.showMessageDialog(this, "Utilizatorul nu există!", "Eroare", JOptionPane.ERROR_MESSAGE);
                        return;
                    }
                }
            }

            // Verificăm permisiunea pentru ștergere
            if ("admin".equals(userRole) && ("super-admin".equals(targetRole) || "admin".equals(targetRole))) {
                JOptionPane.showMessageDialog(this, "Doar super-administratorii pot șterge acest utilizator!", "Eroare", JOptionPane.ERROR_MESSAGE);
                return;
            }

            // Ștergem dependențele
            try (PreparedStatement stmt = conn.prepareStatement("DELETE FROM Angajati WHERE UtilizatorID = ?")) {
                stmt.setInt(1, userId);
                stmt.executeUpdate();
            }

            try (PreparedStatement stmt = conn.prepareStatement("DELETE FROM BonuriFiscale WHERE ReceptionerID = ?")) {
                stmt.setInt(1, userId);
                stmt.executeUpdate();
            }

            // Ștergem utilizatorul propriu-zis
            try (PreparedStatement stmt = conn.prepareStatement("DELETE FROM Utilizatori WHERE ID = ?")) {
                stmt.setInt(1, userId);
                int rowsAffected = stmt.executeUpdate();
                if (rowsAffected > 0) {
                    JOptionPane.showMessageDialog(this, "Utilizator șters cu succes!", "Succes", JOptionPane.INFORMATION_MESSAGE);
                } else {
                    JOptionPane.showMessageDialog(this, "Utilizatorul nu a fost găsit!", "Eroare", JOptionPane.ERROR_MESSAGE);
                }
            }

            conn.commit(); // Confirmăm tranzacția
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(this, "Eroare la ștergerea utilizatorului: " + ex.getMessage(), "Eroare", JOptionPane.ERROR_MESSAGE);
            ex.printStackTrace();
        }
    }


}
