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

package flex2.compiler.common;

import flex2.compiler.config.AdvancedConfigurationInfo;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.config.ConfigurationInfo;

/**
 * This class handles MXML language specific configuration options.
 * This includes things like compatibility-version,
 * minimum-supported-version, and qualified-type-selectors.  This
 * class should not to be confused with
 * flex2.compiler.mxml.MxmlConfiguration, which is where MXML
 * subcompiler configuration options are declared and
 * flex2.compiler.common.CompilerConfiguration, which is where
 * flex2.compiler.mxml.MxmlConfiguration is defined.
 *
 * @author Clement Wong
 */
public class MxmlConfiguration
{
	private ConfigurationPathResolver configResolver;

	public void setConfigPathResolver( ConfigurationPathResolver resolver )
	{
	    this.configResolver = resolver;
	}

    //
    // 'compiler.mxml.compatibility-version' option
    //
	public static final int VERSION_4_11 = 0x040b0000;
	public static final int VERSION_4_10 = 0x040a0000;
	public static final int VERSION_4_9_1 = 0x04090001;
	public static final int VERSION_4_9 = 0x04090000;
	public static final int VERSION_4_8 = 0x04080000;
	public static final int VERSION_4_6 = 0x04060000;
    public static final int VERSION_4_5 = 0x04050000;
    public static final int VERSION_4_0 = 0x04000000;
    public static final int VERSION_3_0 = 0x03000000;
    public static final int VERSION_2_0_1 = 0x02000001;
    public static final int VERSION_2_0 = 0x02000000;
    public static final int CURRENT_VERSION = VERSION_4_11;
    public static final int EARLIEST_MAJOR_VERSION = 3;
    public static final int LATEST_MAJOR_VERSION = 4;
    public static final int LATEST_MINOR_VERSION = 11;

	private int major = LATEST_MAJOR_VERSION;
	private int minor = LATEST_MINOR_VERSION;
	private int revision;
	
	private int minMajor = EARLIEST_MAJOR_VERSION;
	private int minMinor;
	private int minRevision;

	public int getMajorCompatibilityVersion()
	{
		return major;
	}

	public int getMinorCompatibilityVersion()
	{
		return minor;
	}

	public int getRevisionCompatibilityVersion()
	{
		return revision;
	}

	/*
	 * Unlike the framework's FlexVersion.compatibilityVersionString,
	 * this returns null rather than a string like "3.0.0" for the current version.
	 * But if a -compatibility-version was specified, this string will always
	 * be of the form N.N.N. For example, if -compatibility-version=2,
	 * this string is "2.0.0", not "2".
	 */
	public String getCompatibilityVersionString()
	{
		return (major == 0 && minor == 0 && revision == 0) ? null : major + "." + minor + "." + revision;
	}

	/*
	 * This returns an int that can be compared with version constants
	 * such as MxmlConfiguration.VERSION_3_0.
	 */
	public int getCompatibilityVersion()
	{
		int version = (major << 24) + (minor << 16) + revision;
		return version != 0 ? version : CURRENT_VERSION;
	}
	
	public void cfgCompatibilityVersion(ConfigurationValue cv, String version) throws ConfigurationException
	{
		if (version == null)
		{
			return;
		}
		
		String[] results = version.split("\\.");
		
		if (results.length == 0)
		{
			throw new ConfigurationException.BadVersion(version, "compatibility-version");
		}

		// Set minor and revision numbers to zero in case only a major number
		// was specified, etc.
		this.minor = 0;
		this.revision = 0;

		for (int i = 0; i < results.length; i++)
		{
			int versionNum = 0;
			
			try
			{
				versionNum = Integer.parseInt(results[i]);
			}
			catch (NumberFormatException e)
			{
				throw new ConfigurationException.BadVersion(version, "compatibility-version");				
			}
			
			if (i == 0)
			{
				if (versionNum >= EARLIEST_MAJOR_VERSION && versionNum <= LATEST_MAJOR_VERSION) 
				{
					this.major = versionNum;
				}
				else 
				{
					throw new ConfigurationException.BadVersion(version, "compatibility-version");
				}				
			}
			else 
			{
				if (versionNum >= 0) 
				{
					if (i == 1)
					{
						this.minor = versionNum;						
					}
					else
					{
						this.revision = versionNum;
					}
				}
				else 
				{
					throw new ConfigurationException.BadVersion(version, "compatibility-version");
				}				
			}
		}

        if (major <= 3)
        {
            qualifiedTypeSelectors = false;            
        }
	}

