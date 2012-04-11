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

package flex2.compiler.mxml.dom;

import java.io.StringWriter;

/**
 * Represents a &lt;![[CDATA]]&gt; tag.
 *
 * @author Clement Wong
 */
public class CDATANode extends Node
{
	public CDATANode()
	{
		super("", "", 0);
		inCDATA = false;
	}

	public boolean inCDATA;

	public void analyze(Analyzer analyzer)
	{
		analyzer.prepare(this);
		analyzer.analyze(this);
	}

	public void toStartElement(StringWriter w)
	{
		if (inCDATA)
		{
			w.write("<![CDATA[");
			w.write(image);
			w.write("]]>");
		}
		else
		{
			w.write(image);
		}
	}

	public void toEndElement(StringWriter w)
	{
	}

	public boolean isWhitespace()
	{
	    return image != null && image.trim().length() == 0;
	}

	public String toString()
	{
		String cdata = image.replace('\r', ' ').replace('\n', ' ').trim();
		cdata = (cdata.length() > 10) ? cdata.substring(0, 10) + "..." : cdata;
		return "<![[ " + cdata + " ]]>";
	}
}
