import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Point;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.util.ArrayList;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JTextField;

public class MainWindow extends JFrame{

	Clavier clavier;
	
    MainWindow(){
        this.setSize(new Dimension(Clavier.taille, 400));
        this.setLocationRelativeTo(null);
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setVisible(true);
        
        this.getContentPane().setLayout(new BorderLayout());
        clavier = new Clavier();
        this.getContentPane().add(clavier, BorderLayout.CENTER);

        JPanel panneauHaut = new JPanel();
        JTextField txtInput = new JTextField("");
        txtInput.setPreferredSize(new Dimension(50, 30));
        panneauHaut.add(txtInput);
        this.getContentPane().add(panneauHaut, BorderLayout.NORTH);
        panneauHaut.setSize(new Dimension(this.getWidth(), 60));
        txtInput.setLocation(new Point(panneauHaut.getWidth()/2 - txtInput.getWidth()/2, panneauHaut.getHeight()/2 - txtInput.getHeight()/2));
    
        this.repaint();
        
        txtInput.addKeyListener(new KeyAdapter(){
        	public void keyPressed(KeyEvent e){
        		if (e.getKeyCode() == KeyEvent.VK_ENTER){
        			clavier.reset();
        			ArrayList<String> noms = new ArrayList<String>();
        			noms.add("Do");
        			noms.add("Mi");
        			noms.add("Sol");
        			noms.add("Si");
        			clavier.activate(noms);
        		}
        	}
        });
    }
}
