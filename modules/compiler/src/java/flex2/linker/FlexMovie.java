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

import flex2.compiler.CompilationUnit;
import flex2.compiler.Source;
import flex2.compiler.common.FramesConfiguration;
import flex2.compiler.common.FramesConfiguration.FrameInfo;
import flex2.compiler.swc.SwcLibrary;
import flex2.compiler.swc.SwcScript;
import flex2.compiler.util.*;
import flex2.compiler.util.graph.Visitor;
import flash.swf.Frame;
import flash.swf.tags.FrameLabel;

import java.util.*;

/**
 * Extends SimpleMovie by adding support for multiple frames and
 * keeping AS3 metadata.
 *
 * @author Roger Gonzalez
 */
public class FlexMovie extends SimpleMovie
{
    private List<FrameInfo> frameInfoList;
    private List<FrameInfo> configFrameInfoList;
    private String mainDef;
    private Set<String> externs;
	private Set<String> includes;
    private Set<String> unresolved;
	private SortedSet<String> resourceBundles;
    
    /**
     * List of metadata names that are the unions of the library's metadata names
     * that have script linked into this movie (both internal and external references).
     */
	private Set<String> metadata;
    
    public FlexMovie( LinkerConfiguration linkerConfiguration )
    {
        super( linkerConfiguration );
        mainDef = linkerConfiguration.getMainDefinition();        

        // C: FlexMovie should keep its own copy of externs, includes, unresolved and resourceBundles
        //    so that incremental compilation can do the single-compile-multiple-link scenario.
        externs = new HashSet<String>(linkerConfiguration.getExterns());
	    includes = new LinkedHashSet<String>(linkerConfiguration.getIncludes());
        unresolved = new HashSet<String>(linkerConfiguration.getUnresolved());
        generateLinkReport = linkerConfiguration.generateLinkReport();
        generateRBList = linkerConfiguration.generateRBList();
	    resourceBundles = new TreeSet<String>(linkerConfiguration.getResourceBundles());

        frameInfoList = new LinkedList<FrameInfo>();
        configFrameInfoList = new LinkedList<FrameInfo>();
        configFrameInfoList.addAll( linkerConfiguration.getFrameList() );
        metadata = new HashSet<String>();
    }

    private void prelink( List<CompilationUnit> units ) throws LinkerException
    {
        // Starting at the main definition, build the list of frames and frame classes.
        // No new classes can be discovered here, we're just building the frame class list.

        Map<String, CompilationUnit> def2unit = new HashMap<String, CompilationUnit>();
        for (Iterator<CompilationUnit> it = units.iterator(); it.hasNext(); )
        {
            CompilationUnit unit = it.next();
            mapAll( def2unit, unit.topLevelDefinitions.getStringSet(), unit );
        }

        buildFrames( def2unit, mainDef, new HashSet<String>() );

        frameInfoList.addAll( configFrameInfoList );

        if (frameInfoList.size() > 0)
        {
            topLevelClass = formatSymbolClassName( frameInfoList.get( 0 ).frameClasses.get( 0 ) );
        }
    }

    private boolean hasFrameClass( String queryClassName )
    {
        // This is horribly inefficient, but the inner loop will only get called a few times
        // for a typical Flex movie.
        for (Iterator<FrameInfo> fit = frameInfoList.iterator(); fit.hasNext();)
        {
            FramesConfiguration.FrameInfo frameInfo = fit.next();

            for (Iterator<String> cit = frameInfo.frameClasses.iterator(); cit.hasNext(); )
            {
                String className = cit.next();
                if (className.equals( queryClassName ))
                    return true;
            }
        }
        return false;
    }

    private void buildFrames( Map<String, CompilationUnit> def2unit, String className, Set<String> progress ) throws LinkerException
    {
        if (hasFrameClass( className ))
            return;

        if (progress.contains( className ))
            return;

        progress.add( className );

        CompilationUnit unit = def2unit.get( className );

        if (unit == null)   // this should get picked up elsewhere
            throw new LinkerException.UndefinedSymbolException( className ); // fixme - add special frame class error?

        if (unit.loaderClass != null)
        {
            buildFrames( def2unit, unit.loaderClass, progress );
        }
        FramesConfiguration.FrameInfo info = new FramesConfiguration.FrameInfo();
        info.label = className.replaceAll( "[^A-Za-z0-9]", "_" );
        info.frameClasses.add( className );
	    info.frameClasses.addAll( unit.resourceBundles );
        info.frameClasses.addAll( unit.extraClasses );
        frameInfoList.add( info );
    }

