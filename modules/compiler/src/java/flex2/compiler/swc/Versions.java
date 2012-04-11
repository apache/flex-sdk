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

package flex2.compiler.swc;

/**
 * The features enabled for a SWC.
 *
 * @author Brian Deitte
 */
public class Versions
{
    private String libVersion;
    private String flexVersion;
    private String flexBuild;
    private String minimumVersion;
    
    public String getLibVersion()
    {
        return libVersion;
    }

    public void setLibVersion(String libVersion)
    {
        this.libVersion = libVersion;
    }

    public String getFlexVersion()
    {
        return flexVersion;
    }

    public void setFlexVersion(String flexVersion)
    {
        this.flexVersion = flexVersion;
    }

    public String getFlexBuild()
    {
        return flexBuild;
    }

    public void setFlexBuild(String flexBuild)
    {
        this.flexBuild = flexBuild;
    }
    
    public String getMinimumVersionString()
    {
        return minimumVersion;
    }

    public void setMinimumVersion(String libVersion)
    {
        this.minimumVersion = libVersion;
    }
    
    public int getMinimumVersion()
    {
        if (minimumVersion != null)
        {
            String[] results = minimumVersion.split("\\.");
            if (results.length >= 3)
            {
                int major = Integer.parseInt(results[0]);
                int minor = Integer.parseInt(results[1]);
                int revision = Integer.parseInt(results[2]);
                return (major << 24) + (minor << 16) + revision;
            }
        }
        return 0;
    }
}
