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

import flash.util.Trace;

import java.io.InputStream;
import java.io.IOException;
import java.util.Properties;

/**
 * A helper class for querying build number, Flex version, and library
 * version information.
 */
public class VersionInfo
{
    public static String FLEX_MAJOR_VERSION = "4";
    public static String FLEX_MINOR_VERSION = "10";
    public static String FLEX_NANO_VERSION  = "0";
    
	/**
	 * Lib version is the "version" of the SWC format. Major number changes represent big (although not
	 * by definition incompatble) changes, such as bytecode format revs. Minor number changes are intended
	 * to represent easy-to-support modifications. The only universal rule is that the compiler will warn
	 * when a "future" major version is found in a SWC that's being read in.
	 *
	 * It's expected that incompatible changes will arise. Ad-hoc guard code will be added to implement those
	 * dividing lines. The way the code is currently laid out, these would probably be implemented in Swc.read(),
	 * but in any case they should be finable by looking at the callers of VersionInfo.getLibVersion().
	 *
     * <li>
     * Version 1.2: Add &lt;keep-as3-metadata&gt; container to catalog.xml to perserve metadata
     * </li>
	 * <li>
	 * Version 1.1: Add &lt;digest&gt; container to catalog xml for cross-domain rsls support.
	 * 		        Add "signatureChecksum" attribute to "script" element.
     * 
	 * </li>
	 * <li>
	 * Version 1.0: Initial version.
	 * </li>
	 * 
	 */
    public static String LIB_VERSION_1_0 = "1.0";
    public static String LIB_VERSION_1_1 = "1.1";
    public static String LIB_VERSION_1_2 = "1.2";
    
	public static String LIB_MAJOR_VERSION = "1";
	public static String LIB_MINOR_VERSION = "2";

	//Cache this info as it should not change during the time class is loaded
    static String BUILD_MESSAGE;
    static String BUILD_NUMBER_STRING;
	static String FLEX_VERSION_NUMBER;
	static String LIB_VERSION_NUMBER;

	public static String buildMessage()
    {
        if (BUILD_MESSAGE == null)
        {
            try
            {
                //Ensure we've parsed build info
                getBuild();

                String buildNum = BUILD_NUMBER_STRING;
                if (buildNum == null || buildNum.equals(""))
                {
                    buildNum = "development";
                }

                BUILD_MESSAGE = "Version " + FLEX_MAJOR_VERSION + "." + FLEX_MINOR_VERSION +
                         "." + FLEX_NANO_VERSION + " build " + buildNum;
            }
            catch (Throwable t)
            {
                if (Trace.error)
                {
                    t.printStackTrace();
                }
                BUILD_MESSAGE = "build information unavailable";
            }
        }

        return BUILD_MESSAGE;
    }

    public static String getBuild()
    {
        if (BUILD_NUMBER_STRING == null)
        {
            BUILD_NUMBER_STRING = "";

            InputStream in = null;
            try
            {
                Properties p = new Properties();
                in = VersionInfo.class.getResourceAsStream("version.properties");

                if (in != null)
                {
                    p.load(in);                
                    String build = p.getProperty("build");
                    if ((build != null) && (! build.equals("")))
                    {
                        // In open source builds the build number has changed from an
                        // integer to a string of dot separated integers.
                        // for example: 191195 -> 3.0.0.97
                        int dot_index = build.lastIndexOf(".");
                        if (dot_index != -1) 
                        {
                            build = build.substring(dot_index + 1);
                        }
                        BUILD_NUMBER_STRING = build;
                    }
                }
            }
            catch (Throwable t)
            {
                if (Trace.error)
                {
                    t.printStackTrace();
                }
            }
            finally
            {
                if (in != null)
                {
                    try
                    {
                        in.close();
                    }
                    catch (IOException ex)
                    {
                    }
                }
            }
        }

        return BUILD_NUMBER_STRING;
    }

	public static String getFlexVersion()
	{
	    if (FLEX_VERSION_NUMBER == null)
	    {
	    	FLEX_VERSION_NUMBER = FLEX_MAJOR_VERSION + "." + FLEX_MINOR_VERSION +
                                  "." + FLEX_NANO_VERSION;
	    }
	    return FLEX_VERSION_NUMBER;
	}

	public static String getLibVersion()
	{
	    if (LIB_VERSION_NUMBER == null)
	    {
	    	LIB_VERSION_NUMBER = LIB_MAJOR_VERSION + "." + LIB_MINOR_VERSION;
	    }
	    return LIB_VERSION_NUMBER;
	}
	
	
	/**
	 * 
	 * @param swcLibVersion - library version to compare with the current library version.
	 * @param compareMajorVersion - if true, compare only the major versions. Otherwise compare 
	 * 								both major and minor versions.
	 * @return true if the given library version is greater than the compiled in library version. 
	 */
	public static boolean IsNewerLibVersion(String swcLibVersion, boolean compareMajorVersion)
	{
        return compareVersions(swcLibVersion, getLibVersion(), compareMajorVersion) > 0;
	}
    

    /**
     * Compare two version strings that are in at "Major.minor" format.
     * 
     * Examples) "1.0", "1.1"
     * 
     * @param version1 first version
     * @param version2 second version
     * @param compareMajorVersion compare only the major versions, disregarding the minor version.
     * 
     * @return zero if the versions are equal 
     *         less than zero if version1 is less than version2 
     *         greater than zero if version1 is greater than version2
     */
    public static int compareVersions(String version1, String version2,  boolean compareMajorVersion)
    {
        // C: change this implementation if the lib version changes from the a.b format to the a.b.c. format.
        //    Obviously, a.b.c is not a number!
        
        double v1 = 0, v2 = 0;

        try
        {
            v1 = Double.parseDouble(version1);
        }
        catch (NumberFormatException ex)
        {
            if (Trace.error)
            {
                ex.printStackTrace();
            }
        }

        try
        {
            v2 = Double.parseDouble(version2);
        }
        catch (NumberFormatException ex)
        {
            if (Trace.error)
            {
                ex.printStackTrace();
            }
        }
        
        if (compareMajorVersion) 
        {
            v1 = Math.floor(v1);
            v2 = Math.floor(v2);
        }
        
        if (v1 == v2) 
        {
            return 0;
        }
        else if (v1 < v2)
        {
            return -1;
        }
            
        return 1;
    }
}
