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
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;

import flex2.compiler.common.Configuration;
import flex2.compiler.common.FramesConfiguration.FrameInfo;
import flex2.compiler.config.ConfigurationBuffer;
import flex2.compiler.config.ConfigurationException;
import flex2.tools.ToolsConfiguration;

/**
 * A configuration that extends ToolsConfiguration by adding link
 * specific options.
 *
 * @version 2.0.1
 * @author Clement Wong
 */
/*
 * TODO Jono: this should really *implement* flex2.linker.Configuration
 * and not extend ToolsConfiguration to keep us honest about settings
 * required for linking -- options that were not part of the original
 * config are currently ignored and their values instead come from the
 * inherited ToolsConfiguration, and are the default values (rather
 * than the ones coming from original).
 *
 * Example: I forgot to implement getTargetPlayerMajorVersion() here,
 * and it instead came from super, so the value set on the command line
 * was totally ignored.
 */
public class LinkerConfiguration extends ToolsConfiguration implements flex2.linker.LinkerConfiguration
{
	public static Map<String, String> getAliases()
    {
        Map<String, String> map = new HashMap<String, String>();
	    map.putAll(Configuration.getAliases());
	    map.remove("o");
		return map;
    }

    public void validate( ConfigurationBuffer cfgbuf ) throws ConfigurationException
    {
    	super.validate(cfgbuf);
    }
    
    private flex2.linker.LinkerConfiguration original;
    private Set args;
    
    public void setOriginalConfiguration(flex2.linker.LinkerConfiguration original, Set args, Set<String> includes, Set<String> excludes)
    {
    	this.original = original;
    	this.args = args;

    	Set s = getIncludes();
    	addIncludes(s == null || s.size() == 0 ? original.getIncludes() : includes);
    	s = getExterns();
    	addExterns(s == null || s.size() == 0 ? original.getExterns() : excludes);
    }

    // flex2.linker.Configuration methods...

	public int backgroundColor()
	{
		if (args.contains(ConfigurationConstants.DEFAULT_BACKGROUND_COLOR))
		{
			return super.backgroundColor();
		}
		else
		{
			return original.backgroundColor();
		}
	}

	public String debugPassword()
	{
		if (args.contains(ConfigurationConstants.DEBUG_PASSWORD))
		{
			return super.debugPassword();
		}
		else
		{
			return original.debugPassword();
		}
	}

	public int defaultHeight()
	{
		if (args.contains(ConfigurationConstants.DEFAULT_SIZE))
		{
			return super.defaultHeight();
		}
		else
		{
			return original.defaultHeight();
		}
	}

	public int defaultWidth()
	{
		if (args.contains(ConfigurationConstants.DEFAULT_SIZE))
		{
			return super.defaultWidth();
		}
		else
		{
			return original.defaultWidth();
		}
	}

	public boolean debug()
	{
		if (args.contains(ConfigurationConstants.COMPILER_DEBUG))
		{
			return super.debug();
		}
		else
		{
			return original.debug();
		}
	}

	public Set<String> getExterns()
	{
		return super.getExterns();
	}

	public List<FrameInfo> getFrameList()
	{
		if (args.contains(ConfigurationConstants.FRAMES_FRAME))
		{
			return super.getFrameList();
		}
		else
		{
			return original.getFrameList();
		}
	}

	public int getFrameRate()
	{
		if (args.contains(ConfigurationConstants.DEFAULT_FRAME_RATE))
		{
			return super.getFrameRate();
		}
		else
		{
			return original.getFrameRate();
		}
	}

	public Set<String> getIncludes()
	{
		return super.getIncludes();
	}

	public String getLinkReportFileName()
	{
		return null;
	}

	public String getMainDefinition()
	{
		return original.getMainDefinition();
	}

	public String getMetadata()
	{
		if (args.contains(ConfigurationConstants.METADATA_CONTRIBUTOR) ||
			args.contains(ConfigurationConstants.METADATA_CREATOR) ||
			args.contains(ConfigurationConstants.METADATA_DATE) ||
			args.contains(ConfigurationConstants.METADATA_LANGUAGE) ||
			args.contains(ConfigurationConstants.METADATA_LOCALIZED_DESCRIPTION) ||
			args.contains(ConfigurationConstants.METADATA_LOCALIZED_TITLE) ||
			args.contains(ConfigurationConstants.METADATA_PUBLISHER) ||
			args.contains(ConfigurationConstants.RAW_METADATA))
		{
			return super.getMetadata();
		}
		else
		{
			return original.getMetadata();
		}
	}

	public String getRBListFileName()
	{
		return null;
	}

	public SortedSet<String> getResourceBundles()
	{
		return original.getResourceBundles();
	}

	public String getRootClassName()
	{
		return original.getRootClassName();
	}

