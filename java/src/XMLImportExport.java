import java.io.*;
import java.util.ArrayList;

import org.w3c.dom.*;

import javax.xml.parsers.*;

import javax.xml.transform.*;
import javax.xml.transform.dom.*;
import javax.xml.transform.stream.*;

public class XMLImportExport {

	private ArrayList<String> resultat;
	
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
	        resultat = new ArrayList<String>();
	        Element resultatElement = xmlResult.getDocumentElement();
	        NodeList nl = resultatElement.getElementsByTagName("note");
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
	
	public ArrayList<String> getResultat(){
		return resultat;
	}
}
