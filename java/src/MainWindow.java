import java.awt.BorderLayout;
import java.awt.Dimension;

import javax.swing.JFrame;
import javax.swing.JPanel;

public class MainWindow extends JFrame{

    MainWindow(){
        this.setSize(new Dimension(500, 400));
        this.setLocationRelativeTo(null);
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setVisible(true);
        
        this.getContentPane().setLayout(new BorderLayout());
        this.add(new Clavier(), BorderLayout.CENTER);
    }
}
