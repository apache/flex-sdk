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

import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import flash.localization.LocalizationManager;
import flash.localization.ResourceBundleLocalizer;
import flash.util.FileUtils;
import flash.util.Trace;
import flex2.compiler.CompilerAPI;
import flex2.compiler.CompilationUnit;
import flex2.compiler.CompilerSwcContext;
import flex2.compiler.Source;
import flex2.compiler.common.CompilerConfiguration;
import flex2.compiler.common.DefaultsConfigurator;
import flex2.compiler.config.CommandLineConfigurator;
import flex2.compiler.config.ConfigurationBuffer;
import flex2.compiler.config.ConfigurationException;
import flex2.compiler.config.FileConfigurator;
import flex2.compiler.config.SystemPropertyConfigurator;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.swc.Swc;
import flex2.compiler.swc.SwcScript;
import flex2.compiler.util.CompilerControl;
import flex2.compiler.util.MimeMappings;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.tools.CommandLineConfiguration;
import flex2.tools.CompcConfiguration;
import flex2.tools.Mxmlc;
import flex2.tools.ToolsConfiguration;
import flex2.tools.oem.*;

/**
 * A collection of utility methods used by classes in flex2.tools.oem.
 *
 * @version 2.0.1
 * @author Clement Wong
 */
public class OEMUtil
{
	/**
	 * 
	 */
    public static final LocalizationManager setupLocalizationManager()
    {
        LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();

        if (l10n == null)
        {
            // set up for localizing messages
            l10n = new LocalizationManager();
            l10n.addLocalizer(new ResourceBundleLocalizer());
            ThreadLocalToolkit.setLocalizationManager(l10n);
        }

        return l10n;
    }

	/**
	 * 
	 * @param logger
	 * @param mimeMappings
	 */
	public static final void init(Logger logger,
								  MimeMappings mimeMappings,
								  ProgressMeter meter,
								  PathResolver resolver,
								  CompilerControl cc)
	{
        CompilerAPI.useAS3();
        CompilerAPI.usePathResolver(resolver != null ? new OEMPathResolver(resolver) : null);
        setupLocalizationManager();
        ThreadLocalToolkit.setLogger(new OEMLogAdapter(logger));
        ThreadLocalToolkit.setMimeMappings(mimeMappings);
        ThreadLocalToolkit.setProgressMeter(meter);
        ThreadLocalToolkit.setCompilerControl(cc);
	}

	/**
	 * 
	 *
	 */
	public static final void clean()
	{
		CompilerAPI.removePathResolver();
		ThreadLocalToolkit.setLogger(null);
		ThreadLocalToolkit.setLocalizationManager(null);
		ThreadLocalToolkit.setMimeMappings(null);
		ThreadLocalToolkit.setProgressMeter(null);
		ThreadLocalToolkit.setCompilerControl(null);
        ThreadLocalToolkit.setCompatibilityVersion(null);
	}

	/**
	 * 
	 * @param in
	 * @return
	 * @throws IOException
	 */
	public static final String load(InputStream in, String cacheName) throws IOException
	{
		// grab the data and put it in a temp file...
		File temp = null;
		if (cacheName == null)
		{
			temp = FileUtil.createTempFile(in);
			temp.deleteOnExit();
		}
		else
		{
			temp = FileUtil.openFile(cacheName);
			FileUtil.writeBinaryFile(temp, in);
		}
		return FileUtil.getCanonicalPath(temp);
	}

	/**
	 * 
	 * @param out
	 * @param cacheName
	 * @param data
	 * @return
	 * @throws IOException
	 */
	public static final long save(OutputStream out, String cacheName, ApplicationData data) throws IOException
	{
		if (cacheName == null)
		{
			// this will create a temp file and populate cacheName.
			cacheName = load(new ByteArrayInputStream(new byte[0]), null);
		}
		
		// only save when there is something for us to save (i.e. data != null)
		if (cacheName != null && data != null)
		{
			// delete the existing cache file
			File dead = FileUtil.openFile(cacheName);
			if (dead != null && dead.exists())
			{
				dead.delete();
			}

			RandomAccessFile cacheFile = null;
			try
			{
				cacheFile = new RandomAccessFile(cacheName, "rw");
				CompilerAPI.persistCompilationUnits(data.configuration, data.fileSpec, data.sourceList,
                                                    data.sourcePath, data.resources, data.bundlePath,
                                                    data.sources, data.units, data.checksum,
                                                    data.cmdChecksum, data.linkChecksum, data.swcChecksum,
                                                    data.swcDefSignatureChecksums, data.swcFileChecksums,
                                                    "", cacheFile);
			}
			finally
			{
				if (cacheFile != null) { try { cacheFile.close(); } catch (IOException ex) {} }
			}
			
			// write the data to the specified output stream
			InputStream in = null;
			try
			{
				in = new BufferedInputStream(new FileInputStream(cacheName));
				FileUtil.streamOutput(in, out);
			}
			finally
			{		
				if (in != null) { try { in.close(); } catch (IOException ex) {} }
			}
			
			return new File(cacheName).length();
		}
		else
		{
			return 0;
		}
	}

