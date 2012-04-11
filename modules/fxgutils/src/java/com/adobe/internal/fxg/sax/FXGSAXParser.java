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
package com.adobe.internal.fxg.sax;

import java.io.IOException;
import java.io.InputStream;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.SAXException;

import com.adobe.fxg.FXGException;
import com.adobe.fxg.dom.FXGNode;
import com.adobe.fxg.FXGParser;

/**
 * FXGSAXParser implements a SAX parser for an input stream that represents a
 * FXG document
 * 
 * @author sdas
 */
public class FXGSAXParser implements FXGParser
{
    private FXGSAXScanner scanner = null;

    /**
     * Constructs a new FXGSAXParser.
     * 
     * @param profile - String indicates whether a parser is created for mobile or desktop platform
     * The scanner is initialized so that nodes and skipped elements can be
     * registered
     */
    public FXGSAXParser(String profile)
    {
        scanner = createScanner(profile);
    }

    /**
     * Parses an FXG document InputStream to produce an FXGNode based DOM.
     * 
     * @param stream - input stream to be parsed
     * @return the root FXGNode of the DOM
     * @throws FXGException if an exception occurred while parsing.
     * @throws IOException if an exception occurred while reading the stream.
     */
    public FXGNode parse(InputStream stream) throws FXGException, IOException
    {
        return parse(stream, null);
    }

    /**
     * Parses an FXG document InputStream to produce an FXGNode based DOM.
     * 
     * @param stream - input stream to be parsed
     * @param documentName - the name of the FXG document which can be useful
     * for error reporting.
     * @return the root FXGNode of the DOM
     * @throws FXGException if an exception occurred while parsing.
     * @throws IOException if an exception occurred while reading the stream.
     */
    public FXGNode parse(InputStream stream, String documentName) throws FXGException, IOException
    {
        try
        {
        	scanner.setDocumentName(documentName);
            SAXParserFactory saxFactory = SAXParserFactory.newInstance();
            saxFactory.setValidating(false);
            saxFactory.setNamespaceAware(true);
            SAXParser parser = saxFactory.newSAXParser();
            parser.parse(stream, scanner);

            FXGNode node = scanner.getRootNode();
            return node;
        }
        catch (ParserConfigurationException ex)
        {
            throw new FXGException(scanner.getStartLine(), scanner.getStartColumn(), "ErrorParsingFXG", ex.getLocalizedMessage(), ex);
        }
        catch (SAXException ex)
        {
            throw new FXGException(scanner.getStartLine(), scanner.getStartColumn(), "ErrorParsingFXG", ex.getLocalizedMessage(), ex);
        }
        finally
        {
            stream.close();
        }
    }

    /**
     * Registers a custom FXGNode for a particular type of element encountered 
     * while parsing an FXG document.
     * 
     * This method must be called prior to parsing.
     * 
     * @param version - the FXG version of the FXG element 
     * @param uri - the namespace URI of the FXG element
     * @param localName - the local name of the FXG element
     * @param nodeClass - Class of an FXGNode implementation that will represent
     * an element in the DOM and process its attributes and child nodes during
     * parsing.
     */
    public void registerElementNode(double version, String uri,  String localName, Class<? extends FXGNode> nodeClass)
    {
        scanner.registerElementNode(version, uri, localName, nodeClass);
    }

    /**
     * Specifies that a particular element should be skipped while parsing an
     * FXG document. All of the element's attributes and child nodes will be
     * skipped.
     * 
     * Skipped elements must be registered prior to parsing.
     * 
     * @param version - the FXG version of the FXG element 
     * @param uri - the namespace URI of the FXG element to skip
     * @param localName - the name of the FXG element to skip
     */
    public void skipElement(double version, String uri, String localName)
    {
        scanner.skipElement(version, uri, localName);
    }

    /**
     * @param profile - a String indicates whether a parser is created for mobile or desktop platform
     * @return a new instance of FXGSAXScanner.
     */
    protected FXGSAXScanner createScanner(String profile)
    {
        return new FXGSAXScanner(profile);
    }

}
