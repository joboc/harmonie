import java.awt.Color;
import java.awt.Graphics;

import javax.swing.JPanel;

public class Clavier extends JPanel{
	
	static int interstice = 5;

	public void paintComponent(Graphics g){
		g.setColor(Color.gray);
		int tailleTouche = this.getWidth() / 7;
		g.setColor(Color.white);
		for (int i = 0; i < 7; ++i){
			g.fillRect(interstice/2 + i * tailleTouche, 0, tailleTouche - interstice, this.getHeight());
		}
		g.setColor(Color.black);
		for (int i = 0; i < 6; ++i){
			if (i != 2)
				g.fillRect(tailleTouche*3/4 + tailleTouche * i, 0, tailleTouche/2, this.getHeight()*5/8);
		}
	}
}
