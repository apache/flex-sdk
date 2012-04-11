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

import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import flex2.compiler.config.ConfigurationException;
import flex2.compiler.config.ConfigurationInfo;
import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.io.VirtualFile;

/**
 *  Configuration options association with the 
 *  runtime-shared-library-path option.
 *  
 *  @author dloverin
 *
 */
public class RuntimeSharedLibrarySettingsConfiguration
{
    
    private Configuration configuration;
    
    public RuntimeSharedLibrarySettingsConfiguration(Configuration configuration)
    {
        this.configuration = configuration;
    }

    
    protected ConfigurationPathResolver configResolver;

    public void setConfigPathResolver( ConfigurationPathResolver resolver )
    {
        this.configResolver = resolver;
    }

    // 
    // 'force-rsl' option
    //
    private Set<VirtualFile> forceRsls;
    
    /**
     * Get the array of SWCs that should have their RSLs loaded, even if
     * the compiler detects no classes being used from the SWC.
     * @return Array of SWCs that should have their RSLs loaded.
     */
    public VirtualFile[] getForceRsls() 
    {
        if (forceRsls == null)
        {
            return new VirtualFile[0];
        }
        
        return forceRsls.toArray(new VirtualFile[0]);
    }
    
    /**
     * Get the SWCs that are forced to load RSLs as a set of paths.
     * 
     * @return a set of SWC paths.
     */
    public Set<String> getForceRslsPaths() 
    {
        if (forceRsls == null)
        {
            return Collections.emptySet();
        }
        
        Set<String> rslPaths = new HashSet<String>();
        for (VirtualFile file : forceRsls)
        {
            rslPaths.add(file.getName());
        }
        
        return rslPaths;
    }

    
    public void cfgForceRsls(ConfigurationValue cfgval, 
            String[] args)  throws ConfigurationException
    {
        // ignore the force option if we are static linking
        if (configuration.getStaticLinkRsl())
            return;
        
        if (forceRsls == null)
        {
            forceRsls = new HashSet<VirtualFile>();
        }
 
        // Add swc to the forceRsls set.
        for (String arg : args)
        {
            // path-element parameter (swc)
            // verify path exists and the swc has an
            // existing -rslp option specified.
            VirtualFile swcFile = ConfigurationPathResolver.getVirtualFile(arg, configResolver, cfgval);
            String swcPath = swcFile.getName();

            // verify the swc is used in an the RSL configuration.
            if (!doesSwcHaveRSLInfo(swcPath))
            {
                throw new ConfigurationException.SwcDoesNotHaveRslData(swcPath, 
                              cfgval.getVar(), cfgval.getSource(), cfgval.getLine());
            }

            forceRsls.add(swcFile);
        }
    }
    
    public static ConfigurationInfo getForceRslsInfo()
    {
        return new ConfigurationInfo(-1, new String[] {"path-element"})
        {
            public boolean allowMultiple()
            {
                return true;
            }

            public boolean isAdvanced()
            {
                return true;
            }
        };
    }

    // 
    // 'application-domain' option
    //
    
    /**
     *  Enum of the supported application domain targets of an RSL. The string
     *  values represent the valid values that may specified for the 
     *  application-domain option.
     */
    public static enum ApplicationDomainTarget 
    {
        DEFAULT("default"),
        CURRENT("current"),
        PARENT("parent"),
        TOP_LEVEL("top-level");
 
        private String applicationDomainValue;

        private ApplicationDomainTarget( String applicationDomainValue )
        {
            this.applicationDomainValue = applicationDomainValue;
        }

        public String getApplicationDomainValue()
        {
            return applicationDomainValue;
        }
         
    }
    
    /*
     * Key: swc file path; Value: application domain
     */
    private HashMap<VirtualFile,String> applicationDomains;

