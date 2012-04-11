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

package adobe.abc;

import java.io.PrintWriter;
import java.util.Stack;

/**
 *  The TraceManager exposes a trace-oriented API
 *  that writes entries in XML format.
 *  @note Doesn't use XMLWriter so that the trace
 *    entries can be manually indented; the trace
 *    files get very large and difficult to read
 *    using a browser or other ready-to-hand viewer. 
 * @author Tom Harwood
 *
 */
public class TraceManager
{
	private Stack<TraceElement> activeElements;
	
	//  Track number of elements in the stack to indent
	//  the trace file, to highlight its structure.
	private StringBuffer indentBuffer = new StringBuffer();

	private PrintWriter sink;
	
	private boolean enabled = true;

	public TraceManager()
	{
		activeElements = new Stack<TraceElement>();
	}

	public void enable(PrintWriter sink)
	{
		this.sink = sink;
	}
	
	private boolean isEnabled()
	{
		return enabled && sink != null;
	}
	
	public void disable()
	{
		if ( isEnabled() && activeElements.size() > 0 )
			finishCurrentElement();
		enabled = false;
	}
	
	public void enable()
	{
		enabled = true;
	}
	
	public int pushPhase(String phaseName)
	{
		return pushElement(phaseName, false);
	}

	/**
	 * @param elementName -- the name of the new trace element.
	 *     Written as the name of the trace's XML tag.
	 * @param popOnNext -- when set, this is a one-line trace entry.
	 *     When not set, this is a trace phase that may have 
	 *     sub-entries.
	 * @return a trace element stack mark, used to unwind the trace
	 *   when this trace phase finishes.
	 * @see unwind()
	 */
	public int pushElement(String elementName, boolean popOnNext)
	{	
		if ( 0 == activeElements.size() )
			println("<?xml version='1.0' encoding='utf-8' ?>");
		else
			finishCurrentElement();
		
		//  Result must be computed after finishCurrent()
		//  b/c finishCurrent() may change the stack size.
		int result = activeElements.size();
		activeElements.push(new TraceElement(elementName, popOnNext));
		indentBuffer.append(' ');
		
		StringBuffer output = getIndentedBuffer();
		output.append("<");
		output.append(elementName);
		
		print(output.toString());

		return result;
	}
	
	TraceElement popElement()
	{
		TraceElement finished_element = activeElements.pop();
		
		if ( isEnabled() )
		{
			if ( finished_element.hasBody )
			{
				StringBuffer output = getIndentedBuffer();
				output.append("</");
				output.append(finished_element.phaseName);
				output.append(">");
				println(output.toString());
			}
			else
			{
				println("/>");
			}
			
			sink.flush();
		}
		indentBuffer.deleteCharAt(0);
		return finished_element;
	}
	
	private StringBuffer getIndentedBuffer() 
	{
		return new StringBuffer(indentBuffer);
	}
	
	private void finishCurrentElement()
	{
		if ( activeElements.peek().popOnNext )
		{
			popElement();
		}
		else if ( ! activeElements.peek().hasBody )
		{
			println(">");
			activeElements.peek().setHasBody(true);
		}
	}
	
	public void unwind(int mark)
	{
		while ( activeElements.size() > mark)
			popElement();
	}
	
	public void traceEntry(String tagName)
	{
		pushElement(tagName, true);
	}
	public void traceEntry(String tagName, String attrName, String attrValue)
	{
		traceEntry(tagName);
		addAttr(attrName, attrValue);
	}
	
	public void traceEntry(String tagName, String attrValue)
	{
		traceEntry(tagName, "value", attrValue);
	}
	
	public void traceEntry(String tagName, int attrValue)
	{
		traceEntry(tagName, Integer.toHexString(attrValue));
	}

	public void addAttr(String attrName, String attrValue)
	{
		if ( isEnabled() )
		{
			String xml_escaped_value = attrValue.replaceAll("&", "&amp;");
			xml_escaped_value = xml_escaped_value.replaceAll("<", "&lt;");
			//  Should be done, but it makes the -> edge descriptions hard to read
			xml_escaped_value = xml_escaped_value.replaceAll(">", "&gt;");
			xml_escaped_value = xml_escaped_value.replaceAll("\"", "&quot;");
			xml_escaped_value = xml_escaped_value.replaceAll("\r", "\\r");
			print(" " + attrName + "=\"" + xml_escaped_value + "\"");
		}
	}
	
	public void addAttr(String attrName, int attrValue)
	{
		print(" " + attrName + "=\"" + attrValue + "\"");
	}
	
	public void addAttr(String attrName, Object attr)
	{
		if ( isEnabled() )
		{
			String attrValue;
			
			if ( attr != null )
			{
				attrValue = attr.toString();
				if ( attrValue.replaceAll("\\s", "").equals("null") )
				{
					attrValue = "0x" + Integer.toHexString(attr.hashCode());
				}
			}
			else
			{
				attrValue = "null";
			}
	
			addAttr(attrName, attrValue);
		}
	}
	
	void println(String s)
	{
		if ( isEnabled() )
			sink.println(s);
	}
	
	void print(String s)
	{
		if ( isEnabled())
			sink.print(s);
	}
	
	void flush()
	{
		if ( isEnabled() )
			sink.flush();
	}
	
	private class TraceElement
	{
		String phaseName;
		boolean hasBody   = false;
		boolean popOnNext = false;

		TraceElement(String phaseName)
		{
			this.phaseName = phaseName;
		}
		
		TraceElement(String entryName, boolean popOnNext)
		{
			this.phaseName = entryName;
			this.popOnNext = popOnNext;
		}
		
		void setHasBody(boolean has_body)
		{
			this.hasBody = has_body;
		}
	}
}
