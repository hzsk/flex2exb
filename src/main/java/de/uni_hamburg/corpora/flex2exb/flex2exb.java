/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.uni_hamburg.corpora.flex2exb;

import com.sun.jersey.core.header.FormDataContentDisposition;
import com.sun.jersey.multipart.FormDataParam;
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.Scanner;
import javax.ws.rs.Consumes;
import javax.ws.rs.DefaultValue;
import javax.ws.rs.FormParam;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import org.w3c.dom.Document;
//import jdk.internal.org.xml.sax.InputSource;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import org.xml.sax.InputSource;

/**
 *
 * @author niko
 */
@Path("/file")
public class flex2exb {

    @POST
    @Path("/post/{lang}")
    @Produces("text/plain")
    public String flexTransform(final InputStream input, @PathParam("lang") String language) throws TransformerConfigurationException, IOException, TransformerException {

        InputStream xslFile = getClass().getResourceAsStream("/xsl/interlinear-flexeaf2exmaralda.xsl");

        if (xslFile == null) {
            throw new IOException("Stylesheet not found!");
        }

        StreamSource xslSource = new StreamSource(xslFile);

        // create the transformerfactory & transformer instance
        TransformerFactory tf = TransformerFactory.newInstance("net.sf.saxon.TransformerFactoryImpl", null);
        Transformer t = tf.newTransformer(xslSource);
        t.setParameter("language", language);

        // xml comes from input
        StreamSource xmlSource = new StreamSource(input);

        StringWriter xmlOutWriter = new StringWriter();
        // do transformation
        t.transform(xmlSource, new StreamResult(xmlOutWriter));

        return xmlOutWriter.toString();

    }

    @POST
    @Path("/upload")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    public String uploadFile(
            @FormDataParam("file") InputStream uploadedInputStream,
            @FormDataParam("file") FormDataContentDisposition fileDetail//,
//            @DefaultValue("unknown") @FormDataParam("lang") String language
    ) throws IOException, TransformerConfigurationException, TransformerException, XPathExpressionException, ParserConfigurationException, SAXException, Exception {

        InputStream xslFile = getClass().getResourceAsStream("/xsl/interlinear-flexeaf2exmaralda-20160908.xsl");

        if (xslFile == null) {
            throw new IOException("Stylesheet not found!");
        }

        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        Document doc = builder.parse(uploadedInputStream);
        DOMSource source = new DOMSource(doc);

        TransformerFactory tf1 = TransformerFactory.newInstance();
        Transformer transformer = tf1.newTransformer();
        StringWriter writer = new StringWriter();
        transformer.transform(new DOMSource(doc), new StreamResult(writer));
        String strResult = writer.getBuffer().toString().replaceAll("\n|\r", "");

        XPath xpath = XPathFactory.newInstance().newXPath();
        InputSource inputSource = new InputSource(new StringReader(strResult));
        String language = xpath.evaluate("/document/interlinear-text[1]/paragraphs[1]/paragraph[1]/phrases[1]/phrase[1]/words[1]/word[1]/item[1]/@lang", inputSource);

//        StreamSource xmlSource = new StreamSource(uploadedInputStream);
        StreamSource xslSource = new StreamSource(xslFile);

//        XPathFactory xpathfactory = XPathFactory.newInstance();
//        XPath xpath = xpathfactory.newXPath();
//        String language = xpath.evaluate("/document/interlinear-text[1]/paragraphs[1]/paragraph[1]/phrases[1]/phrase[1]/words[1]/word[1]/item[1]/@lang", inputSource);        
//        create the transformerfactory & transformer instance
        TransformerFactory tf = TransformerFactory.newInstance("net.sf.saxon.TransformerFactoryImpl", null);
        Transformer t = tf.newTransformer(xslSource);

        t.setParameter("language", language);

        StringWriter xmlOutWriter = new StringWriter();
        // do transformation
        t.transform(source, new StreamResult(xmlOutWriter));

        return xmlOutWriter.toString();

    }

}