	public static ConfigurationInfo getCompatibilityVersionInfo()
	{
	    return new ConfigurationInfo( new String[] {"version"} );
	}

	/*
	 * Minimum supported SDK version for this library.
	 * This string will always be of the form N.N.N. For example, if 
	 * -minimum-supported-version=2, this string is "2.0.0", not "2".
	 */
	public String getMinimumSupportedVersionString()
	{
		return (minMajor == 0 && minMinor == 0 &&  minRevision == 0) ? 
				null : minMajor + "." + minMinor + "." + minRevision;
	}

	/*
	 * This returns an int that can be compared with version constants
	 * such as MxmlConfiguration.VERSION_3_0.
	 */
	public int getMinimumSupportedVersion()
	{
		int version = (minMajor << 24) + (minMinor << 16) + minRevision;
		return version != 0 ? version : (EARLIEST_MAJOR_VERSION << 24);
	}
	
    public void setMinimumSupportedVersion(int version)
    {
        minMajor = version >> 24 & 0xFF;
        minMinor = version >> 16 & 0xFF;
        minRevision = version & 0xFF;
    }    

	public void cfgMinimumSupportedVersion(ConfigurationValue cv, String version) throws ConfigurationException
	{
		if (version == null)
		{
			return;
		}
		
		String[] results = version.split("\\.");
		
		if (results.length == 0)
		{
			throw new ConfigurationException.BadVersion(version, "minimum-supported-version");

		}
		
		for (int i = 0; i < results.length; i++)
		{
			int versionNum = 0;
			
			try
			{
				versionNum = Integer.parseInt(results[i]);
			}
			catch (NumberFormatException e)
			{
				throw new ConfigurationException.BadVersion(version, "minimum-supported-version");				
			}
			
			if (i == 0)
			{
				if (versionNum >= MxmlConfiguration.EARLIEST_MAJOR_VERSION && versionNum <= MxmlConfiguration.LATEST_MAJOR_VERSION) 
				{
					this.minMajor = versionNum;
				}
				else 
				{
					throw new ConfigurationException.BadVersion(version, "minimum-supported-version");
				}				
			}
			else 
			{
				if (versionNum >= 0) 
				{
					if (i == 1)
					{
						minMinor = versionNum;						
					}
					else
					{
						minRevision = versionNum;
					}
				}
				else 
				{
					throw new ConfigurationException.BadVersion(version, "minimum-supported-version");
				}				
			}
		}

        isMinimumSupportedVersionConfigured = true;
	}
	
    private boolean isMinimumSupportedVersionConfigured = false;

    public boolean isMinimumSupportedVersionConfigured()
    {
        return isMinimumSupportedVersionConfigured;
    }

    //
    // 'qualified-type-selectors' option
    //

    private boolean qualifiedTypeSelectors = true;

    public boolean getQualifiedTypeSelectors()
    {
        if (getCompatibilityVersion() < MxmlConfiguration.VERSION_4_0)
            return false;

        return qualifiedTypeSelectors;
    }

    public void cfgQualifiedTypeSelectors(ConfigurationValue cv, boolean b)
    {
        qualifiedTypeSelectors = b;
    }

    public static ConfigurationInfo getQualifiedTypeSelectorsInfo()
    {
        return new AdvancedConfigurationInfo();
    }
}