	/**
	 * 
	 * @param args
	 * @param logger
	 * @param mimeMappings
	 * @return
	 */
	public static final OEMConfiguration getApplicationConfiguration(String[] args, boolean keepLinkReport, 
			                                                         boolean keepSizeReport, Logger logger, PathResolver resolver,
																	 MimeMappings mimeMappings)
	{
		return getApplicationConfiguration(args, keepLinkReport, keepSizeReport, logger, resolver, mimeMappings, true);
	}

	/**
	 * 
	 * @param args
	 * @param logger
	 * @param mimeMappings
	 * @param processDefaults
	 * @return
	 */
	public static final OEMConfiguration getApplicationConfiguration(String[] args, boolean keepLinkReport, boolean keepSizeReport, 
			                                                         Logger logger, PathResolver resolver, MimeMappings mimeMappings,
																	 boolean processDefaults)
	{
		if (!processDefaults)
		{
			return new OEMConfiguration(null, null);
		}
		
		// expect args to have --file-specs because we need it to find app-specific-config.xml.
		OEMUtil.init(logger, mimeMappings, null, resolver, null);
		
        try
		{
            ConfigurationBuffer cfgbuf = new ConfigurationBuffer(ApplicationCompilerConfiguration.class,
            													 ApplicationCompilerConfiguration.getAliases());
            cfgbuf.setDefaultVar(Mxmlc.FILE_SPECS);            
            DefaultsConfigurator.loadDefaults(cfgbuf);
            Object obj = Mxmlc.processConfiguration(ThreadLocalToolkit.getLocalizationManager(),
            										   "oem",
            										   args,
            										   cfgbuf,
            										   ApplicationCompilerConfiguration.class,
            										   Mxmlc.FILE_SPECS);
            
            ApplicationCompilerConfiguration configuration = (ApplicationCompilerConfiguration) obj;
            configuration.keepLinkReport(keepLinkReport);
            configuration.keepSizeReport(keepSizeReport);
            
            return new OEMConfiguration(cfgbuf, configuration);
		}
		catch (ConfigurationException ex)
		{
			Mxmlc.processConfigurationException(ex, "oem");
			return null;
		}
		catch (IOException ex)
		{
			ThreadLocalToolkit.logError(ex.getMessage());
			return null;
		}
		catch (RuntimeException ex)
		{
			Class c;
			try
			{
				c = Class.forName("flex.messaging.config.ConfigurationException");
				if (c.isInstance(ex))
				{
					ThreadLocalToolkit.logError(ex.getMessage());
				}
			}
			catch (ClassNotFoundException ex2)
			{
				
			}
			return null;
		}
	}

	/**
	 * 
	 * @param args
	 * @param logger
	 * @param mimeMappings
	 * @return
	 */
	public static final OEMConfiguration getLibraryConfiguration(String[] args, boolean keepLinkReport, 
			                                                     boolean keepSizeReport, Logger logger, PathResolver resolver,
																 MimeMappings mimeMappings)
	{
		return getLibraryConfiguration(args, keepLinkReport, keepSizeReport, logger, resolver, mimeMappings, true);
	}

