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

package flash.tools.debugger;

import java.util.HashMap;
import java.util.Map;

/**
 * NoResponseException is thrown when the Player does
 * not respond to the command that was issued.
 * 
 * The field m_waitedFor contains the number of
 * milliseconds waited for the response.
 */
public class NoResponseException extends PlayerDebugException
{
	private static final long serialVersionUID = -3704426811630352537L;
    
    /**
	 * Number of milliseconds that elapsed causing the timeout
	 * -1 means unknown.
	 */
	public int m_waitedFor;

	public NoResponseException(int t) 
	{
		m_waitedFor = t;
	}

	@Override
	public String getMessage()
	{
		Map<String, String> args = new HashMap<String, String>();
		String formatString;
		if (m_waitedFor != -1 && m_waitedFor != 0)
		{
			formatString = "timeout"; //$NON-NLS-1$
			args.put("time", Integer.toString(m_waitedFor)); //$NON-NLS-1$
		}
		else
		{
			formatString = "timeoutAfterUnknownDelay"; //$NON-NLS-1$
		}
		return Bootstrap.getLocalizationManager().getLocalizedTextString(formatString, args);
	}
}
