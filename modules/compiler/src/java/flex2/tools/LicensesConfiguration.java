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

import flex2.compiler.config.ConfigurationException;
import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.config.ConfigurationInfo;
import java.util.HashMap;
import java.util.Map;

/**
 * A sub-configuration of ToolsConfiguration.
 *
 * @see flex2.tools.ToolsConfiguration
 * @author Paul Reilly
 */
public class LicensesConfiguration
{
    //
	//  'license' option
	//
	
	private Map<String, String> licenseMap;

    public Map<String, String> getLicenseMap()
    {
        return licenseMap;
    }
    
   public void setLicenseMap(Map<String, String> m)
    {
    	licenseMap = m;
    }
    
    public void cfgLicense( ConfigurationValue cfgval, String product, String serialNumber)
        throws ConfigurationException
    {
        if (licenseMap == null)
        {
            licenseMap = new HashMap<String, String>();
        }

        licenseMap.put(product, serialNumber);
    }

    public static ConfigurationInfo getLicenseInfo()
    {
        return new ConfigurationInfo( new String[] {"product", "serial-number"} )
        {
            public boolean allowMultiple()
            {
                return true;
            }
            
            public boolean isDisplayed()
            {
            	return false;
            }
        };
    }
}
