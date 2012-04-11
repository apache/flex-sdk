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

package flex2.compiler.swc.catalog;

import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.swc.*;
import flex2.compiler.util.NameFormatter;
import flex2.tools.VersionInfo;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

/**
 * Used to read in the catalog.xml from a SWC.
 *
 * @author Brian Deitte
 */
public class CatalogReader
{
    private InputStream stream;
    protected Swc swc;
    private SwcArchive archive;

	// changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
	protected Versions versions = new Versions();
    protected SwcFeatures swcFeatures = new SwcFeatures();
    protected Map<String, SwcComponent> components = new HashMap<String, SwcComponent>();
    protected Map<String, SwcLibrary> libraries = new HashMap<String, SwcLibrary>();
    protected Map<String, SwcFile> files = new HashMap<String, SwcFile>();
    protected Map<String, Digest> digests = new HashMap<String, Digest>();		// keyed by library path

    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    CatalogReadElement defaultReadElement = new SwcReader();
	protected VersionReader versionReader = new VersionReader();
    protected FeatureReader featureReader = new FeatureReader();
    protected ComponentReader componentReader = new ComponentReader();
    protected LibraryReader libraryReader = new LibraryReader();
    protected ScriptReader scriptReader = new ScriptReader();
    protected FilesReader filesReader = new FilesReader();
    protected DigestReader digestReader = new DigestReader();
    protected MetadataReader metadataReader = new MetadataReader();
    protected UnknownReader unknownReader = new UnknownReader();

    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected Boolean isNewerLibVersion;		// cache if this catalog version is new than the code
    protected boolean isLibraryVersion_1_0;      // true if library is version 1.0
    
    
    public CatalogReader(InputStream stream, Swc swc, SwcArchive archive)
    {
        this.stream = stream;
        this.swc = swc;
        this.archive = archive;
    }

    public void read()
            throws IOException, ParserConfigurationException, SAXException
    {
        if (stream == null)
        {
            throw new SwcException.NullCatalogStream();
        }

        CatalogHandler handler = new CatalogHandler(this);
        SAXParserFactory factory = SAXParserFactory.newInstance();
        factory.setNamespaceAware(true);

        SAXParser parser = factory.newSAXParser();
        parser.parse(stream, handler);
        handler.clear();
    }

	public Versions getVersions()
	{
	    return versions;
	}

    public SwcFeatures getFeatures()
    {
        return swcFeatures;
    }

    public Map<String, Digest> getDigests()
    {
    	return digests;
    }

    public Map<String, SwcComponent> getComponents()
    {
        return components;
    }

    public Map<String, SwcLibrary> getLibraries()
    {
        return libraries;
    }

    public Map<String, SwcFile> getFiles()
    {
        return files;
    }


    /**
     * 
     * @param container - name of container element
     * @param current - name of the current record
     */
    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected void handleUnknownRecord(String container, String current) 
    {
        // If this is a version we know about then we should understand all
    	// the items. If this is a version we don't know about, then allow
    	// there to be unknown records. We will assume that we can do what
    	// we need to do with the information we have.
    	String libVersion = versions.getLibVersion();
    	if (libVersion == null || !IsNewerLibVersion(libVersion))
    	{
            throw new SwcException.UnknownElementInCatalog(current, container);            		
    	}    	
    }

    class SwcReader extends CatalogReadElement
    {
        public CatalogReadElement readElement(ReadContext context)
        {
            String current = context.getCurrentName();
	        if ("versions".equals(current))
	        {
		        return versionReader;
	        }
            else if ("features".equals(current))
            {
                return featureReader;
            }
            else if ("components".equals(current))
            {
                return componentReader;
            }
            else if ("files".equals(current))
            {
                return filesReader;
            }
            else if ("libraries".equals(current))
            {
                return libraryReader;
            }
            else if ("swc".equals(current))
            {
                return this;
            }
            else if ("digests".equals(current))
            {
                return digestReader;
            }
            else
            {
            	handleUnknownRecord("swc", current);
            	return unknownReader;
            }
        }
    }

    
    
