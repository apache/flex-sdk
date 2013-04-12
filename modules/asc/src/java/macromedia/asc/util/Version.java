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

package macromedia.asc.util;

import java.io.InputStream;
import java.io.IOException;
import java.util.Properties;

/**
 * Version information for the asc tool.
 */
public class Version
{
    private static final String VERSION = "1.0";

    /**
     * The version string displayed in the asc help.
     */
    public static String getVersion()
    {
        return VERSION;
    }

    /**
     * The build string displayed in the asc help.
     */
    public static String getBuild()
    {
        String build = "cyclone";

        // Read the build number out of the version.properties file.
        InputStream in = null;
        try
        {
            in = Version.class.getResourceAsStream("version.properties");
            if (in != null)
            {
                Properties p = new Properties();
                p.load(in);                
                build = p.getProperty("build");
            }
        }
        catch (Throwable t)
        {
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

        return build;
    }
}
