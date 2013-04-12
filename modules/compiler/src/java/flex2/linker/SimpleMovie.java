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

import flash.swf.Frame;
import flash.swf.Movie;
import flash.swf.tags.*;
import flash.swf.types.FlashUUID;
import flash.swf.types.Rect;
import flash.util.Trace;
import flex2.compiler.AssetInfo;
import flex2.compiler.CompilationUnit;
import flex2.compiler.Source;
import flex2.compiler.util.*;
import flex2.compiler.util.graph.Algorithms;
import flex2.compiler.util.graph.DependencyGraph;
import flex2.compiler.util.graph.Vertex;
import flex2.compiler.util.graph.Visitor;
import flex2.tools.VersionInfo;
import flex2.tools.PreLink;

import java.util.*;

/**
 * Represents a simple single frame Movie.  It's currently not
 * instantiated directly.  Instead, it's subclasses for special
 * purposes like an application SWF or a library SWF.
 *
 * @author Clement Wong
 */
public class SimpleMovie extends Movie
{
	/**
	 * MD5 password is no longer needed for Flash Player. 
	 * Use this dummy password instead of generating one.
	 * @see http://bugs.adobe.com/jira/browse/SDK-27210
	 */
	private static final String NO_PASSWORD = "NO-PASSWORD";
	
	public SimpleMovie(LinkerConfiguration configuration)
    {
        if (configuration.width() != null)
	    {
		    try
		    {
			    width = Integer.parseInt(configuration.width());
		    }
		    catch(NumberFormatException nfe)
		    {
			    ThreadLocalToolkit.log(new PreLink.CouldNotParseNumber(configuration.width(), "width"));
		    }
	        userSpecifiedWidth = true;
	    }
	    else if (configuration.widthPercent() != null)
	    {
		    width = configuration.defaultWidth();
	        widthPercent = configuration.widthPercent();
	    }
		else
	    {
		    width = configuration.defaultWidth();
	    }

	    if (configuration.height() != null)
	    {
		    try
		    {
			    height = Integer.parseInt(configuration.height());
		    }
		    catch(NumberFormatException nfe)
		    {
			    ThreadLocalToolkit.log(new PreLink.CouldNotParseNumber(configuration.height(), "height"));
		    }
	        userSpecifiedHeight = true;
	    }
	    else if (configuration.heightPercent() != null)
	    {
		    height = configuration.defaultHeight();
	        heightPercent = configuration.heightPercent();
	    }
		else
	    {
		    height = configuration.defaultHeight();
	    }

		size = new Rect(width * 20, height * 20);

        if ((configuration.scriptLimitsSet()))
        {
            scriptLimits = new ScriptLimits( configuration.getScriptRecursionLimit(),
                                             configuration.getScriptTimeLimit() );
        }

        framerate = configuration.getFrameRate();
		version = configuration.getSwfVersion();
		bgcolor = new SetBackgroundColor(configuration.backgroundColor());
		if (configuration.debug())
		{
			enableDebugger = new EnableDebugger(NO_PASSWORD);
			uuid = new FlashUUID();
		}

        // SWF 8 File Attributes Support
        if (version >= 8)
        {
            fileAttributes = new FileAttributes();
            enableTelemetry = new EnableTelemetry();
            fileAttributes.actionScript3 = (version >= 9);    

            if (configuration.useNetwork())
            {
                fileAttributes.useNetwork = true;
	            fileAttributes.actionScript3 = (version >= 9);
            }
            
            if (configuration.getAdvancedTelemetry()) {
            	enableTelemetry.enabled = true;
            }
            
            fileAttributes.useDirectBlit = configuration.getUseDirectBlit();
            fileAttributes.useGPU = configuration.getUseGpu();
            
	        String metadataStr = configuration.getMetadata();
            if (metadataStr != null)
            {
                metadata = new Metadata();
                metadata.xml = metadataStr;
                fileAttributes.hasMetadata = true;
            }
        }

        long build = 0;
        byte majorVersion = 0;
        byte minorVersion = 0;
        
        try
        {
            majorVersion = (byte)Integer.parseInt(VersionInfo.FLEX_MAJOR_VERSION);
            minorVersion = (byte)Integer.parseInt(VersionInfo.FLEX_MINOR_VERSION);
            build = Long.parseLong( VersionInfo.getBuild() );
        }
        catch (NumberFormatException numberFormatException)
        {
            // preilly: for now just ignore empty or bogus build numbers.
        }

        
        productInfo = new ProductInfo(ProductInfo.ABOBE_FLEX_PRODUCT, 6,
                                        majorVersion, minorVersion, build, 
                                        System.currentTimeMillis());
		pageTitle = configuration.pageTitle();

		lazyInit = configuration.lazyInit();
        rootClassName = formatSymbolClassName( configuration.getRootClassName() );

        if (rootClassName == null)
            rootClassName = formatSymbolClassName( configuration.getMainDefinition() );
        
        exportedUnits = new LinkedHashMap<CompilationUnit, Frame>();
        
        includeInheritanceDependenciesOnly = configuration.getIncludeInheritanceDependenciesOnly();
	}

