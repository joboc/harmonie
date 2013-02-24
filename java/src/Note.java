
public class Note {

	private String nom;
	private int degre;
	
	Note(String nom, int degre){
		this.nom = nom;
		this.degre = degre;
	}
	
	public String getNom(){
		return nom;
	}
	public int getDegre(){
		return degre;
	}
}
