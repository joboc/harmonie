import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics;
import java.util.ArrayList;
import java.util.Dictionary;
import java.util.HashMap;
import java.util.Map;

import javax.swing.JPanel;

public class Clavier extends JPanel{
	
	private static int interstice = 2;
	private static int contour = 2;
	private static int tailleBlanche = 65;
	private static int hauteurActivationBlanche = 140;
	private static double proportionHauteurNoire = 0.6;
	private static int nbOctaves = 2;
	private static int nbNotes = 12 * nbOctaves;
	public static int taille = 7 * tailleBlanche * nbOctaves;
	
	private boolean[] notesActives = new boolean[nbNotes];
	private Integer[] degresActifs = new Integer[nbNotes];
	private int[] mappingBlanchesNotes = new int[7];
	private int[] mappingNoiresNotes = new int[5];
    private static final Map<String, Integer> mappingNomsNotes = new HashMap<String, Integer>();

	Clavier(){
		reset();
		
		mappingBlanchesNotes[0] = 0;
		mappingNoiresNotes[0]   = 1;
		mappingBlanchesNotes[1] = 2;
		mappingNoiresNotes[1]   = 3;
		mappingBlanchesNotes[2] = 4;
		mappingBlanchesNotes[3] = 5;
		mappingNoiresNotes[2]   = 6;
		mappingBlanchesNotes[4] = 7;
		mappingNoiresNotes[3]   = 8;
		mappingBlanchesNotes[5] = 9;
		mappingNoiresNotes[4]   = 10;
		mappingBlanchesNotes[6] = 11;
		
		mappingNomsNotes.put("Do", 0);
		mappingNomsNotes.put("Do#", 1);
		mappingNomsNotes.put("Reb", 1);
		mappingNomsNotes.put("Re", 2);
		mappingNomsNotes.put("Re#", 3);
		mappingNomsNotes.put("Mib", 3);
		mappingNomsNotes.put("Mi", 4);
		mappingNomsNotes.put("Fa", 5);
		mappingNomsNotes.put("Fa#", 6);
		mappingNomsNotes.put("Solb", 6);
		mappingNomsNotes.put("Sol", 7);
		mappingNomsNotes.put("Sol#", 8);
		mappingNomsNotes.put("Lab", 8);
		mappingNomsNotes.put("La", 9);
		mappingNomsNotes.put("La#", 10);
		mappingNomsNotes.put("Sib", 10);
		mappingNomsNotes.put("Si", 11);
	}

	public void reset(){
		for (int i = 0; i < 12 * nbOctaves; ++i){
			notesActives[i] = false;
			degresActifs[i] = -1;
		}
	}
	
	public void activate(ArrayList<Note> notes){
		int notePrecedente = -1;
		for (int i = 0; i < notes.size(); ++i){
			int iNote = mappingNomsNotes.get(notes.get(i).getNom());
			while (iNote < notePrecedente)
				iNote += 12;
			notesActives[iNote] = true;
			degresActifs[iNote] = notes.get(i).getDegre();
			notePrecedente = iNote;
		}
		this.repaint();
	}
	
	private enum COULEUR_TOUCHE{
		BLANCHE,
		NOIRE
	}
	
	private int indexNote(int octave, int touche, COULEUR_TOUCHE couleur){
		int note = 0;
		if (couleur == COULEUR_TOUCHE.BLANCHE){
			note = mappingBlanchesNotes[touche];
		} else if (couleur == COULEUR_TOUCHE.NOIRE){
			note = mappingNoiresNotes[touche];
		}
		return 12 * octave + note;
	}
	
	private void afficherDegre(int x, int y, int l, int h, String degre, Graphics g){
		g.setColor(Color.YELLOW);
		FontMetrics metrics = g.getFontMetrics();
		String affichage = degre;
		int lText = metrics.stringWidth(affichage);
		int hText = metrics.getAscent();
		g.drawString(affichage, x + l / 2 - lText / 2, y + h / 2 + hText / 2);
	}
	
	public void paintComponent(Graphics g){
		int tailleOctave = 7 * tailleBlanche;
		g.setFont(new Font("Arial", Font.PLAIN, 28));
		for (int iOctave = 0; iOctave < 2; ++iOctave){
			// touches blanches
			for (int i = 0; i < 7; ++i){
				g.setColor(Color.BLACK); // contour
				g.fillRect(iOctave * tailleOctave + interstice/2 + i * tailleBlanche, 0, tailleBlanche - interstice, this.getHeight());
				g.setColor(Color.WHITE); // touche
				g.fillRect(contour + iOctave * tailleOctave + interstice/2 + i * tailleBlanche, contour, tailleBlanche - interstice - 2*contour, this.getHeight() - 2*contour);
				int iNote = indexNote(iOctave, i, COULEUR_TOUCHE.BLANCHE);
				if (notesActives[iNote]){
					g.setColor(Color.RED); // touche active
					int xActivationTouche = contour + iOctave * tailleOctave + interstice/2 + i * tailleBlanche;
					int yActivationTouche = contour + this.getHeight() - hauteurActivationBlanche;
					int lActivationTouche = tailleBlanche - interstice - 2*contour;
					int hActivationTouche = hauteurActivationBlanche - 2*contour;
					g.fillRect(xActivationTouche, yActivationTouche, lActivationTouche, hActivationTouche);
					if (degresActifs[iNote] != -1){
						afficherDegre(xActivationTouche, yActivationTouche, lActivationTouche, hActivationTouche, degresActifs[iNote].toString(), g);
					}
				}
			}
			// touches noires
			for (int i = 0; i < 6; ++i){
				if (i != 2){
					g.setColor(Color.BLACK); // contour
					g.fillRect(iOctave * tailleOctave + tailleBlanche*3/4 + tailleBlanche * i, 0, tailleBlanche/2, (int) (this.getHeight() * proportionHauteurNoire));
					int iNote = indexNote(iOctave, i<2 ? i : i-1, COULEUR_TOUCHE.NOIRE);
					if (notesActives[iNote]){
						g.setColor(Color.RED); // touche active
					}
					int xActivationTouche = contour + iOctave * tailleOctave + tailleBlanche*3/4 + tailleBlanche * i; 
					int yActivationTouche = contour; 
					int lActivationTouche = tailleBlanche/2 - 2*contour; 
					int hActivationTouche = (int) (this.getHeight() * proportionHauteurNoire - 2*contour); 
					g.fillRect(xActivationTouche, yActivationTouche, lActivationTouche, hActivationTouche);
					if (notesActives[iNote]){
						if (degresActifs[iNote] != -1){
							afficherDegre(xActivationTouche, yActivationTouche, lActivationTouche, hActivationTouche, degresActifs[iNote].toString(), g);
						}
					}
				}
			}
		}
	}
}