	class VersionReader extends CatalogReadElement
	{
	    public CatalogReadElement readElement(ReadContext context)
	    {
		    String current = context.getCurrentName();
		    if ("flex".equals(current))
		    {
		        Attributes attrib = context.getCurrentAttributes();
		        versions.setFlexVersion(readAttribute("version", attrib, true));
			    versions.setFlexBuild(readAttribute("build", attrib, false));
			    versions.setMinimumVersion(readAttribute("minimumSupportedVersion", attrib, false));
			    
				/*System.out.println("VersionReader.readElement: versions.getFlexVersion() = " + versions.getFlexVersion() +
						", versions.getFlexBuild() = " + versions.getFlexBuild());*/

			}
			else if ("swc".equals(current))
			{
				Attributes attrib = context.getCurrentAttributes();
				versions.setLibVersion(readAttribute("version", attrib, true));

                isLibraryVersion_1_0 = (VersionInfo.LIB_VERSION_1_0.equals(versions.getLibVersion()));

                //System.out.println("VersionReader.readElement: versions.getLibVersion = " + versions.getLibVersion());

			}
		    return this;
	    }
	}

    class FeatureReader extends CatalogReadElement
    {
        public CatalogReadElement readElement(ReadContext context)
        {
            // TODO - centralize known feature names
            String name = context.getCurrentName();
            if ("feature-debug".equals(name))
            {
                swcFeatures.setDebug(true);
            }
            else if ("feature-external-deps".equals(name))
            {
                swcFeatures.setExternalDeps(true);
            }
            else if ("feature-script-deps".equals(name))
            {
                swcFeatures.setScriptDeps(true);
            }
            else if ("feature-components".equals(name))
            {
                swcFeatures.setComponents(true);
            }
            else if ("feature-files".equals(name))
            {
                swcFeatures.setFiles(true);
            }
            //else if ("feature-method-deps".equals(name))
            //{
            //    methodDeps = true;
            //}
            else
            {
	            // We only throw an exception if an unknown feature is required.
	            // Otherwise, it is simply ignored
                Attributes attrib = context.getCurrentAttributes();
	            String req = attrib.getValue("required");
	            if (req != null && req.equalsIgnoreCase("true"))
	            {
		            throw new SwcException.UnsupportedFeature(name);
	            }
            }
            return this;
        }
    }

    class ComponentReader extends CatalogReadElement
    {
        public CatalogReadElement readElement(ReadContext context)
        {
            String current = context.getCurrentName();
            if ("component".equals(current))
            {
                SwcComponent comp = new SwcComponent();
                Attributes attrib = context.getCurrentAttributes();
                comp.setClassName(readAttribute("className", attrib, true));
                comp.setName(readAttribute("name", attrib, false));
                comp.setUri(readAttribute("uri", attrib, false));
                comp.setIcon(readAttribute("icon", attrib, false));
                comp.setDocs(readAttribute("docs", attrib, false));
                comp.setPreview(readAttribute("preview", attrib, false));
                comp.setLocation(swc.getLocation());
                components.put(comp.getClassName(), comp);
                return this;
            }
            else
            {
            	handleUnknownRecord("components", current);
            	return this;
            }
        }
    }

    class LibraryReader extends CatalogReadElement
    {
        public CatalogReadElement readElement(ReadContext context)
        {
            String current = context.getCurrentName();
            if ("library".equals(current))
            {
                String path = readAttribute("path", context.getCurrentAttributes(), true);
                SwcLibrary lib = new SwcLibrary( swc, path );
                libraries.put(path, lib);

                scriptReader.clear();
                scriptReader.currentLibrary = lib;
                return scriptReader;
            }
            else
            {
            	handleUnknownRecord("libraries", current);
            	return this;
            }
            
        }
        
