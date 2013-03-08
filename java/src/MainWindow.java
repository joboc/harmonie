import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Point;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.util.ArrayList;

import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.JCheckBox;

public class MainWindow extends JFrame{

	Clavier clavier;
	JTextField txtNomAccord;
	JTextField txtRenversement;
	JCheckBox chk9eme;
	JCheckBox chkRetirerFond;
	
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
        
        chk9eme = new JCheckBox("9eme");
        panneauHaut.add(chk9eme);

        chkRetirerFond = new JCheckBox("Retirer la fondamentale");
        panneauHaut.add(chkRetirerFond);

        this.repaint();
        
        txtNomAccord.addKeyListener(new AccordsKeyListener());
        txtRenversement.addKeyListener(new AccordsKeyListener());
        chk9eme.addItemListener(new AccordsItemListener());
        
    }

    private void requeteAccord(){
		String nom = txtNomAccord.getText();
		int renversement = txtRenversement.getText().length() > 0 ? Integer.parseInt(txtRenversement.getText()) : 0;
		boolean ajouter9eme = chk9eme.isSelected();
		boolean retirerFond = chkRetirerFond.isSelected();
		XMLImportExport calculateurNotes = new XMLImportExport(nom, renversement, ajouter9eme, retirerFond);
		ArrayList<Note> notes = calculateurNotes.getResultat();

		clavier.reset();
		clavier.activate(notes);
    }

    private class AccordsKeyListener extends KeyAdapter{
    	public void keyPressed(KeyEvent e){
    		if (e.getKeyCode() == KeyEvent.VK_ENTER){
    			requeteAccord();
    		}
    	}
    }
    private class AccordsItemListener implements ItemListener{
    	public void itemStateChanged(ItemEvent e){
   			requeteAccord();
    	}
    }

}
