/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flex2.compiler.swc.catalog;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

/**
 * SAX handler for reading in catalog.xml
 *
 * @author Brian Deitte
 */
public class CatalogHandler extends DefaultHandler
{
    private ReadContext readContext = new ReadContext();
    private CatalogReader reader;

    public CatalogHandler(CatalogReader reader)
    {
        this.reader = reader;
    }

    public void startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException
    {
        readContext.setCurrent(qName, attributes);

        CatalogReadElement current = readContext.getCurrentParent();
        if (current == null)
        {
            current = reader.defaultReadElement;
        }
        current = current.readElement(readContext);
        if (current != null)
        {
            readContext.setCurrentParent(current, localName);
        }
    }

    public void endElement( String uri, String localName, String qName )
        throws SAXException
    {
        readContext.setCurrent(qName, null);        
        CatalogReadElement current = readContext.getCurrentParent();
        if (current != null)
        {
            current.endElement(readContext);
        }
        readContext.clearCurrentParent(qName);
    }

    public void clear()
    {
        readContext.clear();
    }

    // TODO: use below?

    /*public void warning (SAXParseException e)
	throws SAXException
    {
        System.err.println("WARNING: " + e);
        e.printStackTrace();
    }

    public void deprecated(SAXParseException e)
	{
        System.err.println("DEPRECATED: " + e);
        e.printStackTrace();
	}

    public void error(SAXParseException e)
    {
        System.err.println("ERROR: " + e);
        e.printStackTrace();
    }

    public void fatalError(SAXParseException e)
            throws SAXParseException
    {
        System.err.println("FATAL ERROR: " + e);
        e.printStackTrace();
        throw e;
    }*/
}
