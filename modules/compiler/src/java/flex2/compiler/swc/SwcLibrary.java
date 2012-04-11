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

import flex2.compiler.io.VirtualFile;
import flex2.compiler.swc.catalog.CatalogReader;
import flex2.compiler.util.NameFormatter;
import flex2.linker.SimpleMovie;
import flash.swf.MovieDecoder;
import flash.swf.Frame;
import flash.swf.Movie;

import java.util.Collection;
import java.util.Iterator;
import java.util.Set;
import java.util.List;
import java.util.LinkedList;
import java.util.Map;
import java.util.HashMap;
import java.util.HashSet;
import java.io.InputStream;
import java.io.IOException;

import flash.swf.TagDecoder;
import flash.swf.Tag;
import flash.swf.tags.DoABC;
import flash.swf.tags.DefineTag;

/**
 * This class represents the list of scripts, name to script mappings,
 * definition to symbol mappings, and digests within a SWC.
 *
 * @author Roger Gonzalez
 */
public class SwcLibrary
{
    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected final Swc swc;
    protected final String path;

    // changed next 4 from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected List<SwcScript> scripts;
    protected Map<String, SwcScript> name2script;
    protected Map<String, DefineTag> def2symbol;
    protected boolean parsed;
    private Set<String> externs;
    private String location = null;
    private Set<String> metadata;
    protected Map<String, Digest> digests = new HashMap<String, Digest>();
    
    public SwcLibrary( Swc swc, String path )
    {
        this.swc = swc;
        this.path = path;
        this.scripts = new LinkedList<SwcScript>();
        this.parsed = false;
        this.name2script = new HashMap<String, SwcScript>();
        this.externs = new HashSet<String>();
        this.metadata = new HashSet<String>();
    }

    public Swc getSwc()
    {
        return swc;
    }

    public String getPath()
    {
        return path;
    }

    public String getSwcLocation()
    {
        if (location != null)
        {
            return location;
        }
        else
        {
            return swc.getLocation();
        }
    }

	public long getSwcCreationTime()
	{
		return swc.getLastModified();
	}

    public void clear()
    {
        scripts = null;
        def2symbol = null;
    }

    public Set<String> getExterns()
    {
        return externs;
    }

    public SwcScript addScript( String name, Set<String> defs, SwcDependencySet deps, long modtime,
    							Long signatureChecksum)
    {
        SwcScript script = new SwcScript( this, name, defs, deps, modtime, signatureChecksum );
        scripts.add( script );
        name2script.put( script.getName(), script );
        assert ((name != null) && (name.length() > 0));
        return script;
    }

    public Iterator<SwcScript> getScriptIterator()
    {
        return scripts.iterator();
    }

    public DefineTag getSymbol( String name )
    {
        DefineTag result = null;

        if (def2symbol != null)
        {
        // stagSymbolClasses likes dots, no colons.
        name = name.replace( ':', '.' );
            result = def2symbol.get( name );
    }

        return result;
    }

    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected SwcScript getScript( DoABC doABC )
    {
        assert (doABC.code == Tag.stagDoABC2);
        return name2script.get( doABC.name );
    }

    /**
     * The catalog should have been previously loaded such that we have a set of SwcScript objects.
     * Parse the SWF and associate a DoABC with each, and keep track of the stagSymbolClass values.
     */
    protected void parse()
    {
        if (parsed)
            return;

        VirtualFile swcFile = swc.getArchive().getFile( path );

        if (swcFile == null)
        {
            throw new SwcException.CatalogNotFound();
        }

        Movie movie = new Movie();
        MovieDecoder movieDecoder = new MovieDecoder( movie );
        InputStream inputStream = null;

        try
        {
            inputStream = swcFile.getInputStream();
            TagDecoder tagDecoder = new TagDecoder(inputStream);
            tagDecoder.parse( movieDecoder );
        }
        catch (IOException e)
        {
        }
        finally
        {
            if (inputStream != null)
            {
                try
                {
                    inputStream.close();
                }
                catch (IOException ioException)
                {
                    // ignore.
                }
            }

            // Null out any cached bytes, because we won't need them again.
            swcFile.close();
        }

        int c1 = 0;
        def2symbol = new HashMap<String, DefineTag>();
        for (Iterator frames = movie.frames.iterator(); frames.hasNext(); )
        {
            Frame frame = (Frame) frames.next();
            for (Iterator abcit = frame.doABCs.iterator(); abcit.hasNext(); )
            {
                DoABC doABC = (DoABC) abcit.next();
                SwcScript script = getScript( doABC );
                script.setABC(doABC.abc);
            }

            for (Iterator it = frame.symbolClass.class2tag.entrySet().iterator(); it.hasNext();)
            {
                Map.Entry e = (Map.Entry) it.next();
                String className = (String) e.getKey();
                DefineTag tag = (DefineTag) e.getValue();

                def2symbol.put( className, tag );
            }

            if (Swc.FNORD)  // release SWCs must have magic hash label per frame
            {
                if (frame.label != null)
                {
                    try { c1 = Integer.parseInt( frame.label.label ); } catch (Exception e) {};
                }
                int c2 = SimpleMovie.getCodeHash( frame );

                if (c1 != c2)
                {
                    location = " " + swc.getLocation();
                }
            }
        }
        parsed = true;
    }
    
