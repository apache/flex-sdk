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

import java.util.HashMap;
import java.util.Map;

import flex2.compiler.common.Configuration;
import flex2.compiler.config.ConfigurationBuffer;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.config.ConfigurationInfo;
import flex2.compiler.config.ConfigurationValue;
import flex2.tools.CompcConfiguration;

/**
 * A configuration that extends CompcConfiguration by adding options
 * for -loadConfig and -compute-digest.
 *
 * @version 2.0.1
 * @author Clement Wong
 */
public class LibraryCompilerConfiguration extends CompcConfiguration
{
    static
    {
        outputRequired = false;
    }

	public static Map<String, String> getAliases()
    {
        Map<String, String> map = new HashMap<String, String>();
	    map.putAll(Configuration.getAliases());
	    map.remove("o");
		return map;
    }

    protected void validateSwcInputs() throws ConfigurationException
    {
        // Skip validating the inputs, because they are provided via the OEM API.
    }

    //
    // 'generate-link-report' option
    //
    
	private boolean generateLinkReport;
	
	public boolean generateLinkReport()
	{
		return generateLinkReport || super.generateLinkReport();
	}

	public void keepLinkReport(boolean b)
	{
		generateLinkReport = b;
	}
	
    //
    // 'generate-size-report' option
    //
    
	private boolean generateSizeReport;
	
	public boolean generateSizeReport()
	{
		return generateSizeReport || super.generateSizeReport();
	}

	public void keepSizeReport(boolean b)
	{
		generateSizeReport = b;
	}

    //
    // 'load-config' option
    //
    
    // dummy, ignored - pulled out of the buffer
    public void cfgLoadConfig(ConfigurationValue cv, String filename) throws ConfigurationException
    {
    }

    public static ConfigurationInfo getLoadConfigInfo()
    {
        return new ConfigurationInfo( 1, "filename" )
        {
            public boolean allowMultiple()
            {
                return true;
            }
        };
    }
    
	//
	// compute-digest option
	//
	
	private boolean computeDigest = true;
	
	public boolean getComputeDigest()
	{
		return computeDigest;
	}
	
	/**
	 * compute-digest option
	 * 
	 * @param cv
	 * @param b
	 */
	public void cfgComputeDigest(ConfigurationValue cv, boolean b)
	{
		computeDigest = b;
	}
}