	/**
	 * 
	 * @param args
	 * @param logger
	 * @param mimeMappings
	 * @param processDefaults
	 * @return
	 */
	public static final OEMConfiguration getLibraryConfiguration(String[] args, boolean keepLinkReport, 
			                                                     boolean keepSizeReport, Logger logger,
																 PathResolver resolver, MimeMappings mimeMappings,
																 boolean processDefaults)
	{
		if (!processDefaults)
		{
			return new OEMConfiguration(null, null);
		}
		
		// expect no SWC inputs in args.
		OEMUtil.init(logger, mimeMappings, null, resolver, null);
		
        try
		{
            ConfigurationBuffer cfgbuf = new ConfigurationBuffer(LibraryCompilerConfiguration.class,
            													 LibraryCompilerConfiguration.getAliases());
	        DefaultsConfigurator.loadOEMCompcDefaults( cfgbuf );
	        Object obj = Mxmlc.processConfiguration(ThreadLocalToolkit.getLocalizationManager(),
	        										   "oem",
	        										   args,
	        										   cfgbuf,
	        										   LibraryCompilerConfiguration.class,
	        										   null);
            
            LibraryCompilerConfiguration configuration = (LibraryCompilerConfiguration) obj;
            configuration.keepLinkReport(keepLinkReport);
            configuration.keepSizeReport(keepSizeReport);
            
            return new OEMConfiguration(cfgbuf, configuration);
		}
		catch (ConfigurationException ex)
		{
			Mxmlc.processConfigurationException(ex, "oem");
			return null;
		}
		catch (IOException ex)
		{
			ThreadLocalToolkit.logError(ex.getMessage());
			return null;
		}
		catch (RuntimeException ex)
		{
			Class c;
			try
			{
				c = Class.forName("flex.messaging.config.ConfigurationException");
				if (c.isInstance(ex))
				{
					ThreadLocalToolkit.logError(ex.getMessage());
				}
			}
			catch (ClassNotFoundException ex2)
			{
				
			}
			return null;
		}
	}

	/**
	 * 
	 * @param args
	 * @param logger
	 * @param mimeMappings
	 * @return
	 */
	public static final OEMConfiguration getLinkerConfiguration(String[] args, boolean keepLinkReport, boolean keepSizeReport,
																Logger logger, MimeMappings mimeMappings,
																PathResolver resolver,
																flex2.compiler.common.Configuration c,
																Set newLinkerOptions, Set<String> includes, Set<String> excludes)
	{
		OEMUtil.init(logger, mimeMappings, null, resolver, null);
		
        try
		{
            ConfigurationBuffer cfgbuf = new ConfigurationBuffer(LinkerConfiguration.class,
            													 LinkerConfiguration.getAliases());
            
            DefaultsConfigurator.loadDefaults(cfgbuf);
            Object obj = Mxmlc.processConfiguration(ThreadLocalToolkit.getLocalizationManager(),
	        										   "oem",
	        										   args,
	        										   cfgbuf,
	        										   LinkerConfiguration.class,
	        										   null);
            
            LinkerConfiguration configuration = (LinkerConfiguration) obj;
            configuration.setOriginalConfiguration(c, newLinkerOptions, includes, excludes);
            configuration.keepLinkReport(keepLinkReport);
            configuration.keepSizeReport(keepSizeReport);
            
            return new OEMConfiguration(cfgbuf, configuration);
		}
		catch (ConfigurationException ex)
		{
			Mxmlc.processConfigurationException(ex, "oem");
			return null;
		}
		catch (IOException ex)
		{
			ThreadLocalToolkit.logError(ex.getMessage());
			return null;
		}
		catch (RuntimeException ex)
		{
			Class cls;
			try
			{
				cls = Class.forName("flex.messaging.config.ConfigurationException");
				if (cls.isInstance(ex))
				{
					ThreadLocalToolkit.logError(ex.getMessage());
				}
			}
			catch (ClassNotFoundException ex2)
			{
				
			}
			return null;
		}
	}

	public static final ConfigurationBuffer getCommandLineConfigurationBuffer(Logger logger, PathResolver resolver, String[] args)
	{
		ConfigurationBuffer cfgbuf = null;
		
        try
        {
			OEMUtil.init(logger, null, null, resolver, null);
			
	        cfgbuf = new ConfigurationBuffer(CommandLineConfiguration.class, CommandLineConfiguration.getAliases());
	        SystemPropertyConfigurator.load( cfgbuf, "flex" );
        	CommandLineConfigurator.parse( cfgbuf, null, args);
        }
        catch (ConfigurationException ex)
        {
        	ThreadLocalToolkit.log(ex);
        	cfgbuf = null;
        }
        
        return cfgbuf;
	}
	
