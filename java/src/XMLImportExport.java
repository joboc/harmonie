import java.io.*;
import java.util.ArrayList;

import org.w3c.dom.*;

import javax.xml.parsers.*;

import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.*;

public class XMLImportExport {

	private ArrayList<String> resultat;
	
	XMLImportExport(String nomAccord){
		try{
			DocumentBuilderFactory dbfac = DocumentBuilderFactory.newInstance();
	        DocumentBuilder docBuilder = dbfac.newDocumentBuilder();
	        Document xmlRequest = docBuilder.newDocument();
	
	        remplirXML(xmlRequest, nomAccord);
	        
	        TransformerFactory transfac = TransformerFactory.newInstance();
	        Transformer trans = transfac.newTransformer();
	        trans.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
	        trans.setOutputProperty(OutputKeys.INDENT, "yes");
	        StringWriter sw = new StringWriter();
	        StreamResult result = new StreamResult(sw);
	        DOMSource source = new DOMSource(xmlRequest);
	        trans.transform(source, result);
	        String xmlString = sw.toString();
	        
	        FileWriter fstream = new FileWriter("request.xml");
	        BufferedWriter out = new BufferedWriter(fstream);
	        out.write(xmlString);
	        out.close();
	        
	        ProcessBuilder pb = new ProcessBuilder("/bin/sh", "-c", "./chords");
	        Process p = pb.start();
	        p.waitFor();

	        resultat = new ArrayList<String>();
	        Document xmlResult = docBuilder.parse("result.xml");
	        Element resultatElement = xmlResult.getDocumentElement();
	        NodeList nl = resultatElement.getElementsByTagName("resultat");
	        System.out.println(nl.getLength());
	        if(nl != null && nl.getLength() > 0){
	        	for (int i = 0; i < nl.getLength(); ++i) {
	        		Element el = (Element) nl.item(i);
	        		String note = el.getFirstChild().getNodeValue();
	        		resultat.add(note);
	        	}
	        }
	        
        } catch (Exception e) {
            System.out.println(e);
        }
	}
	
	private void remplirXML(Document doc, String nomAccord){
        Element accordNode = doc.createElement("accord");
        doc.appendChild(accordNode);
        Element nomNode = doc.createElement("nom");
        accordNode.appendChild(nomNode);
        Text nomVal = doc.createTextNode(nomAccord);
        nomNode.appendChild(nomVal);
        Element renversementNode = doc.createElement("renversement");
        accordNode.appendChild(renversementNode);
        Text renversementVal = doc.createTextNode("0");
        renversementNode.appendChild(renversementVal);
	}
	
	public ArrayList<String> getResultat(){
		return resultat;
	}
}
