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

package flex2.compiler.asdoc;

import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;

import java.io.BufferedWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;

import flex2.tools.ASDocConfiguration;

/**
 * SAX Handler for parsing ASDoc_Config_Base.xml and writing out ASDoc_Config.xml
 *
 * @author Brian Deitte
 */
public class ASDocConfigHandler extends DefaultHandler
{
	private BufferedWriter writer;
	private Map<String, String> configMap = new HashMap<String, String>();
	private boolean skipCharacters;

	/**
	 * Constructor
	 * 
	 * @param w
	 * @param config
	 */
	public ASDocConfigHandler(BufferedWriter w, ASDocConfiguration config)
	{
		writer = w;

		// store all config values but packages in a map, with the key as the ASDoc_Config.xml element
		if (config.getMainTitle() != null) configMap.put("title", config.getMainTitle());
		if (config.getWindowTitle() != null) configMap.put("windowTitle", config.getWindowTitle());
		if (config.getFooter() != null) configMap.put("footer", config.getFooter());
		if (config.getExamplesPath() != null) configMap.put("includeExamplesDirectory", config.getExamplesPath());

		configMap.put("dateInFooter", String.valueOf(config.getDateInFooter()));
	}

	/**
	 * implementation for Default Handler method 
	 */
	public void startElement (String uri, String localName,
	                          String qName, Attributes attributes)
			throws SAXException
	{
		try
		{
			// if this element was added as a parameter, we use the parameter value
			if (! configMap.containsKey(qName))
			{
				skipCharacters = false;
				writer.newLine();
				writer.write("<" + qName);
				for (int i = 0; i < attributes.getLength(); i++)
				{
					writer.write(" " + attributes.getQName(i) + "=\"" + attributes.getValue(i) + "\"");
				}
				writer.write(">");
			}
			else
			{
				skipCharacters = true;
			}
		}
		catch(IOException ioe)
		{
			throw new SAXException(ioe);
		}
	}


	/**
	 * implementation for Default Handler method 
	 */
	public void endElement (String uri, String localName, String qName)
			throws SAXException
	{
		try
		{
			if (qName.equals("asDocConfig"))
			{
				// if we're at the end of the document, write out all the config values
				for (Iterator iterator = configMap.entrySet().iterator(); iterator.hasNext();)
				{
					Map.Entry entry = (Map.Entry)iterator.next();
					writer.newLine();
					writer.write("<" + entry.getKey() + ">" + entry.getValue() + "</" + entry.getKey() + ">");
				}
			}
			if (configMap.get(qName) == null)
			{
				writer.write("</" + qName + ">");
			}
		}
		catch(IOException ioe)
		{
			throw new SAXException(ioe);
		}
	}

	/**
	 * implementation for Default Handler method 
	 */
	public void characters (char ch[], int start, int length)
			throws SAXException
	{
		if (! skipCharacters)
		{
			try
			{
				writer.write(new String(ch, start, length));
			}
			catch(IOException ioe)
			{
				throw new SAXException(ioe);
			}
		}
	}
}