	public static final ConfigurationBuffer getCompcConfigurationBuffer(Logger logger, PathResolver resolver, String[] args)
	{
		ConfigurationBuffer cfgbuf = null;
		
        try
        {
			OEMUtil.init(logger, null, null, resolver, null);
			
	        cfgbuf = new ConfigurationBuffer(CompcConfiguration.class, CompcConfiguration.getAliases());
	        SystemPropertyConfigurator.load( cfgbuf, "flex" );
        	CommandLineConfigurator.parse( cfgbuf, null, args);
        }
        catch (ConfigurationException ex)
        {
        	ThreadLocalToolkit.log(ex);
        	cfgbuf = null;
        }
        
        return cfgbuf;
	}
	
	public static String[] trim(String[] args, ConfigurationBuffer cfgbuf, Set excludes)
	{
		List<Object[]> positions = cfgbuf.getPositions();
        List<Object> newArgs = new ArrayList<Object>();
		for (int i = 0, length = positions.size(); i < length; i++)
		{
			Object[] a = positions.get(i);
			String var = (String) a[0];
			int iStart = ((Integer) a[1]).intValue(), iEnd = ((Integer) a[2]).intValue();
			if (!excludes.contains(var))
			{
				for (int j = iStart; j < iEnd; j++)
				{
					newArgs.add(args[j]);
				}
			}
		}
		args = new String[newArgs.size()];
		newArgs.toArray(args);
		return args;
	}
	
	public static final Logger getLogger(Logger logger, List<Message> messages)
	{
		return new BuilderLogger(logger == null ? new OEMConsole() : logger, messages);
	}
	
	public static final String formatConfigurationBuffer(ConfigurationBuffer cfgbuf)
	{
		return FileConfigurator.formatBuffer(cfgbuf, "flex-config",
											 OEMUtil.setupLocalizationManager(), "flex2.configuration");
	}

	/**
	 * 
	 * @param configuration
	 * @return
	 */
	public static final Map getLicenseMap(ToolsConfiguration configuration)
	{
		return configuration.getLicensesConfiguration().getLicenseMap();
	}
	
	public static final void setGeneratedDirectory(CompilerConfiguration compilerConfig, File output)
	{
        if (compilerConfig.keepGeneratedActionScript())
        {
            File canonical = FileUtils.canonicalFile( output );

            if (canonical != null)
                output = canonical;

            String parent = output.getParent();

            String generated = null;
            if (parent == null)
            {
                generated = new File( "generated" ).getAbsolutePath();
            }
            else
            {
                generated = FileUtils.addPathComponents( parent, "generated", File.separatorChar );
            }
            compilerConfig.setGeneratedDirectory( generated );
            new File( generated ).mkdirs();
        }
	}

	/**
	 * Save the compiler units signature checksums to ApplicationData.
	 * These will be used by the next compilation to determine if we
	 * can do an incremental compiler or if a full recompilation is required.
	 * 
	 * @param units - compilation units, may be null
	 * @param data	- application data, may not be null
	 */
	public static void saveSignatureChecksums(List units, ApplicationData data, 
										flex2.compiler.common.Configuration config)
	{
		if (!config.isSwcChecksumEnabled())
		{
			data.swcDefSignatureChecksums = null;
			return;
		}
		
		if (units != null)
		{
			data.swcDefSignatureChecksums = new HashMap<QName, Long>();
			for (Iterator iter = units.iterator(); iter.hasNext();) 
			{
				CompilationUnit unit = (CompilationUnit)iter.next();
				Source source = unit == null ? null : unit.getSource();
				if (source != null && source.isSwcScriptOwner() && !source.isInternal())
				{
					addSignatureChecksumToData(data, unit); 
				}
			}
		}
	}

	/**
	 * @param swcContext context, may not be null
	 * @param data	- application data, may not be null
	 */
	public static void saveSwcFileChecksums(CompilerSwcContext swcContext, ApplicationData data, 
										flex2.compiler.common.Configuration config)
	{
		if (!config.isSwcChecksumEnabled())
		{
			data.swcFileChecksums = null;
			return;
		}
		
		data.swcFileChecksums = new HashMap<String, Long>();
		for (Iterator iter = swcContext.getFiles().entrySet().iterator(); iter.hasNext();) 
		{
			Map.Entry entry = (Map.Entry)iter.next();
			String filename = (String)entry.getKey();
			VirtualFile file = (VirtualFile)entry.getValue();
			data.swcFileChecksums.put(filename, new Long(file.getLastModified())); 
		}

        for (VirtualFile themeStyleSheet : swcContext.getThemeStyleSheets())
        {
            data.swcFileChecksums.put(themeStyleSheet.getName(),
                                      new Long(themeStyleSheet.getLastModified()));
        }
	}

