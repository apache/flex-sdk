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

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import flash.localization.LocalizationManager;
import flash.localization.ResourceBundleLocalizer;
import flash.localization.XLRLocalizer;
import flash.util.Trace;
import flex2.compiler.CompilerAPI;
import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.common.Configuration;
import flex2.compiler.common.DefaultsConfigurator;
import flex2.compiler.config.ConfigurationBuffer;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.config.ConfigurationInfo;
import flex2.compiler.config.ConfigurationValue;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.swc.SwcException;
import flex2.compiler.util.SwcDependencyInfo;
import flex2.compiler.util.SwcDependencyUtil;
import flex2.compiler.util.SwcExternalScriptInfo;
import flex2.compiler.util.ThreadLocalToolkit;


/**
 * SwcDependencies is the entry point for a command line tool to list a set of SWC dependencies on each other.
 * 
 * This tool accepts all the command line options that mxmlc does but only uses the options to gather SWCs, it does 
 * not modify the file system in any way.
 * 
 * @author dloverin
 *
 */
public class SwcDependencies extends Tool
{
    public static void main(String[] args)
    {
        swcDependencies(args);
        System.exit(ThreadLocalToolkit.errorCount());
    }

    public static void swcDependencies(String[] args)
    {
        try
        {
            CompilerAPI.useAS3();

            // setup the path resolver
            CompilerAPI.usePathResolver();

            // set up for localizing messages
            LocalizationManager l10n = new LocalizationManager();
            l10n.addLocalizer( new XLRLocalizer() );
            l10n.addLocalizer( new ResourceBundleLocalizer() );
            ThreadLocalToolkit.setLocalizationManager(l10n);

            // setup the console logger. the configuration parser needs a logger.
            CompilerAPI.useConsoleLogger();

            // process configuration
            ConfigurationBuffer cfgbuf = new ConfigurationBuffer(DependencyRootConfiguration.class, Configuration.getAliases());
            DefaultsConfigurator.loadDefaults( cfgbuf );

            DependencyRootConfiguration configuration = (DependencyRootConfiguration) Mxmlc.processConfiguration(
                        l10n, "swcdepends", args, cfgbuf, DependencyRootConfiguration.class, "no-default-arg");

            // well, setup the logger again now that we know configuration.getWarnings()???
            CompilerAPI.useConsoleLogger(true, true, configuration.getWarnings(), true);
            CompilerAPI.setupHeadless(configuration);

            CompilerConfiguration compilerConfig = configuration.getCompilerConfiguration();
            VirtualFile[] virtualFiles = new VirtualFile[0];
            
            VirtualFile[] moreFiles = compilerConfig.getLibraryPath();
            if (moreFiles != null)
                virtualFiles = moreFiles;   // first one, just assign reference

            moreFiles = Configuration.getAllExcludedLibraries(compilerConfig, configuration);
            if (moreFiles != null)
                virtualFiles = (VirtualFile[])CompilerConfiguration.merge(virtualFiles, moreFiles, VirtualFile.class);

            moreFiles = compilerConfig.getThemeFiles();
            if (moreFiles != null)
            {
                // remove the css files and keep the swcs
                List<VirtualFile> themeSwcs = new ArrayList<VirtualFile>(moreFiles.length); 
                for (int i = 0; i < moreFiles.length; i++)
                {
                    if (moreFiles[i].getName().endsWith(".swc"))
                        themeSwcs.add(moreFiles[i]);
                }
                
                if (themeSwcs.size() > 0)
                    virtualFiles = (VirtualFile[])CompilerConfiguration.merge(virtualFiles, 
                                                          themeSwcs.toArray(new VirtualFile[themeSwcs.size()]), 
                                                          VirtualFile.class);
            }

            moreFiles = compilerConfig.getIncludeLibraries();
            if (moreFiles != null)
                virtualFiles = (VirtualFile[])CompilerConfiguration.merge(virtualFiles, moreFiles, VirtualFile.class);
            
            DependencyConfiguration dependencyConfig = configuration.getDependencyConfiguration();
            List<String> types = dependencyConfig.getDesiredScriptDependencyTypes();
            SwcDependencyInfo depInfo = SwcDependencyUtil.getSwcDependencyInfo(virtualFiles, 
                                                                               types.size() == 0 ? null : 
                                                                               types.toArray(new String[types.size()]),
                                                                               dependencyConfig.getMinimizeDependencySet());
            List<String> depOrder = depInfo.getSwcDependencyOrder();
            List<String> showSwcs = dependencyConfig.getShowSwcs();
            
            // list the swc dependencies
            for (String swcLocation : depOrder)
            {
                // filter the swcs that are shown
                if (showSwcs.size() != 0)
                {
                    boolean skip = true;
                    for (String showSwc : showSwcs)
                    {
                        if (swcLocation.equals(showSwc) || swcLocation.endsWith(showSwc))
                        {
                            skip = false;
                            break;
                        }
                    }
                    
                    if (skip)
                        continue;
                }
                
                System.out.println(swcLocation + ":");

                // list of swc dependencies on swcLocation
                Set<String> depends = depInfo.getDependencies(swcLocation);
                for (String swcDepName : depends)
                {
                    System.out.println("\t" + swcDepName);
                  
                    // list the external scripts that caused the dependencies between
                    // swcLocation and swcDepName.
                    if (dependencyConfig.getShowExterns())
                    {
                        SwcExternalScriptInfo swcExternalScriptInfo = depInfo.getSwcExternalScriptInfo(swcLocation); 
                        for (String externalScriptName : swcExternalScriptInfo.getExternalScripts(swcDepName)) 
                        {
                            if (dependencyConfig.getShowTypes())
                            {
                                System.out.print("\t\t" + externalScriptName + "\t");
                                
                                for (String type : swcExternalScriptInfo.getScriptDependencyTypes(externalScriptName))
                                {
                                    System.out.print(type + " ");
                                }
                                
                                System.out.println();
                            }
                            else
                                System.out.println("\t\t" + externalScriptName);
                           
                        }
                    }
                }
            }
        }
        catch (ConfigurationException ex)
        {
            Mxmlc.processConfigurationException(ex, "swcdepends");
        }
        catch (SwcException ex)
        {
            assert ThreadLocalToolkit.errorCount() > 0;
        }
        catch (Throwable t) // IOException, Throwable
        {
            ThreadLocalToolkit.logError(t.getLocalizedMessage());
            if (Trace.error)
            {
                t.printStackTrace();
            }
        }
        finally
        {
            CompilerAPI.removePathResolver();
        }
    }