        public void endElement(ReadContext context)
        {
            /* backward-compatibility: if the swc version is less than 1.2, then add the 
             * "big 5" default metadata to the library. 
             * 
             */
            if ("library".equals(context.getCurrentName()) &&
                VersionInfo.compareVersions(versions.getLibVersion(), 
                                            VersionInfo.LIB_VERSION_1_2, 
                                            false) < 0)
            {
                assert scriptReader.currentLibrary != null;
                scriptReader.currentLibrary.addMetadata(Arrays.asList(StandardDefs.DefaultAS3Metadata));
            }
        }


        
    }

    class ScriptReader extends CatalogReadElement
    {
        public SwcLibrary currentLibrary;
        private String name;
        private long modtime;
        private Long signatureChecksum;
        private Set<String> defs;
        private SwcDependencySet depSet;
       
        public CatalogReadElement readElement(ReadContext context)
        {
            String current = context.getCurrentName();
            if ("script".equals(current))
            {
                name = readAttribute("name", context.getCurrentAttributes(), true);
                modtime = readAttributeLong("mod", context.getCurrentAttributes(), true).longValue();
                signatureChecksum = readAttributeLong("signatureChecksum", context.getCurrentAttributes(), false);
            }
            else if ("def".equals(current))
            {
                String id = readAttribute("id", context.getCurrentAttributes(), true);
                
                // convert the id to colon format because Flash CS3 SWC files have two ids
                // defined for each script. One id is in colon format (good), the other is
                // in dot format (bad). Since defs is a Set the two ids will end up as
                // just one def. This only needs to be done for version 1.0 libraries.
                defs.add(isLibraryVersion_1_0 ? NameFormatter.toColon(id) : id);
            }
            else if ("dep".equals(current))
            {
                String id = readAttribute("id", context.getCurrentAttributes(), true);
                String type = readAttribute("type", context.getCurrentAttributes(), false);
                depSet.addDependency(type, id);
            }
            else if ("keep-as3-metadata".equals(current)) 
            {
                metadataReader.setCurrentLibrary(currentLibrary);
                return metadataReader;
            }
            else if ("digests".equals(current)) {
                digestReader.setCurrentLibrary(currentLibrary);
                return digestReader;
            }
            else if ("ext".equals(current))
            {
                // we just toss these for now.
            }
            else
            {
            	handleUnknownRecord("script", current);
            }
            return this;
        }

        public void endElement(ReadContext context)
        {
            if ("script".equals(context.getCurrentName()))
            {
                assert currentLibrary != null;
                assert name != null;
                currentLibrary.addScript(name, defs, depSet, modtime, signatureChecksum);
                clear();
            }
        }

        public void clear()
        {
            scriptReader.name = null;
            scriptReader.modtime = -1;
            scriptReader.defs = new TreeSet<String>();
            scriptReader.depSet = new SwcDependencySet();
        }
    }

    class FilesReader extends CatalogReadElement
    {
        public CatalogReadElement readElement(ReadContext context)
        {
            String current = context.getCurrentName();
            if ("file".equals(current))
            {
                String path = readAttribute("path", context.getCurrentAttributes(), true);
                Long mod = readAttributeLong("mod", context.getCurrentAttributes(), true);
                // C: catalog.xml and the RSL directory may be out-of-sync, i.e. catalog.xml says the file
                //    is there but actually it does not.
                if (!(archive instanceof SwcDirectoryArchive) || ((SwcDirectoryArchive) archive).exists(path))
                {
                    SwcFile file = new SwcFile(path, mod.longValue(), swc, archive);
                    files.put(path, file);
                }
                return this;
            }
            else
            {
               	handleUnknownRecord("files", current);
               	return this;
            }
        }
    }

    class DigestReader extends CatalogReadElement
    {
        private SwcLibrary currentLibrary;
        
        public CatalogReadElement readElement(ReadContext context)
        {
            String current = context.getCurrentName();
            if ("digest".equals(current))
            {
    	        Attributes attrib = context.getCurrentAttributes();
    		    String signedAttrib = readAttribute("signed", attrib, false);
    		    boolean signed = Boolean.TRUE.toString().equals(signedAttrib);
    		    
    		    Digest digest = new Digest();
    		    digest.setSigned(signed);
    		    digest.setType(readAttribute("type", attrib, true));
    		    digest.setValue(readAttribute("value", attrib, true));

                digests.put(createDigestHashValue(digest.getType(), digest.isSigned()),
                			digest);
                
            	return this;
            }
            else
            {
              	handleUnknownRecord("digests", current);
              	return this;
            }
        }
        