	/**
	     * Loop thru the saved signature checksums in the application data and compare them with
	     * the signature checksums in the swc context.
	     * 
	     * @param data  application data from a previous compile. May not be null.
	     * @param swcContext  swc context
	     * @return true if all the signature checksums in application data match the checksums
	     * 		   in the swc context.
	     */
	    public static boolean isRecompilationNeeded(ApplicationData data, 
	    									  CompilerSwcContext swcContext,
	    									  OEMConfiguration config)
		{
	    	int checksum = OEMUtil.calculateChecksum(data, swcContext, config);
	
	        // if the checksum from last time and the current checksum do not match,
	        // then we need to recompile.
	    	if (checksum != data.checksum)
	    	{
		    	if (Trace.swcChecksum)
		    	{
			        Trace.trace("isRecompilationNeeded: calculated checksum differs from last checksum, recompile");	    		
		    	}
	    		data.checksum = checksum;
	     		return true;
	    	}
            
	    	// if we got here and swc checksums are disabled, then
	    	// the checksums are equal and a recompilation is not needed.
	    	// Otherwise continue on and compare the swc checksums.
	        if (!config.configuration.isSwcChecksumEnabled())
	    	{
		    	if (Trace.swcChecksum)
		    	{
			        Trace.trace("isRecompilationNeeded: checksums equal, swc-checksum disabled, incremental compile");	    		
		    	}
	            return false;
	    	}
	
	    	Map signatureChecksums = data.swcDefSignatureChecksums;
	    	if (signatureChecksums == null)
	    	{
		    	if (Trace.swcChecksum)
		    	{
			        Trace.trace("isRecompilationNeeded: checksums equal, signatureChecksums is null, incremental compile");	    		
		    	}
	    	}
	    	else
	    	{
		    	for (Iterator iter = signatureChecksums.entrySet().iterator(); iter.hasNext();)
		    	{
		    		Map.Entry entry = (Map.Entry)iter.next();
		    		
		    		// lookup definition in swc context 
                    QName qName = (QName) entry.getKey();
		    		Long dataSignatureChecksum = (Long)entry.getValue();
		    		Long swcSignatureChecksum = swcContext.getChecksum(qName);
                    if (swcSignatureChecksum == null && qName != null)
                    {
                        Source source = swcContext.getSource(qName.getNamespace(), qName.getLocalPart());
                        if (source != null)
                        {
                            swcSignatureChecksum = new Long(source.getLastModified());
                        }
                    }
		    		if (Trace.swcChecksum)
			    	{
			    		if (dataSignatureChecksum == null)
			    		{
			    			throw new IllegalStateException("dataSignatureChecksum should never be null");
			    		}
			    	}

			    	if (dataSignatureChecksum != null && swcSignatureChecksum == null)
		    		{
				    	if (Trace.swcChecksum)
				    	{
					        Trace.trace("isRecompilationNeeded: signature checksums not equal, recompile");	    		
				    		Trace.trace("compare " + entry.getKey());
				    		Trace.trace("data =  " + dataSignatureChecksum);
				    		Trace.trace("swc  =  " + swcSignatureChecksum);
				    	}
		    			return true;
		    		}
		    		
		    		if (dataSignatureChecksum != null)
		    		{
		    			if (dataSignatureChecksum.longValue() != swcSignatureChecksum.longValue())
		    			{
					    	if (Trace.swcChecksum)
					    	{
						        Trace.trace("isRecompilationNeeded: signature checksums not equal, recompile");	    		
					    		Trace.trace("compare " + entry.getKey());
					    		Trace.trace("data =  " + dataSignatureChecksum);
					    		Trace.trace("swc  =  " + swcSignatureChecksum);
					    	}
		    				return true;
		    			}
		    		}
		    		else {
		    			// dataSignatureChecksum should never be null, but if it is then recompile.
		    			return true;
		    		}
		    	}
	    	}

	    	boolean result = !areSwcFileChecksumsEqual(data, swcContext);

	    	if (Trace.swcChecksum)
	    	{
		        Trace.trace("isRecompilationNeeded: " + (result ? "recompile" : "incremental compile"));	    		
	    	}

	        return result;
		}

