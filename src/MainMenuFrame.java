import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class MainMenuFrame extends JFrame {
    private int userId;
    private String role;

    public MainMenuFrame(int userId, String role) {
        this.userId = userId;
        this.role = role;
        setTitle("Meniu Principal - Policlinica");
        setSize(600, 400);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLocationRelativeTo(null);

        initializeUI();
    }

    private void initializeUI() {
        JPanel panel = new JPanel(new GridLayout(5, 1, 10, 10));

        JButton hrButton = new JButton("Resurse Umane");
        JButton financeButton = new JButton("Modul Financiar");
        JButton operationsButton = new JButton("Modul Operațional");
        JButton userManagementButton = new JButton("Gestionare Utilizatori");
        JButton logoutButton = new JButton("Deautentificare");

        hrButton.addActionListener(e -> new HRModule(userId, role).setVisible(true));
        financeButton.addActionListener(e -> new FinanceModule(userId, role).setVisible(true));
        operationsButton.addActionListener(e -> new OperationsModule(userId, role).setVisible(true));
        userManagementButton.addActionListener(e -> new UserManagementModule(userId, role).setVisible(true));
        logoutButton.addActionListener(e -> {
            new LoginFrame().setVisible(true);
            dispose();
        });

        if (!role.equals("medic") && !role.equals("asistent") && !role.equals("receptionist")) {
            operationsButton.setEnabled(false);
        }

        if (!role.equals("admin") && !role.equals("super-admin")) {
            userManagementButton.setEnabled(false);
        }

        if (!role.equals("hr")) {
            hrButton.setEnabled(false);
        }
        if (!role.equals("financiar")) {
            financeButton.setEnabled(false);
        }

            panel.add(hrButton);
            panel.add(financeButton);
            panel.add(operationsButton);
            panel.add(userManagementButton);
            panel.add(logoutButton);

            add(panel);
        }
    }
