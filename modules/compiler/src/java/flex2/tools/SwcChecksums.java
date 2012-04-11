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

import java.io.File;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import flash.util.Trace;
import flex2.compiler.CompilationUnit;
import flex2.compiler.CompilerSwcContext;
import flex2.compiler.Source;
import flex2.compiler.config.ConfigurationBuffer;
import flex2.compiler.io.LocalFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.swc.SwcScript;
import flex2.compiler.util.QName;

/**
 * A value object used to store checksums during an incremental
 * compilation.
 */
public class SwcChecksums
{
    /**
     * Used for incremental builds to verify the stored cache.
     * checksums[0] - checksum
     * checksums[1] = cmdChecksum - must be set with expected value before loading cache
     * checksums[2] = linkChecksum
     * checksums[3] = swcChecksum
     */    
    int checksums[];
    
   /**
     * Map definition to signature checksum.
     */
    private Map<QName, Long> swcDefSignatureChecksums = new HashMap<QName, Long>(); // Map<QName, Long>
    
    /**
     * Map swc file to checksum (modification timestamp).
     */
    private Map<String, Long> swcFileChecksums = new HashMap<String, Long>(); // Map<String, Long>
    
    /**
     * Map archive files to checksum (modification timestamp).
     */
    private Map<String, Long> archiveFileChecksums = new HashMap<String, Long>(); // Map<String, Long>

    private CompilerSwcContext swcContext;
    private ConfigurationBuffer cfgbuf;
    
    /**
     * If true, checksum the signatures in the swc rather than the mod time on 
     * the entire swc file.  This can save recompiles if there is a change but 
     * the signature doesn't change.
     */
    private boolean isSwcChecksumEnabled;
    
    protected SwcChecksums(CompilerSwcContext swcContext, ConfigurationBuffer cfgbuf, 
            ToolsConfiguration configuration)
    {
        this.swcContext = swcContext;   
        this.cfgbuf = cfgbuf;
        this.isSwcChecksumEnabled = configuration.isSwcChecksumEnabled();
        
        // This array is used to load and persist the cache for the incremental 
        // compile.  Initialize it for the load.
        checksums = new int[4];
        checksums[0] = 0;
        checksums[1] = cfgbuf.checksum_ts();
        checksums[2] = cfgbuf.link_checksum_ts();
        checksums[3] = swcContext.checksum();
    }
    
    /**
     * Save the compiler units signature checksums.
     * These will be used by the next compilation to determine if we
     * can do an incremental compiler or if a full recompilation is required.
     * 
     * @param units - compilation units, may be null
     */
    protected void saveSignatureChecksums(List<CompilationUnit> units)
    {
        if (!isSwcChecksumEnabled)
        {
            swcDefSignatureChecksums = null;
            return;
        }
        
        if (units != null)
        {
            swcDefSignatureChecksums = new HashMap<QName, Long>();
            for (CompilationUnit unit : units)
            {
                Source source = unit == null ? null : unit.getSource();
                if (source != null && source.isSwcScriptOwner() && !source.isInternal())
                {
                    addSignatureChecksumToData(unit); 
                }                
            }
          }
    }

    /**
     * Save the swc file checksums.
     */
    protected void saveSwcFileChecksums()
    {
        if (!isSwcChecksumEnabled)
        {
            swcFileChecksums = null;
            return;
        }
 
        for (Map.Entry<String, VirtualFile> entry: swcContext.getFiles().entrySet())
        {
            String filename = entry.getKey();
            VirtualFile file = entry.getValue();
            swcFileChecksums.put(filename, new Long(file.getLastModified()));             
        }

        for (VirtualFile themeStyleSheet : swcContext.getThemeStyleSheets())
        {
            swcFileChecksums.put(themeStyleSheet.getName(),
                                 new Long(themeStyleSheet.getLastModified()));
        }
    }

    /**
     * Save the checksums for the resources that get written to the swc.  These
     * may not have compile dependencies so mods won't get detected during
     * the compile phase.
     * 
     * @param m - Map(filename, VirtualFile) of resources
     */
    protected void saveArchiveFilesChecksums(Map<String, VirtualFile> m)
    {
        if (!isSwcChecksumEnabled)
        {
            swcFileChecksums = null;
            return;
        }
        
        for (Map.Entry<String, VirtualFile> entry : m.entrySet())
        {
            VirtualFile file = entry.getValue();
            archiveFileChecksums.put(file.getName(), new Long(file.getLastModified()));            
        }        
   }

