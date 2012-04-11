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

import flex2.compiler.config.ConfigurationInfo;
import flex2.compiler.config.ConfigurationValue;

/**
 * Used to setup the "digest." prefix for the optioins in DigestConfiguration.
 * 
 * @author dloverin
 */
public class DigestRootConfiguration
{
	public DigestRootConfiguration()
	{
        digestConfiguration = new DigestConfiguration(this);
	}
	
	//
    // 'digest.*' options
    //
	
	private DigestConfiguration digestConfiguration;
	
    public DigestConfiguration getDigestConfiguration()
    {
        return digestConfiguration;
    }
   	
	//
	// 'version' option
	//
	
    // dummy, just a trigger for version info
    public void cfgVersion(ConfigurationValue cv, boolean dummy)
    {
        // intercepted upstream in order to allow version into to be printed even when required args are missing
    }

	//
	// 'help' option
	//
	
    // dummy, just a trigger for help text
	public void cfgHelp(ConfigurationValue cv, String[] keywords)
	{
    }

    public static ConfigurationInfo getHelpInfo()
    {
        return new ConfigurationInfo( -1, "keyword" )
        {
            public boolean isGreedy()
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
