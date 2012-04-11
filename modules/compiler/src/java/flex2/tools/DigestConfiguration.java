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

import flex2.compiler.config.ConfigurationBuffer;
import flex2.compiler.config.ConfigurationInfo;
import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.io.FileUtil;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

/**
 * Options for the digest tool.
 * 
 * @author dloverin
 */
public class DigestConfiguration 
{
	DigestRootConfiguration root;
	
	public DigestConfiguration(DigestRootConfiguration root)
	{
		this.root = root;
	}
	
     
	public static Map<String, String> getAliases()
    {
        Map<String, String> map = new HashMap<String, String>();
		return map;
    }

	public void validate( ConfigurationBuffer cfgbuf ) throws ConfigurationException
    {
	    String appHome = System.getProperty("application.home");
	    if (appHome == null)
	    {
		    appHome = ".";
	    }
    }

	//
	// 'rsl_file' option
	//
	
	private File rslFile = null;
	
	public File getRslFile()
	{
		return rslFile;
	}
	
    public void cfgRslFile( ConfigurationValue cfgval, String file)
    							throws ConfigurationException
	{
    	if (file == null || file.length() == 0) {
    		// a filename must be supplied
			throw new ConfigurationException.MissingArgument("filename",
															"rsl-file", null, 0);
    	}
		rslFile = FileUtil.openFile(file);
		if (!rslFile.exists()) {
			throw new ConfigurationException.ConfigurationIOError(file, "rsl-file", null, 0);
		}
		
		if (!rslFile.isFile()) {
			throw new ConfigurationException.NotAFile(file, "rsl-file", null, 0);
		}
	}

    
	public static ConfigurationInfo getRslFileInfo()
	{
		return new ConfigurationInfo(new String[] { "filename" })
		{
			public boolean isPath()
			{
				return true;
			}

			public boolean isRequired()
			{
				return true;
			}
		};
	}
	
	
	//
	// 'swc_path' option
	//
	
	private String swcPath = null;
	
	
	public String getSwcPath()
	{
		return swcPath;
	}
	
    public void cfgSwcPath( ConfigurationValue cfgval, String path)
        throws ConfigurationException
	{
    	if (path == null || path.length() == 0) {
    		// a filename must be supplied
			throw new ConfigurationException.MissingArgument("path-element",
															"swc-path", null, 0);
    	}
		swcPath = path;
	}

	public static ConfigurationInfo getSwcPathInfo()
	{
		return new ConfigurationInfo(new String[] { "path-element" })
		{
			public boolean isPath()
			{
				return true;
			}

			public boolean isRequired()
			{
				return true;
			}
		};
	}
	
	//
	// 'signed' option
	//
	
    private boolean signed = false;		// true if the file is signed, false otherwise

    public boolean getSigned()
    {
        return signed;
    }

    public void cfgSigned(ConfigurationValue cv, boolean signed) throws ConfigurationException
    {
        this.signed = signed;
    }

    public static ConfigurationInfo getSignedInfo()
    {
        return new ConfigurationInfo()
        {
			public boolean isHidden()
			{
				return true;
			}
        };
    }
}