	protected boolean lazyInit;
    protected String rootClassName;
    protected Map<CompilationUnit, Frame> exportedUnits;
    
    protected boolean generateLinkReport, generateSizeReport, generateRBList;
    protected String linkReport, sizeReport;
	protected String rbList;
	private boolean includeInheritanceDependenciesOnly;

    protected static String formatSymbolClassName( String className )
    {
        // symbolclass list likes dotted classnames
        return (className == null)? null : className.replace( ':', '.' );
    }

	public void generate(List<CompilationUnit> units) throws LinkerException
	{
		// create a dependency graph based on source file dependencies...
        final DependencyGraph<CompilationUnit> dependencies = extractCompilationUnitInfo(units);

        // create a single frame - this is a simple movie
		final Frame frame = new Frame();
		frames = new ArrayList<Frame>();
		frames.add(frame);

        exportDependencies(dependencies, frame);

        topLevelClass = formatSymbolClassName( rootClassName );

        if (ThreadLocalToolkit.errorCount() > 0) {
  			throw new LinkerException.LinkingFailed();
        }
	}

    private DependencyGraph<CompilationUnit> extractCompilationUnitInfo(List<CompilationUnit> units)
    {
        final DependencyGraph<CompilationUnit> dependencies = new DependencyGraph<CompilationUnit>();
	    CompilationUnit main = null;

        for (int i = 0, length = units.size(); i < length; i++)
        {
            CompilationUnit u = units.get(i);
            Source s = u.getSource();
            String path = s.getName();

	        if (!u.isRoot())
	        {
		        // C: should also setup dependencies based on CompilationUnit.inheritance...
		        //    it still works because the list is already sorted and this is a SimpleMovie!
                dependencies.put(path, u);
		        dependencies.addVertex(new Vertex<String,CompilationUnit>(path));
	        }
	        else
	        {
		        main = u;
	        }
        }

        if (main != null)
        {
    	    // C: should also setup dependencies based on CompilationUnit.inheritance...
    	    //    it still works because the list is already sorted and this is a SimpleMovie!
            dependencies.put(main.getSource().getName(), main);
    	    dependencies.addVertex(new Vertex<String,CompilationUnit>(main.getSource().getName()));
        }

        return dependencies;
    }

