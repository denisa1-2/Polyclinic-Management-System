import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class EditUserFrame extends JFrame {
    private int userId; // ID-ul utilizatorului care va fi modificat
    private JTextField emailField, phoneField, addressField, passwordField, roleField;

    public EditUserFrame(int userId) {
        this.userId = userId;

        setTitle("Modificare Utilizator");
        setSize(400, 400);
        setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        setLocationRelativeTo(null);

        initializeUI();
        loadUserData(); // Preia datele utilizatorului din baza de date
    }

    private void initializeUI() {
        JPanel panel = new JPanel(new GridLayout(6, 2, 10, 10));
        panel.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));

        JLabel emailLabel = new JLabel("Email:");
        emailField = new JTextField();

        JLabel phoneLabel = new JLabel("Telefon:");
        phoneField = new JTextField();

        JLabel addressLabel = new JLabel("Adresă:");
        addressField = new JTextField();

        JLabel passwordLabel = new JLabel("Parolă:");
        passwordField = new JTextField();

        JLabel roleLabel = new JLabel("Rol:");
        roleField = new JTextField();

        JButton saveButton = new JButton("Salvează");
        saveButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                updateUser(); // Actualizează datele utilizatorului
            }
        });

        panel.add(emailLabel);
        panel.add(emailField);
        panel.add(phoneLabel);
        panel.add(phoneField);
        panel.add(addressLabel);
        panel.add(addressField);
        panel.add(passwordLabel);
        panel.add(passwordField);
        panel.add(roleLabel);
        panel.add(roleField);
        panel.add(new JLabel()); // Spacer
        panel.add(saveButton);

        add(panel);
    }

    private void loadUserData() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "SELECT Email, Telefon, Adresa, Parola, Rol FROM Utilizatori WHERE ID = ?";
            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setInt(1, userId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        emailField.setText(rs.getString("Email"));
                        phoneField.setText(rs.getString("Telefon"));
                        addressField.setText(rs.getString("Adresa"));
                        passwordField.setText(rs.getString("Parola"));
                        roleField.setText(rs.getString("Rol"));
                    } else {
                        JOptionPane.showMessageDialog(this, "Utilizatorul nu a fost găsit!", "Eroare", JOptionPane.ERROR_MESSAGE);
                        dispose();
                    }
                }
            }
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, "Eroare la încărcarea datelor utilizatorului: " + e.getMessage(), "Eroare", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void updateUser() {
        String newEmail = emailField.getText();
        String newPhone = phoneField.getText();
        String newAddress = addressField.getText();
        String newPassword = passwordField.getText();
        String newRole = roleField.getText();

        // Validare date
        if (newEmail.isEmpty() || newPhone.isEmpty() || newAddress.isEmpty() || newPassword.isEmpty() || newRole.isEmpty()) {
            JOptionPane.showMessageDialog(this, "Toate câmpurile sunt obligatorii!", "Eroare", JOptionPane.ERROR_MESSAGE);
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "UPDATE Utilizatori SET Email = ?, Telefon = ?, Adresa = ?, Parola = ?, Rol = ? WHERE ID = ?";
            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                stmt.setString(1, newEmail);
                stmt.setString(2, newPhone);
                stmt.setString(3, newAddress);
                stmt.setString(4, newPassword);
                stmt.setString(5, newRole);
                stmt.setInt(6, userId);

                int rowsUpdated = stmt.executeUpdate();
                if (rowsUpdated > 0) {
                    JOptionPane.showMessageDialog(this, "Utilizator actualizat cu succes!", "Succes", JOptionPane.INFORMATION_MESSAGE);
                    dispose(); // Închide fereastra după salvare
                } else {
                    JOptionPane.showMessageDialog(this, "Eroare: Utilizatorul nu a fost găsit!", "Eroare", JOptionPane.ERROR_MESSAGE);
                }
            }
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, "Eroare la actualizarea utilizatorului: " + e.getMessage(), "Eroare", JOptionPane.ERROR_MESSAGE);
        }
    }
}
