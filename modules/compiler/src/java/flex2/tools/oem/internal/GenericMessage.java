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

package flex2.tools.oem.internal;

import flex2.tools.oem.Message;

/**
 * A generic implementation of Message.
 *
 * @version 2.0.1
 * @author Clement Wong
 */
class GenericMessage implements Message
{
	GenericMessage(Message message)
	{
		this(message.getLevel(), message.getPath(), message.getLine(), message.getColumn(), message.toString());
	}
	
	GenericMessage(String level, String path, int line, int col, String message)
	{
		this.level = level;
		this.path = path;
		this.line = line;
		this.col = col;
		this.message = message;
	}
	
	private String level, path, message;
	private int line, col;
	
	public int getColumn()
	{
		return col;
	}

	public String getLevel()
	{
		return level;
	}

	public int getLine()
	{
		return line;
	}

	public String getPath()
	{
		return path;
	}
	
	public String toString()
	{
		return message;
	}
}
