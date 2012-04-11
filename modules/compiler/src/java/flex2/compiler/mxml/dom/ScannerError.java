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

/**
 * @author Clement Wong
 */
public class ScannerError extends Error
{
	private static final long serialVersionUID = -619000486885987644L;

    ScannerError(int line, int col, String reason)
	{
		this.line = line;
		this.col = col;
		this.reason = reason;
	}

	private int line;
	private int col;
	private String reason;

	public int getLineNumber()
	{
		return line;
	}

	public int getColumnNumber()
	{
		return col;
	}

	public String getReason()
	{
		return reason;
	}
}
