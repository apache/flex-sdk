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

package flex2.linker;

import java.util.List;
import java.util.Set;
import java.util.SortedSet;

import flex2.compiler.common.FramesConfiguration.FrameInfo;

/**
 * This interface is used to restrict consumers of
 * flex2.compiler.common.Configuration to linker specific options.
 *
 * @author Clement Wong
 */
public interface LinkerConfiguration
{
	// C: If you add a method here, please add it to
	// flex2.tools.oem.internal.LinkerConfiguration as well.
	
    int backgroundColor();

	/**
	 * Generate SWFs for debugging.
	 */
	boolean debug();

    boolean verboseStacktraces();

	boolean optimize();

	boolean useNetwork();

	boolean lazyInit();

    boolean scriptLimitsSet();

    int getScriptTimeLimit();

    int getScriptRecursionLimit();

    int getFrameRate();

    String getMetadata();

    /**
	 * The password to include in debuggable swfs.
	 */
	String debugPassword();

    /**
	 * SWF width
	 */
	String width();

	int defaultWidth();

	/**
	 * SWF height
	 */
	String height();

	int defaultHeight();
	
	/**
	 * SWF height percentage
	 */
	String heightPercent();

	/**
	 * SWF width percentage
	 */
	String widthPercent();

	/**
	 * browser page title
	 */
	String pageTitle();

    /**
     * @param mainDefinition the name of the app class to instantiate
     */
    void setMainDefinition( String mainDefinition );
    String getMainDefinition();

    /**
     * @return the name of the root SWF class
     */
    String getRootClassName();

    /**
     * @param rootClassName the name of the root SWF class
     */
    void setRootClassName( String rootClassName );

    /**
     * @return list of frame classes
     */
    List<FrameInfo> getFrameList();

    /**
     * @return set of configured external symbols
     */
    Set<String> getExterns();

	/**
	 * @return set of symbols to always include
	 */
	Set<String> getIncludes();

    /**
     * @return set of symbols that were not resolved (includes any referenced externs)
     */
    Set<String> getUnresolved();

    /**
     * @return name of compile report file, null if none
     */
    String getLinkReportFileName();
    boolean generateLinkReport();
    
    /**
     * @return name of size report file, null if none
     */
    String getSizeReportFileName();
    boolean generateSizeReport();

	/**
	 * @return name of resource bundle list file, null if none
	 */
	String getRBListFileName();
    boolean generateRBList();

	/**
	 * @return set of resource bundles for resource bundle list
	 */
	SortedSet<String> getResourceBundles();
	
	/**
	 * @return the as3 metadata to keep
	 */
	String[] getMetadataToKeep();
	
	/**
	 * @return true if the digest should be computed, false otherwise.
	 */
	 boolean getComputeDigest();
     
     String getCompatibilityVersionString();
	 int getCompatibilityVersion();
	 
	 String getMinimumSupportedVersionString();
	 int getMinimumSupportedVersion();

	/**
	 * @return The major version of the player targeted by this application.
	 * 		   The returned value will be greater to or equal to 9.  
	 */
	 int getTargetPlayerMajorVersion();

	/**
	 * @return The minor version of the player targeted by this application.
	 * 		   The returned value will be greater to or equal to 0.  
	 */
	 int getTargetPlayerMinorVersion();
	
	/**
	 * @return The revision of the player targeted by this application.
	 * 		   The returned value will be greater to or equal to 0.  
	 */
	 int getTargetPlayerRevision();
	 
	 /**
	  * @return The version of the generated SWF file.
	  */
	 int getSwfVersion();
	 
	 boolean getUseGpu();
	 
	 boolean getUseDirectBlit();
	
	 /**
	  * 
	  * @return true if only inheritance 
	  */
	 boolean getIncludeInheritanceDependenciesOnly();
	 
	 boolean getAdvancedTelemetry();
}
