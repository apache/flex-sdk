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

package flex2.compiler.config;

import java.util.Properties;
import java.util.Enumeration;
import java.util.List;
import java.util.LinkedList;
import java.util.StringTokenizer;

/**
 * A utility class, which is used to load configuration options via
 * system properties and populate a ConfigurationBuffer.  A
 * counterpart of CommandLineConfigurator and FileConfigurator.
 *
 * @author Roger Gonzalez
 */
public class SystemPropertyConfigurator
{
    /**
     * Opportunistically find some configuration settings in system properties.
     * @param buffer the intermediate config buffer
     * @param prefix an optional prefix to add to the variable, pass null if no prefix
     * @throws ConfigurationException
     */
    public static void load( final ConfigurationBuffer buffer, String prefix ) throws ConfigurationException
    {
        try
        {
            Properties props = System.getProperties();

            for (Enumeration e = props.propertyNames(); e.hasMoreElements();)
            {
                String propname = (String) e.nextElement();

                if (!propname.startsWith( prefix + "."))
                {
                    String value = System.getProperty( propname );
                    buffer.setToken( propname, value );
                    continue;
                }

                String varname = propname.substring( prefix.length() + 1 );

                if (!buffer.isValidVar( varname ))
                    continue;

                String value = System.getProperty( propname );

                List<String> args = new LinkedList<String>();
                StringTokenizer t = new StringTokenizer( value, "," );

                while (t.hasMoreTokens())
                {
                    String token = t.nextToken();
                    args.add( token );
                }
                buffer.setVar( varname, args, "system properties", -1 );
            }
        }
        catch (SecurityException se)
        {
            // just ignore, this is an optional for loading configuration   
        }
    }
}
