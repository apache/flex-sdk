/*
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
 */

package flash.tools.debugger.threadsafe;

import java.io.IOException;
import java.io.Reader;
import java.text.ParseException;

import flash.tools.debugger.expression.IASTBuilder;
import flash.tools.debugger.expression.ValueExp;

/**
 * @author Mike Morearty
 */
public class ThreadSafeASTBuilder extends ThreadSafeDebuggerObject implements IASTBuilder
{
	private final IASTBuilder m_astBuilder;

	/**
	 * @param syncObj
	 */
	public ThreadSafeASTBuilder(Object syncObj, IASTBuilder astBuilder)
	{
		super(syncObj);
		m_astBuilder = astBuilder;
	}

	/**
	 * Wraps an IASTBuilder inside a ThreadSafeASTBuilder. If the passed-in
	 * IASTBuilder is null, then this function returns null.
	 */
	public static ThreadSafeASTBuilder wrap(Object syncObj, IASTBuilder astBuilder) {
		if (astBuilder != null)
			return new ThreadSafeASTBuilder(syncObj, astBuilder);
		else
			return null;
	}

	/*
	 * @see flash.tools.debugger.expression.IASTBuilder#parse(java.io.Reader)
	 */
	public ValueExp parse(Reader in) throws IOException, ParseException
	{
		synchronized (getSyncObject()) {
			return ThreadSafeValueExp.wrap(getSyncObject(), m_astBuilder.parse(in));
		}
	}

}
