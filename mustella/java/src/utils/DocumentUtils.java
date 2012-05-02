/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
package utils;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.Element;
import org.apache.xml.serialize.TextSerializer;
import org.apache.xml.serialize.XMLSerializer;
import org.apache.xml.serialize.OutputFormat;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import java.io.Writer;
import java.io.IOException;
import java.io.File;

/**
 * @author Peter Farland
 */
public class DocumentUtils
{
	private DocumentUtils()
	{
	}

	public static DocumentBuilder getBuilder(boolean ignoreComments, boolean validating, boolean ignoreContentWhitespace, boolean isNamespaceAware)
	{
		DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
		factory.setIgnoringComments(ignoreComments);
		factory.setValidating(validating);
		factory.setIgnoringElementContentWhitespace(ignoreContentWhitespace);
		factory.setNamespaceAware(isNamespaceAware);

		DocumentBuilder builder = null;

		try
		{
			builder = factory.newDocumentBuilder();
		}
		catch (Exception ex)
		{
			ex.printStackTrace();
		}

		return builder;
	}

	public static Document newDocument()
	{
		DocumentBuilder builder = getBuilder(false, false, false, true);
		return builder.newDocument();
	}

	public static Document parseDocument(String path) throws SAXException, IOException
	{
		return parseDocument(path, getBuilder(false, false, false, true));
	}

	public static Document parseDocument(String path, DocumentBuilder builder) throws SAXException, IOException
	{
		Document doc = builder.parse(path);
		return doc;
	}

	public static Document parseDocument(File file) throws SAXException, IOException
	{
		return parseDocument(file, getBuilder(false, false, false, true));
	}

	public static Document parseDocument(File file, DocumentBuilder builder) throws SAXException, IOException
	{
		Document doc = builder.parse(file);
		return doc;
	}

	public static void writeDocument(Document doc, Writer writer) throws IOException
	{
		writeDocument(doc, writer, null);
	}

	public static void writeDocument(Document doc, Writer writer, OutputFormat outputFormat) throws IOException
	{
		XMLSerializer serializer;

		if (outputFormat != null)
			serializer = new XMLSerializer(outputFormat);
		else
			serializer = new XMLSerializer();

		serializer.setOutputCharStream(writer);
		serializer.serialize(doc);
	}

	public static Element getFirstChild(Element element, String childName)
	{
		Element e = null;

		NodeList nl = element.getElementsByTagName(childName);
		if (nl != null)
		{
			e = (Element)nl.item(0);
		}

		return e;
	}

	public static Element getFirstChildByNS(Element node, String ns, String localName)
	{
		Element e = null;

		NodeList nl = node.getElementsByTagNameNS(ns, localName);
		if (nl != null)
		{
			e = (Element)nl.item(0);
		}

		return e;
	}

	public static void removeChildren(Node parent, NodeList nodelist)
	{
		for (int i = 0; i < nodelist.getLength(); i++)
		{
			parent.removeChild(nodelist.item(i));
		}
	}


}
