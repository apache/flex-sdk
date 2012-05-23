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

package flex2.compiler.mxml;

import java.io.StringWriter;

/**
 * This class is used to track and report the line number during code
 * generation.
 *
 * @author Clement Wong
 */
public final class SourceCodeBuffer extends StringWriter
{
	public SourceCodeBuffer(int initialSize)
	{
		super(initialSize);
	}

	public SourceCodeBuffer()
	{
		this(1024);
	}

	private int currentLine = 1;

	public void write(int c)
	{
		super.write(c);
		if (c == '\n')
		{
			currentLine++;
		}
	}

	public void write(char cbuf[], int off, int len)
	{
		super.write(cbuf, off, len);
		for (int i = off; i < off + len; i++)
		{
			if (cbuf[i] == '\n')
			{
				currentLine++;
			}
		}
	}

	public void write(String str)
	{
		super.write(str);
		for (int i = 0, len = str.length(); i < len; i++)
		{
			if (str.charAt(i) == '\n')
			{
				currentLine++;
			}
		}
	}

	public void write(String str, int off, int len)
	{
		super.write(str, off, len);
		for (int i = off; i < off + len; i++)
		{
			if (str.charAt(i) == '\n')
			{
				currentLine++;
			}
		}
	}

	public int getLineNumber()
	{
		return currentLine;
	}
}
