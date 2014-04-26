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

import java.util.Locale;
import java.util.Map;

import flash.localization.ILocalizedText;
import flash.localization.ILocalizer;
import flash.localization.ResourceBundleLocalizer;

/**
 * An ILocalizer which does a couple of extra things:
 * 
 * <ol>
 * <li> If the requested string is not found, rather than returning <code>null</code>, we
 *      return a default string, to avoid a crash. </li>
 * <li> We replace any "\n" with the current platform's newline sequence. </li>
 * </ol>
 * 
 * @author mmorearty
 */
public class DebuggerLocalizer implements ILocalizer
{
	private ResourceBundleLocalizer m_resourceBundleLocalizer = new ResourceBundleLocalizer();
	private String m_prefix;
	public final static String m_newline = System.getProperty("line.separator"); //$NON-NLS-1$

	public DebuggerLocalizer(String prefix)
	{
		m_prefix = prefix;
	}

	public ILocalizedText getLocalizedText(Locale locale, final String id)
	{
		// We hard-code our package name in here, so that callers can use
		// a short string
		ILocalizedText localizedText = m_resourceBundleLocalizer.getLocalizedText(locale, m_prefix + id);

		// If no ILocalizedText was found, try English
		if (localizedText == null && !Locale.getDefault().getLanguage().equals("en")) //$NON-NLS-1$
		{
			localizedText = m_resourceBundleLocalizer.getLocalizedText(Locale.ENGLISH, m_prefix + id);
		}

		// If still no ILocalizedText was found, create a default one
		if (localizedText == null)
		{
			localizedText = new ILocalizedText()
			{
				public String format(Map parameters)
				{
					StringBuilder sb = new StringBuilder();
					sb.append('!');
					sb.append(id);
					sb.append('!');
					if (parameters != null && !parameters.isEmpty())
					{
						sb.append(' ');
						sb.append(parameters.toString());
					}
					return sb.toString();
				}
			};
		}

		// If the current platform's newline sequence is something other
		// than "\n", then replace all occurrences of "\n" with this platform's
		// newline sequence.
		if (m_newline.equals("\n")) //$NON-NLS-1$
		{
			return localizedText;
		}
		else
		{
			final ILocalizedText finalLocalizedText = localizedText;
			return new ILocalizedText()
			{
				public String format(Map parameters)
				{
					String result = finalLocalizedText.format(parameters);
					return result.replaceAll("\n", m_newline); //$NON-NLS-1$
				}
			};
		}
	}
}
