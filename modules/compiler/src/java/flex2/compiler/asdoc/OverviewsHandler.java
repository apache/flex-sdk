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
import java.util.List;
import java.util.Iterator;

import flex2.tools.ASDocConfiguration;

/**
 * SAX Handler for parsing Overviews_Base.xml and writing out overviews.xml
 *
 * @author Brian Deitte
 */
public class OverviewsHandler extends DefaultHandler
{
	private BufferedWriter writer;
	private List packages;

	/**
	 * Constructor
	 * 
	 * @param w
	 * @param config
	 */
	public OverviewsHandler(BufferedWriter w, ASDocConfiguration config)
	{
		writer = w;
		packages = config.getPackagesConfiguration().getPackages();
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
			if (qName.equals("packages") && packages.size() > 0)
			{
				throw new RuntimeException("packages can not be specified in ASDoc_Config.xml and as a Flex parameter");
			}
			// if this element was added as a parameter, we use the parameter value
			writer.newLine();
			writer.write("<" + qName);
			for (int i = 0; i < attributes.getLength(); i++)
			{
				writer.write(" " + attributes.getQName(i) + "=\"" + attributes.getValue(i) + "\"");
			}
			writer.write(">");
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
			if (qName.equals("overviews"))
			{
				if (packages.size() > 0)
				{
					writer.newLine();
					writer.write("<packages>");
					for (Iterator iterator = packages.iterator(); iterator.hasNext();)
					{
						PackageInfo info = (PackageInfo)iterator.next();
						writer.newLine();
						writer.write("<package name=\"" + info.name + "\">");
						writer.newLine();
						writer.write("<shortDescription>" + info.description + "</shortDescription>");
						writer.write("<longDescription>" + info.description + "</longDescription>");

						writer.newLine();
						writer.write("</package>");
					}
					writer.newLine();
					writer.write("</packages>");
				}
			}
			writer.write("</" + qName + ">");
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