    /**
     * Get the application domain an RSL should be loaded into. The default is
     * the current application domain but the user can override this setting.
     * @param swcPath The full path of the swc file.
     * 
     * @return The application domain the RSL should be loaded into. If the 
     * swc is not found, then 'default' is returned.
     */
    public String getApplicationDomain(String swcPath) 
    {
        if (applicationDomains == null || swcPath == null)
        {
            return ApplicationDomainTarget.DEFAULT.applicationDomainValue;
        }
        
        for (Map.Entry<VirtualFile, String> entry : applicationDomains.entrySet())
        {
            VirtualFile swcFile = entry.getKey();
            if (swcFile.getName().equals(swcPath))
            {
                return entry.getValue();
            }
        }

        return ApplicationDomainTarget.DEFAULT.applicationDomainValue;
    }
    
    /**
     * Get the HashMap of any applicationDomain overrides for RSL loading.  
     * 
     * @return Map, key: SWC file path, value: on of application domain strings.
     */
    public Map<VirtualFile,String> getApplicationDomains() 
    {
        if (applicationDomains == null)
        {
            return Collections.emptyMap();
        }
        
        return applicationDomains;
    }

    
    public void cfgApplicationDomain(ConfigurationValue cfgval, 
            String[] args)  throws ConfigurationException
    {
        // ignore the force option if we are static linking
        if (configuration.getStaticLinkRsl())
            return;
        
        if (applicationDomains == null)
        {
            applicationDomains = new HashMap<VirtualFile,String>();
        }
 
        // Add swc and application domain target to the map.
        // The args are: swc file path, application domain type, ...
        for (int i = 0; i < args.length; i++)
        {
            String arg = args[i++];
            
            // path-element parameter (swc)
            // verify path exists and the swc has an
            // existing -rslp option specified.
            VirtualFile swcFile = ConfigurationPathResolver.getVirtualFile(arg, configResolver, cfgval);
            String swcPath = swcFile.getName();

            // verify the swc is used in an the RSL configuration.
            if (!doesSwcHaveRSLInfo(swcPath))
            {
                throw new ConfigurationException.SwcDoesNotHaveRslData(swcPath, 
                              cfgval.getVar(), cfgval.getSource(), cfgval.getLine());
            }

            // Verify the application domain target is valid.
            arg = args[i];
            if (!isValidApplicationDomainTarget(arg))
            {
                // throw a configuration exception that the application domain 
                // type is incorrect.
                throw new ConfigurationException.BadApplicationDomainValue(swcPath, arg, cfgval.getVar(), 
                        cfgval.getSource(), cfgval.getLine());
            }
            
            applicationDomains.put(swcFile, arg);
        }
    }
    
    public static ConfigurationInfo getApplicationDomainInfo()
    {
        return new ConfigurationInfo(-1, new String[] {"path-element", "application-domain-target"})
        {
            public boolean allowMultiple()
            {
                return true;
            }

            public boolean isAdvanced()
            {
                return true;
            }
            
            public String getArgName(int argnum)
            {
                String argName = null;
                
                argnum = argnum % 2;
                if (argnum == 0)
                {
                    argName = "path-element";
                }
                else 
                {
                    argName = "application-domain-target";
                }
                return argName;
            }
            
            
        };
    }

    /**
     * Check if the SWC has any RSL info associated with it.
     * @param swcPath 
     * @return true if the swc has RSL info, false otherwise.
     */
    private boolean doesSwcHaveRSLInfo(String swcPath)
    {
        if (swcPath == null)
            return false;
        
        List<Configuration.RslPathInfo> rslInfoList = configuration.getRslPathInfo();
        for (Configuration.RslPathInfo rslInfo : rslInfoList)
        {
            if (swcPath.equals(rslInfo.getSwcVirtualFile().getName()))
                return true;
        }
        
        return false;
    }

    /**
     * Test if the specified parameter is a valid application domain type.
     * @param arg
     * @return true if parameter is a valid application domain type, false otherwise.
     */
    private boolean isValidApplicationDomainTarget(String arg) 
    {
        for (ApplicationDomainTarget appDomain : ApplicationDomainTarget.values())
        {
            if (appDomain.applicationDomainValue.equals(arg))
                return true;
        }
        
        return false;
    }
    
}