     /**
      * Used to setup the "dependency." prefix for the options in DependencyConfiguration.
      * 
      */
     public static class DependencyRootConfiguration extends CommandLineConfiguration
     {
         public DependencyRootConfiguration()
         {
             dependencyConfiguration = new DependencyConfiguration();
         }
         
         /*
          * Since we are filtering out a lot of command line options, we need to override validate to 
          * keep it from throwing an exception.
          * 
          * (non-Javadoc)
          * @see flex2.tools.CommandLineConfiguration#validate(flex2.compiler.config.ConfigurationBuffer)
          */
         public void validate(ConfigurationBuffer cfgbuf) throws ConfigurationException
         {
             try 
             {
                 super.validate(cfgbuf);
             }
             catch (ConfigurationException.MustSpecifyTarget e)
             {
                 // eat this error so we can run swcdepends without any args.
             }
         }
         
         //
         // 'dependency.*' options
         //
         
         private DependencyConfiguration dependencyConfiguration;
         
         public DependencyConfiguration getDependencyConfiguration()
         {
             return dependencyConfiguration;
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
     
     
    /**
     * dependency.* configuration options
     *
     */
    public static class DependencyConfiguration 
    {

        //
        // 'show-external-classes' option
        //
        //  Should we show the external scripts
        //
        
        private boolean showExterns = false;

        public boolean getShowExterns()
        {
            return showExterns;
        }

        public void cfgShowExternalClasses(ConfigurationValue cv, boolean showExterns) throws ConfigurationException
        {
            this.showExterns = showExterns;
        }

        public static ConfigurationInfo getShowExternalClassesInfo()
        {
            return new ConfigurationInfo();
        }
        
        //
        // 'show-types' option
        //
        //  Should we show the external scripts
        //
        
        private boolean showTypes = false;

        public boolean getShowTypes()
        {
            return showTypes;
        }

        public void cfgShowTypes(ConfigurationValue cv, boolean showTypes) throws ConfigurationException
        {
            this.showTypes = showTypes;
            
            // if showTypes is set, then turn on show-external-classes show the types will be seen.
            if (showTypes)
                showExterns = true;
        }

        public static ConfigurationInfo getShowTypesInfo()
        {
            return new ConfigurationInfo()
            {
                public String[] getSoftPrerequisites()
                {
                    return new String[] { "show-external-classes" };
                }
            };
        }
        
        //
        // 'types' option
        //
        
        private List<String> desiredTypes = new LinkedList<String>();
        
        public List<String> getDesiredScriptDependencyTypes()
        {
            return desiredTypes;
        }
        
        public void cfgTypes( ConfigurationValue cfgval, String[] types ) throws ConfigurationException
        {
            for (int i = 0; i < types.length; ++i)
            {
                desiredTypes.add( types[i] );
            }
        }

        public static ConfigurationInfo getTypesInfo()
        {
            return new ConfigurationInfo( -1, new String[] { "type" } )
            {
                public boolean allowMultiple()
                {
                    return true;
                }
            };
        }
        
        
        //
        // 'show-swcs' option
        //
        //  Filter which SWCs to show.
        //
        
        private List<String> showSwcs = new LinkedList<String>();
        
        public List<String> getShowSwcs()
        {
            return showSwcs;
        }
        
        public void cfgShowSwcs( ConfigurationValue cfgval, String[] swcs ) throws ConfigurationException
        {
            for (int i = 0; i < swcs.length; ++i)
            {
                showSwcs.add( swcs[i] );
            }
        }

        public static ConfigurationInfo getShowSwcsInfo()
        {
            return new ConfigurationInfo( -1, new String[] { "swc-name" } )
            {
                public boolean allowMultiple()
                {
                    return true;
                }
            };
        }

        
        //
        // 'minimize-dependency-set' option
        //
        //  Removes a SWC from the dependency set if the scripts resolved in a SWC are a subset of the scripts resolved in another dependent SWC.
        //
        
        private boolean minimizeDependencySet = true;

        public boolean getMinimizeDependencySet()
        {
            return minimizeDependencySet;
        }

        public void cfgMinimizeDependencySet(ConfigurationValue cv, boolean minimumSet) throws ConfigurationException
        {
            this.minimizeDependencySet = minimumSet;
        }

        public static ConfigurationInfo getMinimizeDependencySetInfo()
        {
            return new ConfigurationInfo();
        }
                
    }

}