    /**
     * Save the checksums that are going to be persisted to the store file.
     * 
     * @param units - compilation units
     */
    protected void saveChecksums(List<CompilationUnit> units)
    {
        saveSwcFileChecksums();
        saveSignatureChecksums(units);
        
        // Ensure this is current.
        updateChecksum();
    }
    
    /**
     * Loop thru the saved signature and file checksums in the persisted data 
     * and compare them with the signature and file checksums in the swc context.
     * 
     * @return true if all the signature and file checksums in cached data match the checksums
     *         in the swc context.
     */
    protected boolean isRecompilationNeeded(int[] loadedChecksums)
    {
        // Now that the load is done, which can change swcDefSignatureChecksums,
        // recalculate the checksum and see if it matches the loaded one from the
        // cache.
        this.checksums[0] = calculateChecksum();
        
        // if the checksum from last time and the current checksum do not match,
        // then we need to recompile.
        if (this.checksums[0] != loadedChecksums[0])
        {
            if (Trace.swcChecksum)
            {
                Trace.trace("isRecompilationNeeded: calculated checksum differs from last checksum, recompile");                
            }
            return true;
        }
        
        // if we got here and swc checksums are disabled, then
        // the checksums are equal and a recompilation is not needed.
        // Otherwise continue on and compare the swc checksums.
        if (!isSwcChecksumEnabled)
        {
            if (Trace.swcChecksum)
            {
                Trace.trace("isRecompilationNeeded: checksums equal, swc-checksum disabled, incremental compile");              
            }
            return false;
        }

        Map<QName, Long> signatureChecksums = swcDefSignatureChecksums;
        if (signatureChecksums == null)
        {
            if (Trace.swcChecksum)
            {
                Trace.trace("isRecompilationNeeded: checksums equal, signatureChecksums is null, incremental compile");             
            }
        }
        else
        {
            for (Map.Entry<QName, Long> entry : signatureChecksums.entrySet())
            {                
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
                else 
                {
                    // dataSignatureChecksum should never be null, but if it is then recompile.
                    return true;
                }
            }
        }
 
        boolean result = !areSwcFileChecksumsEqual();

        if (Trace.swcChecksum)
        {
            Trace.trace("isRecompilationNeeded: " + (result ? "recompile" : "incremental compile"));                
        }
        
        return result;
    }

    /** 
     * If the link timestamp is different, or the resources in the swc have been
     * updated, a relink is necessary.
     * 
     * @return true if relink is needed.
     */
    protected boolean isRelinkNeeded(int[] loadedChecksums)
    {
        // If the link checksum from last time and the current checksum do not match,
        // then we need to relink.
        if (this.checksums[2] != loadedChecksums[2])
        {
            if (Trace.swcChecksum)
            {
                Trace.trace("isRecompilationNeeded: calculated checksum differs from last checksum, relink");                
            }
            return true;
        }

        // Verify that the timestamps on the archive files haven't changed.
        boolean result = !areArchiveFileChecksumsEqual();

        if (Trace.swcChecksum)
        {
            Trace.trace("isRelinkNeeded: " + result);                
        }
        
        return result;
     }
     
