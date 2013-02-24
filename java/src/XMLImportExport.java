import java.io.*;
import java.util.ArrayList;

import org.w3c.dom.*;

import javax.xml.parsers.*;

import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.*;

public class XMLImportExport {

	private ArrayList<Note> resultat;
	
	XMLImportExport(String nomAccord, int renversement){
		try{
			DocumentBuilderFactory dbfac = DocumentBuilderFactory.newInstance();
	        DocumentBuilder docBuilder = dbfac.newDocumentBuilder();
	        Document xmlRequest = docBuilder.newDocument();
	
	        remplirXML(xmlRequest, nomAccord, renversement);
	        
	        TransformerFactory transfac = TransformerFactory.newInstance();
	        Transformer trans = transfac.newTransformer();
	        trans.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
	        trans.setOutputProperty(OutputKeys.INDENT, "yes");
	        StringWriter sw = new StringWriter();
	        StreamResult result = new StreamResult(sw);
	        DOMSource source = new DOMSource(xmlRequest);
	        trans.transform(source, result);
	        String xmlString = sw.toString();
	        	        
	        ProcessBuilder pb = new ProcessBuilder("/bin/sh", "-c", "./chords");
	        pb.redirectErrorStream(true);
	        Process p = pb.start();
	        InputStream inputStream = p.getInputStream();
	        OutputStream outputStream = p.getOutputStream();
	        BufferedWriter bufWriter = new BufferedWriter(new OutputStreamWriter(outputStream));
	        bufWriter.write(xmlString);
	        bufWriter.close();

	        Document xmlResult = docBuilder.parse(inputStream);
	        resultat = new ArrayList<Note>();
	        Element resultatElement = xmlResult.getDocumentElement();
	        NodeList notesList = resultatElement.getElementsByTagName("note");
	        if(notesList != null && notesList.getLength() > 0){
	        	for (int i = 0; i < notesList.getLength(); ++i) {
	        		Element noteElement = (Element) notesList.item(i);
	        		
	        		NodeList noteNomElements = noteElement.getElementsByTagName("nom");
	        		String resultNoteNom = noteNomElements.item(0).getFirstChild().getNodeValue();
	        		NodeList noteDegreElements = noteElement.getElementsByTagName("degre");
	        		String resultDegreNom = noteDegreElements.item(0).getFirstChild().getNodeValue();
	        		
	        		resultat.add(new Note(resultNoteNom, Integer.parseInt(resultDegreNom)));
	        	}
	        }
	        
        } catch (Exception e) {
            System.out.println(e);
        }
	}
	
	private void remplirXML(Document doc, String nomAccord, Integer renversement){
        Element accordNode = doc.createElement("accord");
        doc.appendChild(accordNode);
        Element nomNode = doc.createElement("nom");
        accordNode.appendChild(nomNode);
        Text nomVal = doc.createTextNode(nomAccord);
        nomNode.appendChild(nomVal);
        Element renversementNode = doc.createElement("renversement");
        accordNode.appendChild(renversementNode);
        Text renversementVal = doc.createTextNode(renversement.toString());
        renversementNode.appendChild(renversementVal);
	}
	
	public ArrayList<Note> getResultat(){
		return resultat;
	}
}
