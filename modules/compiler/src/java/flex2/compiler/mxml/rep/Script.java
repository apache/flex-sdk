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

package flex2.compiler.mxml.rep;

/**
 * This class represents a script block in a Mxml document.
 *
 * @author Edwin Smith
 */
public class Script implements LineNumberMapped
{
	private int xmlLineNumber, endXmlLineNumber;
	protected String text;
	private boolean isEmbedded;

	public Script(String text, int lineNumber)
	{
		this(text, lineNumber, lineNumber);
	}

	public Script(String text, int beginLine, int endLine)
	{
		this(text);
		setXmlLineNumber(beginLine);
		setEndXmlLineNumber(endLine);
	}

	public Script(String text)
	{
		this.text = text;
	}

	public int getXmlLineNumber()
	{
		return xmlLineNumber;
	}

	public int getEndXmlLineNumber()
	{
		return endXmlLineNumber;
	}

	public String getText()
	{
		return text;
	}

	public void setXmlLineNumber(int xmlLineNumber)
	{
		this.xmlLineNumber = xmlLineNumber;
	}

	public void setEndXmlLineNumber(int xmlLineNumber)
	{
		this.endXmlLineNumber = xmlLineNumber;
	}

	public void setXmlLineNumber(int xmlLineNumber, boolean allowXmlLineOffset)
	{
		setXmlLineNumber(xmlLineNumber);
	}

	public void setText(String text)
	{
		this.text = text;
	}

	public void setEmbeddedScript(boolean b)
	{
		isEmbedded = b;
	}

	public boolean isEmbedded()
	{
		return isEmbedded;
	}
}
