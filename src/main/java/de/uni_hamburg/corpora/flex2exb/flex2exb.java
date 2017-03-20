/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.uni_hamburg.corpora.flex2exb;

import com.sun.jersey.core.header.FormDataContentDisposition;
import com.sun.jersey.multipart.FormDataParam;
import java.io.IOException;
import java.io.InputStream;
import java.io.StringReader;
import java.io.StringWriter;
import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;
import org.xml.sax.InputSource;

/**
 *
 * @author niko
 */
@Path("/file")
public class flex2exb {

    @POST
    @Path("/upload")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    @Produces("text/xml")
    public String uploadFile(
            @FormDataParam("file") InputStream uploadedInputStream,
            @FormDataParam("file") FormDataContentDisposition fileDetail//,

    ) throws IOException, TransformerConfigurationException, TransformerException, XPathExpressionException, ParserConfigurationException, SAXException, Exception {

        InputStream xslFile = getClass().getResourceAsStream("/xsl/interlinear-flex2exmaralda-var-multi.xsl");

        if (xslFile == null) {
            throw new IOException("Stylesheet not found!");
        }

        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        Document doc = builder.parse(uploadedInputStream);
        DOMSource source = new DOMSource(doc);

        String strResult = getStringFromDoc(source);
        
        XPath xpath = XPathFactory.newInstance().newXPath();
        InputSource langSource = new InputSource(new StringReader(strResult));
        String language = xpath.evaluate("/document/interlinear-text[1]/paragraphs[1]/paragraph[1]/phrases[1]/phrase[1]/words[1]/word[1]/item[1]/@lang", langSource);
        
        StreamSource xslSource = new StreamSource(xslFile);

        // create the transformerfactory & transformer instance
        TransformerFactory tf = TransformerFactory.newInstance("net.sf.saxon.TransformerFactoryImpl", null);
        Transformer t = tf.newTransformer(xslSource);

        t.setParameter("language", language);

        StringWriter xmlOutWriter = new StringWriter();
        // do transformation
        t.transform(source, new StreamResult(xmlOutWriter));

        return xmlOutWriter.toString();

    }

    public String getStringFromDoc(DOMSource domSource)    {
        try
        {
           StringWriter writer = new StringWriter();
           StreamResult result = new StreamResult(writer);
           TransformerFactory tf = TransformerFactory.newInstance();
           Transformer transformer = tf.newTransformer();
           transformer.transform(domSource, result);
           writer.flush();
           return writer.toString();
        }
        catch(TransformerException ex)
        {
           ex.printStackTrace();
           return null;
        }
    }
            
}
