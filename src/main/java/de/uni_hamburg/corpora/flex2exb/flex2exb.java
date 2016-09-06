/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.uni_hamburg.corpora.flex2exb;

import java.io.IOException;
import java.io.InputStream;
import java.io.StringWriter;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

/**
 *
 * @author niko
 */

@Path("/")
public class flex2exb {

    @POST
    @Path("/flex/{lang}")
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

}
