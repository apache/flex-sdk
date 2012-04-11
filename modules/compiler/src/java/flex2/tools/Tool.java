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

package flex2.tools;

import flash.localization.LocalizationManager;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.compiler.util.CompilerMessage.CompilerError;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.io.FileInputStream;
import java.io.IOException;

/**
 * Common base class for most flex tools.
 */
public class Tool
{
    public static Map<String, String> getLicenseMapFromFile(String fileName) throws ConfigurationException
    {
        Map<String, String> result = null;
        FileInputStream in = null;

        try
        {
            in = new FileInputStream(fileName);
            Properties properties = new Properties();
            properties.load(in);
            Enumeration enumeration = properties.propertyNames();

            if ( enumeration.hasMoreElements() )
            {
                result = new HashMap<String, String>();

                while ( enumeration.hasMoreElements() )
                {
                    String propertyName = (String) enumeration.nextElement();
                    result.put(propertyName, properties.getProperty(propertyName));
                }
            }
        }
        catch (IOException ioException)
        {
        	LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
            throw new ConfigurationException(l10n.getLocalizedTextString(new FailedToLoadLicenseFile(fileName)));
        }
        finally
        {
            if (in != null)
            {
                try
                {
                    in.close();
                }
                catch (IOException ioe)
                {
                }
            }
        }

        return result;
    }

    public static class FailedToLoadLicenseFile extends CompilerError
	{
		private static final long serialVersionUID = -2980033917773108328L;
        
        public String fileName;

		public FailedToLoadLicenseFile(String fileName)
		{
			super();
			this.fileName = fileName;
		}
	}
}