    // shouldn't need swcContext at this point - units should have all referenced defs by now.
    public void generate(List<CompilationUnit> units) throws LinkerException
    {
        try
        {
            prelink( units );
        }
        catch (LinkerException e)
        {
            // You can't actually throw a LinkerException from generate,
            // because an assert fires downstream that expects errorcount > 0!
            // So, we have to warn here and then rethrow.

            ThreadLocalToolkit.log( e );
            throw e;
        }

        List<CULinkable> linkables = new LinkedList<CULinkable>();

		//	TODO remove - see note below
        String serverConfigDef = null;

        CULinkable mainLinkable = null;
        for (Iterator<CompilationUnit> it = units.iterator(); it.hasNext();)
        {
            CompilationUnit unit = it.next();

			//	NOTE Here we watch for specific generated loose code units we have carnal knowledge of, and add their
			//	definitions as deps to the main unit.
			// 	TODO Remove once serverconfigdata is handled within the standard bootstrap setup.
			//
            Source source = unit.getSource();
			String sourceName = source.getName();

            if (sourceName.equals("serverConfigData.as"))
            {
                serverConfigDef = unit.topLevelDefinitions.first().toString();
            }
            CULinkable linkable = new CULinkable( unit );
            if (unit.isRoot())
                mainLinkable = linkable;

            if (source.isInternal())
            {
                externs.addAll( unit.topLevelDefinitions.getStringSet() ); 
            }

            linkables.add( linkable );            
        }

        frames = new ArrayList<Frame>();

        // FIXME - hook serverconfigdata to FlexInit mixin
		if (mainLinkable != null)
		{
            if (serverConfigDef != null)
                mainLinkable.addDep(serverConfigDef);
		}

        try
        {
            final Set<SwcLibrary> librariesProcessed = new HashSet<SwcLibrary>();
            int counter = 0;
            DependencyWalker.LinkState state = new DependencyWalker.LinkState( linkables, externs, includes, unresolved );
            for (Iterator<FrameInfo> it = frameInfoList.iterator(); it.hasNext();)
            {
                FramesConfiguration.FrameInfo frameInfo = it.next();
                final Frame f = new Frame();
	            f.pos = ++counter;

                if (frameInfo.label != null)
                {
                    f.label = new FrameLabel();
                    f.label.label = frameInfo.label;
                }

                // note that we only allow externs on the last frame
                DependencyWalker.traverse( frameInfo.frameClasses, state, !it.hasNext(), !it.hasNext(),
                                           getInheritanceDependenciesOnly(), 
                                           new Visitor<Linkable>()
                {
                    public void visit( Linkable o )
                    {
                        // FIXME - keep an eye on those lazy abcs... do we have loose script?
						//	TODO yep! delete "false &&" once loose-script bootstrapping code has been eliminated - see note above
                        CULinkable l = (CULinkable) o;
                        // exportUnitOnFrame( l.getUnit(), f, false);// && !l.hasDefinition( frameClass ) );
	                    exportUnitOnFrame( l.getUnit(), f, lazyInit);
                        
                        // for any scripts that we include from libraries, add the libraries keep-as3-metadata
                        // to the list of metadata we will preserve in postlink.
                        Source source = l.getUnit().getSource();
                        if (source.isSwcScriptOwner() && !source.isInternal())
                        {
                            SwcScript script = (SwcScript)source.getOwner();
                            SwcLibrary library = script.getLibrary();
                 
                            // lots of scripts, but not many swcs, so avoid adding the same metadata
                            // over and over.
                            if (!librariesProcessed.contains(library))
                            {
                                librariesProcessed.add(library);
                                metadata.addAll(library.getMetadata());
                            }
                        }
                    }
                });
                frames.add( f );
            }

            if (generateLinkReport)
            {
            	linkReport = DependencyWalker.dump( state );
            }
            if (generateRBList)
            {
            	rbList = dumpRBList(resourceBundles);
            }
            
	        if (unresolved.size() != 0)
	        {
	            boolean fatal = false;
	            for (Iterator<String> it = unresolved.iterator(); it.hasNext();)
	            {
	                String u = it.next();
	                if (!externs.contains( u ))
	                {
	                    ThreadLocalToolkit.log( new LinkerException.UndefinedSymbolException( u ) );
	                    fatal = true;
	                }
	            }
	            if (fatal)
	            {
	                throw new LinkerException.LinkingFailed();
	            }
	        }

        }
        catch (LinkerException e)
        {
            ThreadLocalToolkit.log( e );
            throw e;
        }
    }

	public static String dumpRBList(Set<String> bundles)
	{
		StringBuilder b = new StringBuilder();
	    b.append("bundles = ");
	    for (Iterator<String> iterator = bundles.iterator(); iterator.hasNext();)
	    {
		    String str = iterator.next();
		    b.append(str + " ");
	    }		
	    return b.toString();
	}
	
	private static void mapAll( Map<String, CompilationUnit> map, Set keys, CompilationUnit val )
	{
	    for (Iterator it = keys.iterator(); it.hasNext();)
	    {
	        String defname = (String) it.next();
//            defname = defname.replace( ':', '.' );      // FIXME - which is the canonical form?
	        map.put( defname, val );
	    }
	}

    /**
     * Get the set of metadata names that should be preserved when optimizing this movie. 
     *
     * @return Set of metadata names to keep in the movie.
     */
    public Set<String> getMetadata()
    {
        return metadata;
    }

// todo - move/refactor, this is temporary 'til linkable/script stuff gets hoisted out of Compunit
}