    void getSymbolClasses(String def, Set<String> symbolClasses)
    {
    	// getSymbol() converts def from a.b:C to a.b.C
    	DefineTag t = getSymbol(def);   
    	HashSet<Tag> visited = new HashSet<Tag>();
    	getReferencedSymbolClasses(t, symbolClasses, visited);
    }
    
    void getReferencedSymbolClasses(Tag t, Set<String> symbolClasses, HashSet<Tag> visited)
    {
    	if (t != null && !visited.contains(t))
    	{
    		visited.add(t);
    		for (Iterator i = t.getReferences(); i != null && i.hasNext(); )
    		{
    		    Tag r = (Tag)i.next();
    			if (r != null)
    			{
					for (Iterator<String> j = def2symbol.keySet().iterator(); j.hasNext(); )
					{
						String className = j.next();
						if (def2symbol.get(className) == r)
						{
							symbolClasses.add(NameFormatter.toColon(className));
						}
					}
    			}
    			getReferencedSymbolClasses(r, symbolClasses, visited);
    		}
    	}	
    }
    
    /**
     * Get the set of metadata to keep when optimizing codes from this library.
     * 
     * @return Set of metadata names of type String.
     */
    public Set<String> getMetadata()
    {
        return metadata;
    }
    
    /**
     * Set the metadata to the given Set.
     * 
     * @param metadata Collection of metadata names of type String.
     */
    public void setMetadata(Set<String> metadata)
    {
        this.metadata = metadata;
    }
    
    /**
     * Add a collection of names to the list of metadata in this library.
     * 
     * @param metadata Collection of metadata names of type String.
     * 
     * @throws NullPointerException if metadata is null
     */
    public void addMetadata(Collection<String> metadata)
    {
       this.metadata.addAll(metadata);
    }

    
    /**
     * Get the digest of a specified library.
     * 
     * @param libPath
     *          name of library path. If in doubt pass in LIBRARY_PATH.
     * @param hashType
     *          type of hash. Only valid choice is Digest.SHA_256.
     * @param isSigned
     *          if true return a signed digest, if false return an unsigned digest.
     * 
     * @return the digest of the specified library. May be null if not digest is found.
     */
    public Digest getDigest(String hashType, boolean isSigned)
    {
        if (hashType == null)
        {
            throw new NullPointerException("hashType may not be null");
        }
        
        return digests.get(CatalogReader.createDigestHashValue(hashType, isSigned));
    }
    
    
    /**
     * Add a new digest to the swc or replace the existing digest if a
     * digest for libPath already exists.
     * 
     * @param libPath name of the library file, may not be null
     * @param digest digest of libPath
     * @throws NullPointerException if libPath or digest are null.
     */
    public void setDigest(Digest digest)
    {
        if (digest == null)
        {
            throw new NullPointerException("setDigest:  digest may not be null");  // $NON-NLS-1$
        }

        digests.put(CatalogReader.createDigestHashValue(digest.getType(), 
                                                        digest.isSigned()), 
                                                        digest);
    }
    
    /**
     * 
     * @return all the digests in this swc. May be empty, but not null.
     */
    public Map<String, Digest> getDigests()
    {
        return digests;
    }
    
    
    /**
     * Set all the digest of the library. Typically this is called after reading from
     * all the digests from catalog.xml.
     *  
     * @param digests - Map of digests in this swc. 
     */
    public void setDigests(Map<String, Digest> digests)
    {
        this.digests = digests;
    }
    
    
}
