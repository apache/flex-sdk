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

import java.io.InputStream;

import flash.tools.debugger.SourceLocator;

/**
 * @author Mike Morearty
 */
public class ThreadSafeSourceLocator extends ThreadSafeDebuggerObject implements SourceLocator
{
	private SourceLocator fSourceLocator;
	
	/**
	 * @param syncObj
	 */
	public ThreadSafeSourceLocator(Object syncObj, SourceLocator sourceLocator)
	{
		super(syncObj);
		fSourceLocator = sourceLocator;
	}

	/**
	 * Wraps a SourceLocator inside a ThreadSafeSourceLocator.  If the passed-in SourceLocator
	 * is null, then this function returns null.
	 */
	public static ThreadSafeSourceLocator wrap(Object syncObj, SourceLocator sourceLocator) {
		if (sourceLocator != null)
			return new ThreadSafeSourceLocator(syncObj, sourceLocator);
		else
			return null;
	}

	/* (non-Javadoc)
	 * @see flash.tools.debugger.SourceLocator#locateSource(java.lang.String, java.lang.String, java.lang.String)
	 */
	public InputStream locateSource(String arg0, String arg1, String arg2)
	{
		synchronized (getSyncObject()) {
			return fSourceLocator.locateSource(arg0, arg1, arg2);
		}
	}

	/* (non-Javadoc)
	 * @see flash.tools.debugger.SourceLocator#getChangeCount()
	 */
	public int getChangeCount()
	{
		synchronized (getSyncObject()) {
			return fSourceLocator.getChangeCount();
		}
	}
}