    /**
     * Add all top level definitions.
     * @param unit
     */
    private void addSignatureChecksumToData(CompilationUnit unit)
    {
        Long signatureChecksum = unit.getSignatureChecksum();
        if (signatureChecksum == null)
        {
            SwcScript script = (SwcScript) unit.getSource().getOwner();
            signatureChecksum = new Long(script.getLastModified());
        }

        if (swcDefSignatureChecksums != null)
        {
            for (Iterator<QName> iter = unit.topLevelDefinitions.iterator(); iter.hasNext();)
            {
                QName qname = iter.next();
                swcDefSignatureChecksums.put(qname, signatureChecksum);
            }
        }
    }

    
    /**
     * Test if the files in the compiler swc context have changed since the last compile.
     * 
     * @return true it the swc files compiled with last time are the same as this time.
     */
    private boolean areSwcFileChecksumsEqual()
    {
        if (swcFileChecksums == null) 
        {
            if (Trace.swcChecksum)
            {
                Trace.trace("areSwcFileChecksumsEqual: no file checksum map, not equal");               
            }
            
            return false;
        }

        Map<String, VirtualFile> swcFiles = swcContext.getFiles();

        for (VirtualFile themeStyleSheet : swcContext.getThemeStyleSheets())
        {
            swcFiles.put(themeStyleSheet.getName(), themeStyleSheet);
        }

        Set<Map.Entry<String, Long>> dataSet = swcFileChecksums.entrySet();

        if (swcFiles.size() < dataSet.size())
        {
            if (Trace.swcChecksum)
            {
                Trace.trace("areSwcFileChecksumsEqual: less files than before, not equal");             
            }
            
            return false;           
        }
        
        for (Map.Entry<String, Long> entry : dataSet)
        {           
            String filename = entry.getKey();
            Long dataFileLastModified = entry.getValue();
            Long swcFileLastModified = null;
            VirtualFile swcFile = swcFiles.get(filename);
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
        
        if (Trace.swcChecksum)
        {
            Trace.trace("areSwcFileChecksumsEqual: equal");
        }
        
        return true;
    }
    
    /**
     * Test if the archive files in the swc have changed since the last compile.
     * 
     * @return true it the swc files compiled with last time are the same as this time.
     */
    private boolean areArchiveFileChecksumsEqual()
    {
        if (swcFileChecksums == null) 
        {
            if (Trace.swcChecksum)
            {
                Trace.trace("areArchiveFileChecksumsEqual: no file checksum map, not equal");               
            }
            
            return false;
        }

        Set<Map.Entry<String, Long>> dataSet = archiveFileChecksums.entrySet();
        
        for (Map.Entry<String, Long> entry : dataSet)
        {           
            String filename = entry.getKey();
            Long dataFileLastModified = entry.getValue();
            Long localFileLastModified = null;

            LocalFile localFile = new LocalFile(new File(filename));
            localFileLastModified = new Long(localFile.getLastModified());
            
            if (!dataFileLastModified.equals(localFileLastModified))
            {
                if (Trace.swcChecksum)
                {
                    Trace.trace("areArchiveFileChecksumsEqual: not equal");
                    Trace.trace("filename = " + filename);
                    Trace.trace("last modified1 = " + dataFileLastModified);
                    Trace.trace("last modified2 = " + localFileLastModified);
                }

                return false;
            }
        }
        
        if (Trace.swcChecksum)
        {
            Trace.trace("areArchiveFileChecksumsEqual: equal");
        }
        
        return true;
    }

    /**
     * Calculate the data checksum on configuration buffer and the
     * swcContext.  If the configuration changes the checksum changes.
     *  
     * @return checksum
     */
     protected int calculateChecksum()
     {
         // Checksum on the oonfiguration buffer.
         int checksum = cfgbuf.checksum_ts();
         
         // If swc checksums are disabled or there are no checksums to compare, 
         // then include the swc timestamp as part of the checksum.
         if (!isSwcChecksumEnabled ||
                 swcDefSignatureChecksums == null ||
                 swcDefSignatureChecksums.size() == 0)
         {
             checksum += swcContext.checksum();
         }
         
         return checksum;
     }
        
//     protected int getChecksum()
//     {
//        return checksums[0];
//     }

    /**
     * Set the checksum with the recalculated value.
     */
    protected void updateChecksum()
    {
        checksums[0] = calculateChecksum();
    }

    /**
     * @return a copy of the stored checksum array
     */
    protected int[] copy()
    {
        int[] copy = (int[])this.checksums.clone();
        return copy;
    }
    
    /**
     * 
     * @return array of checksums
     */
    protected int[] getChecksums()
    {
        return checksums;
    }

    protected Map<QName, Long> getSwcDefSignatureChecksums()
    {
        return swcDefSignatureChecksums;
    }

    protected Map<String, Long> getSwcFileChecksums()
    {
        return swcFileChecksums;
    }
    
    protected Map<String, Long> getArchiveFileChecksums()
    {
        return archiveFileChecksums;
    }
}