	public int getScriptRecursionLimit()
	{
		if (args.contains(ConfigurationConstants.DEFAULT_SCRIPT_LIMITS))
		{
			return super.getScriptRecursionLimit();
		}
		else
		{
			return original.getScriptRecursionLimit();
		}
	}

	public int getScriptTimeLimit()
	{
		if (args.contains(ConfigurationConstants.DEFAULT_SCRIPT_LIMITS))
		{
			return super.getScriptTimeLimit();
		}
		else
		{
			return original.getScriptTimeLimit();
		}
	}

	public Set<String> getUnresolved()
	{
		return original.getUnresolved();
	}

	public String height()
	{
		return original.height();
	}

	public String heightPercent()
	{
		return original.heightPercent();
	}

	public boolean verboseStacktraces()
	{
		if (args.contains(ConfigurationConstants.COMPILER_DEBUG) ||
			args.contains(ConfigurationConstants.COMPILER_VERBOSE_STACKTRACES))
		{
			return super.verboseStacktraces();
		}
		else
		{
			return original.verboseStacktraces();
		}
	}

	public boolean lazyInit()
	{
		return original.lazyInit();
	}

	public boolean optimize()
	{
		if (args.contains(ConfigurationConstants.COMPILER_OPTIMIZE))
		{
			return super.optimize();
		}
		else
		{
			return original.optimize();
		}
	}

	public String pageTitle()
	{
		return original.pageTitle();
	}

	public boolean scriptLimitsSet()
	{
		if (args.contains(ConfigurationConstants.DEFAULT_SCRIPT_LIMITS))
		{
			return super.scriptLimitsSet();
		}
		else
		{
			return original.scriptLimitsSet();
		}
	}

    public int getSwfVersion()
    {
        if (args.contains(ConfigurationConstants.SWF_VERSION))
        {
            return super.getSwfVersion();
        }
        else
        {
            return original.getSwfVersion();
        }	    
    }

	public void setMainDefinition(String mainDefinition)
	{
		original.setMainDefinition(mainDefinition);
	}

	public void setRootClassName(String rootClassName)
	{
		original.setRootClassName(rootClassName);
	}

	public boolean useNetwork()
	{
		if (args.contains(ConfigurationConstants.USE_NETWORK))
		{
			return super.useNetwork();
		}
		else
		{
			return original.useNetwork();
		}
	}

	public String width()
	{
		return original.width();
	}

	public String widthPercent()
	{
		return original.widthPercent();
	}
	
	private boolean generateLinkReport;
	
	public void keepLinkReport(boolean b)
	{
		generateLinkReport = b;
	}
	
	public boolean generateLinkReport()
	{
		return generateLinkReport || super.generateLinkReport();
	}
	
	private boolean generateSizeReport;
	
	public void keepSizeReport(boolean b)
	{
		generateSizeReport = b;
	}
	
	public boolean generateSizeReport()
	{
		return generateSizeReport || super.generateSizeReport();
	}
	
	public String[] getMetadataToKeep()
	{
		if (args.contains(ConfigurationConstants.COMPILER_KEEP_AS3_METADATA))
		{
			return super.getMetadataToKeep();
		}
		else
		{
			return original.getMetadataToKeep();
		}
	}
	
	public boolean getComputeDigest()
	{
		if (args.contains(ConfigurationConstants.COMPILER_COMPUTE_DIGEST))
		{
			return super.getComputeDigest();
		}
		else
		{
			return original.getComputeDigest();
		}
	}

    public String getCompatibilityVersionString()
    {
        if (args.contains(ConfigurationConstants.COMPILER_MXML_COMPATIBILITY))
		{
			return super.getCompatibilityVersionString();
		}
		else
		{
            return original.getCompatibilityVersionString();
		}
    }

    
    public int getCompatibilityVersion()
    {
        if (args.contains(ConfigurationConstants.COMPILER_MXML_COMPATIBILITY))
		{
			return super.getCompatibilityVersion();
		}
		else
		{
            return original.getCompatibilityVersion();
		}
	}

    public String getOutput()
    {
        return null;
    }

    public String getTargetFile()
    {
        return null;
    }

	public int getTargetPlayerMajorVersion()
	{
        if (args.contains(ConfigurationConstants.TARGET_PLAYER))
		{
			return super.getTargetPlayerMajorVersion();
		}
		else
		{
            return original.getTargetPlayerMajorVersion();
		}
	}
	
	public int getTargetPlayerMinorVersion()
	{
        if (args.contains(ConfigurationConstants.TARGET_PLAYER))
		{
			return super.getTargetPlayerMinorVersion();
		}
		else
		{
            return original.getTargetPlayerMinorVersion();
		}
	}
	
	public int getTargetPlayerRevision()
	{
        if (args.contains(ConfigurationConstants.TARGET_PLAYER))
		{
			return super.getTargetPlayerRevision();
		}
		else
		{
            return original.getTargetPlayerRevision();
		}
	}
}