	/**
	* Calculate the data checksum.
	*  
	* @param data  application data from a previous compile. If a recompilation is 
	* 				needed, data.checksum is updated with the new checksum. May not be null.
	* @param swcContext  swc context
	* @return true if all the signature checksums in application data match the checksums
	* 		   in the swc context.
	*/
	public static int calculateChecksum(ApplicationData data, 
										  CompilerSwcContext swcContext,
										  OEMConfiguration config)
	{
	    int checksum = config.cfgbuf.checksum_ts();
	    
	    // if swc checksums are disabled or there are no checksums to compare, then
	    // include the swc timestamp as part of the checksum.
	    if (!config.configuration.isSwcChecksumEnabled() ||
	    	data.swcDefSignatureChecksums == null ||
	    	data.swcDefSignatureChecksums.size() == 0)
		{
	    	checksum += swcContext.checksum();
		}
	    
	    return checksum;
	}
	
    /**
     * Add all top level definitions to ApplicationData
     * @param swcDefSignatureChecksums
     * @param unit
     * @param signatureChecksum
     */
    private static void addSignatureChecksumToData(ApplicationData data, CompilationUnit unit)
	{
		Long signatureChecksum = unit.getSignatureChecksum();
		if (signatureChecksum == null)
		{
			SwcScript script = (SwcScript) unit.getSource().getOwner();
			signatureChecksum = new Long(script.getLastModified());
		}

		if (data.swcDefSignatureChecksums != null)
		{
			for (Iterator iter = unit.topLevelDefinitions.iterator(); iter.hasNext();)
	    	{
	    		QName qname = (QName) iter.next();
	        	data.swcDefSignatureChecksums.put(qname, signatureChecksum);
	    	}
		}
	}

    
    /**
     * Test if the files in the compiler swc context have changed since the last compile.
     * 
     * @param data	- application data, may not be null
     * @param swcContext context, may not be null
     * @return true it the swc files compiled with last time are the same as this time.
     */
    private static boolean areSwcFileChecksumsEqual(ApplicationData data,
                                                    CompilerSwcContext swcContext)
	{
    	if (data.swcFileChecksums == null)
    	{
        	if (Trace.swcChecksum)
        	{
    	        Trace.trace("areSwcFileChecksumsEqual: no file checksum map, not equal");	    		
        	}
        	
    		return false;
    	}

    	Map swcFiles = swcContext.getFiles();

        for (VirtualFile themeStyleSheet : swcContext.getThemeStyleSheets())
        {
            swcFiles.put(themeStyleSheet.getName(), themeStyleSheet);
        }

    	Set dataSet = data.swcFileChecksums.entrySet();

    	if (swcFiles.size() < dataSet.size())
    	{
        	if (Trace.swcChecksum)
        	{
    	        Trace.trace("areSwcFileChecksumsEqual: less files than before, not equal");	    		
        	}
        	
    		return false;    		
    	}
    	
    	for (Iterator iter = dataSet.iterator(); iter.hasNext();) 
    	{
    		Map.Entry entry = (Map.Entry)iter.next();
    		String filename = (String)entry.getKey();

            // When we are reusing cached SWC's, the catalog.xml and
            // library.swf are updated each time we save the
            // SwcDynamicArchive, but we don't want to reload the SWC
            // from disk, because all the compilation units
            // represented by catalog.xml should be cached.  If any of
            // the cached CompilationUnit's becomes out of data,
            // CompilerAPI.validateCompilationUnits() will handle
            // removing the cached CompilationUnit, which will cause
            // it to be reloaded from disk.
            if (!filename.equals(Swc.CATALOG_XML) &&
                !filename.equals(Swc.LIBRARY_SWF))
            {
                Long dataFileLastModified = (Long)entry.getValue();
                Long swcFileLastModified = null;
                VirtualFile swcFile = (VirtualFile)swcFiles.get(filename);
                if (swcFile != null)
                {
                    swcFileLastModified = new Long(swcFile.getLastModified());
                }
    		
                if (!dataFileLastModified.equals(swcFileLastModified))
                {
                    if (Trace.swcChecksum)
                    {
                        Trace.trace("areSwcFileChecksumsEqual: not equal");
                        Trace.trace("filename = " + filename);
                        Trace.trace("last modified1 = " + dataFileLastModified);
                        Trace.trace("last modified2 = " + swcFileLastModified);
                    }
                    return false;
                }
            }
        }
    	
    	if (Trace.swcChecksum)
    	{
    		Trace.trace("areSwcFileChecksumsEqual: equal");
    	}
    	
    	return true;
	}
}