        public void endElement(ReadContext context)
        {
            if ("digests".equals(context.getCurrentName()))
            {
                // TODODJL: Remove this code after Library Version 1.2 has been out for a few weeks.
                if (VersionInfo.LIB_VERSION_1_1.equals(versions.getLibVersion()))
                {
                    SwcLibrary lib = libraries.get(Swc.LIBRARY_SWF);
                    if (lib != null)
                    {
                        lib.setDigests(digests);
                        digests = new HashMap<String, Digest>();
                    }    
                    return;
                }    
                
                assert currentLibrary != null;
                assert digests != null;
                if (digests != null)
                {
                    currentLibrary.setDigests(digests);
                    digests = new HashMap<String, Digest>();                    
                }
                
            }
       }

        public SwcLibrary getCurrentLibrary()
        {
            return currentLibrary;
        }

        public void setCurrentLibrary(SwcLibrary currentLibrary)
        {
            this.currentLibrary = currentLibrary;
        }


    }
      
    class MetadataReader extends CatalogReadElement
    {
        private SwcLibrary currentLibrary;
        private Set<String> metadata = new HashSet<String>();
        
        public CatalogReadElement readElement(ReadContext context)
        {
            String current = context.getCurrentName();
            
            if ("metadata".equals(current))
            {
                String name = readAttribute("name", context.getCurrentAttributes(), true);
                metadata.add(name);
            }
            else
            {
                handleUnknownRecord("metadata", current);
            }
            
            return this;
        }
        
        public void endElement(ReadContext context)
        {
            if ("keep-as3-metadata".equals(context.getCurrentName()))
            {
                assert currentLibrary != null;
                assert metadata != null;
                if (metadata != null)
                {
                    currentLibrary.addMetadata(metadata);
                    metadata = new HashSet<String>();                    
                }
            }
       }

        public SwcLibrary getCurrentLibrary()
        {
            return currentLibrary;
        }

        public void setCurrentLibrary(SwcLibrary currentLibrary)
        {
            this.currentLibrary = currentLibrary;
        }

    }

    
    class UnknownReader extends CatalogReadElement
    {
        public CatalogReadElement readElement(ReadContext context)
        {
        	return this;
        }
    }
     
    public static String readAttribute(String name, Attributes attributes, boolean required)
    {
        String val = attributes.getValue(name);
        if (val == null && required)
        {
            throw new SwcException.NoElementValue(name);
        }
        return val;
    }

    public static Long readAttributeLong(String name, Attributes attributes, boolean required)
    {
        Long val = null;
        String str = readAttribute(name, attributes, required);
        if (str != null)
        {
            val = new Long(str);
        }
        return val;
    }
    
    
    /**
     * Create a hash value to look up a digest in the Map of digest values.
     * 
     * @param hashType
     * 			type of hash used to create the digest, pass Digest.SHA_256.
     * @param isSigned
     * 	
     * @return Object of type String
     */
    public static String createDigestHashValue(String hashType, boolean isSigned) 
    {
    	StringBuilder sb = new StringBuilder(hashType);
    	sb.append(isSigned);
    	return sb.toString();
    }
    
    
    /**
     * Test if this catalog version is newer than the version compiled into this code.
     * Both the major and minor versions are compared in the test.
     * 
     * @param libVersion
     * 				catalog version
     * @return true if the catalog version is newer than the version compiled into this code.
     */
    private boolean IsNewerLibVersion(String libVersion) 
    {
    	if (isNewerLibVersion == null)
    	{
    		isNewerLibVersion = new Boolean(VersionInfo.IsNewerLibVersion(libVersion, false));
    	}
    	
    	return isNewerLibVersion.booleanValue();
    }
}
