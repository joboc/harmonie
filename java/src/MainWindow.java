import java.awt.Dimension;

import javax.swing.JFrame;

public class MainWindow extends JFrame{

    MainWindow(){
        this.setSize(new Dimension(700, 400));
        this.setLocationRelativeTo(null);
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setVisible(true);
    }
}
