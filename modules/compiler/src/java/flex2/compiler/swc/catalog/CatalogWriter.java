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

import flex2.compiler.io.VirtualFile;
import flex2.compiler.swc.*;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.tools.VersionInfo;

import java.io.IOException;
import java.io.Writer;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 * Used to write out a catalog.xml within a SWC.  Uses various pieces
 * of a SWC to figure out what needs to be written out.
 * 
 * @author Brian Deitte
 */
public class CatalogWriter
{
    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected Writer writer;
	protected Versions versions;
    protected SwcFeatures swcFeatures;
    protected Collection components, libraries;
    protected Collection files;
    protected boolean forceLibraryVersion1;
    
    public static String ls = System.getProperty("line.separator");

    public CatalogWriter(Writer stream, Versions versions, SwcFeatures swcFeatures, Collection components,
                         Collection libraries, Collection files)
    {
        this.writer = stream;
	    this.versions = versions;
        this.swcFeatures = swcFeatures;
        this.components = components;
        this.libraries = libraries;
        this.files = files;
    
        forceLibraryVersion1 = false;
        if (VersionInfo.LIB_VERSION_1_0.equals(versions.getLibVersion()))
        {
            forceLibraryVersion1 = true;
        }
    }

    public void write() throws IOException
    {
	    assert writer != null;

        writer.write("<?xml version=\"1.0\" encoding =\"utf-8\"?>" + ls);
        writer.write("<swc xmlns=\"http://www.adobe.com/flash/swccatalog/9\">" + ls);

	    if (versions != null)
	    {
		    writeVersions();
	    }
        if (swcFeatures != null)
        {
            writeFeatures();
        }
        if (components != null && components.size() > 0)
        {
            writeComponents();
        }
        if (libraries != null && libraries.size() > 0)
        {
            writeLibraries();
        }
        if (files != null && files.size() > 0)
        {
            writeFiles();
        }

        writer.write("</swc>" + ls);
        writer.flush();
    }

	// changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
	protected void writeVersions() throws IOException
	{
        /*System.out.println("CatalogWriter.writeVersions: versions.getLibVersion = " + versions.getLibVersion() +
                ", versions.getFlexVersion() = " + versions.getFlexVersion() +
                ", versions.getFlexBuild() = " + versions.getFlexBuild());*/

        writer.write("  <versions>" + ls);
        writer.write("    <swc ");
        writeAttribute("version", "" + versions.getLibVersion(), "versions", true, writer);
        writer.write("/>" + ls);
        writer.write("    <flex ");
        writeAttribute("version", "" + versions.getFlexVersion(), "versions", true, writer);
        writeAttribute("build", "" + versions.getFlexBuild(), "versions", true, writer);
        writeAttribute("minimumSupportedVersion", "" + versions.getMinimumVersionString(), "versions", true, writer);
        
        writer.write("/>" + ls);
        writer.write("  </versions>" + ls);
	}

    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected void writeFeatures() throws IOException
    {
        writer.write("  <features>" + ls);
        writeFeature(writer, "feature-debug", swcFeatures.isDebug());
        writeFeature(writer, "feature-script-deps", swcFeatures.isScriptDeps());
        writeFeature(writer, "feature-external-deps", swcFeatures.hasExternalDeps());
        writeFeature(writer, "feature-components", swcFeatures.isComponents());
        writeFeature(writer, "feature-files", swcFeatures.isFiles());
        //writeFeature(writer, "feature-method-deps", methodDeps);
        writer.write("  </features>" + ls);
    }

    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected void writeFeature(Writer writer, String feature, boolean enabled) throws IOException
    {
        if (enabled)
        {
            writer.write("    <" + feature + " />" + ls);
        }
    }

    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected void writeComponents() throws IOException
    {
        writer.write("  <components>" + ls);
        String cls = "component";
        for (Iterator iterator = components.iterator(); iterator.hasNext();)
        {
            SwcComponent comp = (SwcComponent)iterator.next();
            writer.write("    <component ");
            writeAttribute("className", comp.getClassName(), cls, true, writer);
            writeAttribute("name", comp.getName(), cls, false, writer);
            writeAttribute("uri", comp.getUri(), cls, false, writer);
            writeAttribute("icon", comp.getIcon(), cls, false, writer);
            writeAttribute("docs", comp.getDocs(), cls, false, writer);
            writeAttribute("preview", comp.getPreview(), cls, false, writer);
            writer.write(" />" + ls);
        }
        writer.write("  </components>" + ls);
    }

    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected void writeLibraries() throws IOException
    {
        writer.write("  <libraries>" + ls);
        for (Iterator libit = libraries.iterator(); libit.hasNext();)
        {
            SwcLibrary swcLibrary = (SwcLibrary) libit.next();
            writer.write("    <library path=\"" + swcLibrary.getPath() + "\">" + ls);

            for (Iterator extit = swcLibrary.getExterns().iterator(); extit.hasNext(); )
            {
                writer.write("      <ext>" + extit.next() + "</ext>" + ls);
            }

	        HashSet<String> scriptSet = new HashSet<String>();
            for (Iterator scriptit = swcLibrary.getScriptIterator(); scriptit.hasNext(); )
            {
                SwcScript swcScript = (SwcScript) scriptit.next();

	            // sanity check: make sure script names aren't added twice
	            String scriptName = swcScript.getName();
	            if (scriptSet.contains(scriptName))
	            {
		            throw new SwcException.ScriptUsedMultipleTimes(scriptName);
	            }
	            scriptSet.add(scriptName);

                writer.write("      <script ");
                writeAttribute("name", scriptName, "script", true, writer);
                writeAttribute("mod", new Long(swcScript.getLastModified()), "script", true, writer);
                
                Long signatureChecksum = swcScript.getSignatureChecksum();
                if (!forceLibraryVersion1 && signatureChecksum != null)
                {
                    writeAttribute("signatureChecksum", signatureChecksum, "script", false, writer);
                }
                writer.write(">" + ls);

                for (Iterator it = swcScript.getDefinitionIterator(); it.hasNext();)
                {
                    String defname = (String) it.next();
                    writer.write("        <def id=\"" + defname + "\" /> " + ls);
                }

                SwcDependencySet depset = swcScript.getDependencySet();
                for (Iterator typeit = depset.getTypeIterator(); typeit.hasNext();)
                {
                    String type = (String) typeit.next();
                    for (Iterator depit = depset.getDependencyIterator( type ); depit.hasNext();)
                    {
                        String dep = (String) depit.next();
                        writer.write("        <dep id=\"" + dep + "\" type=\"" + type + "\" /> " + ls);
                    }
                }
                writer.write("      </script>" + ls);
            }
    
            writeMetadata(swcLibrary);
            writeDigests(swcLibrary);
            writer.write("    </library>" + ls);
        }
        writer.write("  </libraries>" + ls);
    }

    
    protected void writeMetadata(SwcLibrary swcLibrary) throws IOException
    {
        Set metadata = swcLibrary.getMetadata();
        if (forceLibraryVersion1)
        {
          if (!metadata.isEmpty())
          {
              ThreadLocalToolkit.log(new SwcException.MetadataNotWritten());
          }
          return;     // don't write metadata in a 1.0 library.
        }
        
        if (!metadata.isEmpty())
        {
            writer.write("      <keep-as3-metadata>" + ls);
            for (Iterator iter = metadata.iterator(); iter.hasNext();)
            {
                writer.write("        <metadata ");
                writeAttribute("name", iter.next(), "metadata", true, writer);
                writer.write("/>" + ls);
            }
            writer.write("      </keep-as3-metadata>" + ls);
        }
    }
    
    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected void writeFiles() throws IOException
    {
        writer.write("  <files>" + ls);
        for (Iterator iterator = files.iterator(); iterator.hasNext();)
        {
        	Map.Entry entry = (Map.Entry)iterator.next();
        	String name = (String)entry.getKey();
            VirtualFile vFile = (VirtualFile)entry.getValue();
            if (! (Swc.CATALOG_XML.equals(name) || Swc.LIBRARY_SWF.equals(name)))
            {
                writer.write("    <file path=\"" + name + "\" mod=\"" + vFile.getLastModified() +
                             "\" />" + CatalogWriter.ls);
            }
        }
        writer.write("  </files>" + ls);
    }

    
    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected void writeDigests(SwcLibrary swcLibrary) throws IOException
    {
        Map digestMap = swcLibrary.getDigests();

        if (forceLibraryVersion1)
        {
            if (!digestMap.isEmpty())
            {
                ThreadLocalToolkit.log(new SwcException.DigestsNotWritten());
            }
            return;     // don't write digests in a 1.0 library.
        }
        
    	if (!digestMap.isEmpty())
    	{
   	        writer.write("      <digests>" + ls);

    	    for (Iterator iter = digestMap.values().iterator(); iter.hasNext();)
    	    {
    	        Digest digest = (Digest)iter.next();

    	        writer.write("        <digest ");

    	        writeAttribute("type", digest.getType(), "digest", true, writer);
    	        writeAttribute("signed", Boolean.toString(digest.isSigned()), "digest", true, writer);
    	        writeAttribute("value", digest.getValue(), "digest", true, writer);

    	        writer.write("  />" + ls);

    	    }
            writer.write("      </digests>" + ls);
    	}
        
    }
    
    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected void writeAttribute(String name, Object val, String cls, boolean required, Writer writer)
        throws IOException
    {
        if (val == null)
        {
            if (required)
            {
                throw new SwcException.NoElementValueFound(name, cls);
            }
        }
        else
        {
            writer.write(name + "=\"" + val.toString() + "\" ");
        }
    }

}
