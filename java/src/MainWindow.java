import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Point;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.util.ArrayList;

import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

public class MainWindow extends JFrame{

	Clavier clavier;
	JTextField txtNomAccord;
	JTextField txtRenversement;
	
    MainWindow(){
        this.setSize(new Dimension(Clavier.taille, 400));
        this.setLocationRelativeTo(null);
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setVisible(true);
        
        this.getContentPane().setLayout(new BorderLayout());
        clavier = new Clavier();
        this.getContentPane().add(clavier, BorderLayout.CENTER);

        JPanel panneauHaut = new JPanel();
        this.getContentPane().add(panneauHaut, BorderLayout.NORTH);
        panneauHaut.setSize(new Dimension(this.getWidth(), 60));
    
        JLabel lblNomAccord = new JLabel("Accord");
        panneauHaut.add(lblNomAccord);
        txtNomAccord = new JTextField();
        txtNomAccord.setPreferredSize(new Dimension(50, 30));
        txtNomAccord.setLocation(new Point(panneauHaut.getWidth()/2 - txtNomAccord.getWidth()/2, panneauHaut.getHeight()/2 - txtNomAccord.getHeight()/2));
        panneauHaut.add(txtNomAccord);

        JLabel lblRenversement = new JLabel("Renversement");
        panneauHaut.add(lblRenversement);
        txtRenversement = new JTextField();
        txtRenversement.setPreferredSize(new Dimension(50, 30));
        txtRenversement.setLocation(new Point(panneauHaut.getWidth()/2 - txtRenversement.getWidth()/2, panneauHaut.getHeight()/2 - txtRenversement.getHeight()/2));
        panneauHaut.add(txtRenversement);

        this.repaint();
        
        txtNomAccord.addKeyListener(new AccordsKeyAdapter());
        txtRenversement.addKeyListener(new AccordsKeyAdapter());
        
        }

    class AccordsKeyAdapter extends KeyAdapter{
    	public void keyPressed(KeyEvent e){
    		if (e.getKeyCode() == KeyEvent.VK_ENTER){
    			String nom = txtNomAccord.getText();
    			int renversement = txtRenversement.getText().length() > 0 ? Integer.parseInt(txtRenversement.getText()) : 0;
    			XMLImportExport calculateurNotes = new XMLImportExport(nom, renversement);
    			ArrayList<String> noms = calculateurNotes.getResultat();

    			clavier.reset();
    			clavier.activate(noms);
    		}
    	}
    }
}