    protected void exportUnitOnFrame( CompilationUnit u, Frame frame, boolean lazy )
    {
        if (u == null || u.getSource().isInternal())
        {
            return;
        }

        if (u.hasAssets())
        {
            for (Iterator<Map.Entry<String, AssetInfo>> it = u.getAssets().iterator(); it.hasNext();)
            {
                Map.Entry<String, AssetInfo> entry = it.next();
                String className = entry.getKey();
                AssetInfo assetInfo = entry.getValue();
                DefineTag tag = assetInfo.getDefineTag();

                if (Trace.dependency)
                    Trace.trace( u.getSource().getName() + " depends on symbolClass " + className );

                frame.addSymbolClass( formatSymbolClassName( className ), tag );

                // FIXME - this should be unnecessary, but as long as we generate the
                // FIXME - DisplayObject.mapSymbolToClass, we need it!

                if (tag.name != null)
                    frame.addExport( tag );
            }

            // temporary, see note in FontVisitor
            List<DefineFont> fonts = u.getAssets().getFonts();
            if (fonts != null)
            {
                for (DefineFont font : fonts)
                {
                    // Special casing this as DefineFont should NOT be linked by name and can
                    // have duplicate names as there can be bold and italic versions of the
                    // same font name in the same movie
                    // Note that the linkage between DefineText -> DefineFont is done via tag id, not name
                    frame.addFont( font );
                }
            }
        }

        DoABC tag = null;
        // FIXME: shouldn't we only be giving a name to SWFs created for a SWC?
        String name = NameFormatter.nameFromSource(u.getSource());
        if (u.getSource().isEntryPoint() || !lazy)
        {
            tag = new DoABC( name, 0 );
            // ThreadLocalToolkit.logInfo(fileName + " will be initialized eagerly at runtime.");
        }
        else
        {
            tag = new DoABC( name, 1 );
        }

        tag.abc = u.getByteCodes();
        frame.doABCs.add( tag );
        exportedUnits.put(u, frame);
    }

	private void exportDependencies(final DependencyGraph<CompilationUnit> dependencies, final Frame frame)
	{
		Set<Vertex<String,CompilationUnit>> cycles = Algorithms.detectCycles(dependencies);
		if (cycles.size() == 0)
		{
			// export compilation units
			Algorithms.topologicalSort(dependencies, new Visitor<Vertex<String,CompilationUnit>>()
			{
				public void visit(Vertex<String,CompilationUnit> v)
				{
					String fileName = v.getWeight();
					CompilationUnit u = dependencies.get(fileName);

					exportUnitOnFrame( u, frame, lazyInit );
				}
			});
		}
		else
		{
			ThreadLocalToolkit.logError("The following forms a cycle in the dependency graph: " + cycles.toString());
		}
	}

    public static int getCodeHash( Frame f )
    {
        int h = f.symbolClass.hashCode();
        for (Iterator ci = f.doABCs.iterator(); ci.hasNext();)
        {

            DoABC doABC = (DoABC) ci.next();
            for (int i = 0; i < doABC.abc.length; ++i)
                h += (doABC.abc[i] * DefineTag.PRIME);
        }
        return h & 0xffffff;
    }
    

    public List<CompilationUnit> getExportedUnits()
    {
        return new ArrayList<CompilationUnit>(exportedUnits.keySet());
    }
    
    public List<CompilationUnit> getExportedUnitsByFrame(Frame f)
    {
    	List<CompilationUnit> a = new ArrayList<CompilationUnit>();
    	
    	for (Iterator<CompilationUnit> i = exportedUnits.keySet().iterator(); i.hasNext(); )
    	{
    		CompilationUnit u = i.next();
    		Frame frame = exportedUnits.get(u);
    		if (f == frame)
    		{
    			a.add(u);
    		}
    	}
    	
    	return a;
    }
    
    public String getLinkReport()
    {
    	return linkReport;
    }
    
    public String getSizeReport()
    {
    	return sizeReport;
    }
    
    public void setSizeReport(String report)
    {
    	sizeReport = report;
    }
    
    public String getRBList()
    {
    	return rbList;
    }
    
    public boolean getInheritanceDependenciesOnly()
    {
        return includeInheritanceDependenciesOnly;
    }
}
