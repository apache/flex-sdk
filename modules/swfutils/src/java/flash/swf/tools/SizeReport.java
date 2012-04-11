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

package flash.swf.tools;

import java.util.*;

/**
 * Helper class generally used by TagEncoderReporter to collect size
 * related metrics for a given SWF and to generate an optional XML
 * report of the summarized data.
 *
 * @author Corey Lucier
 */
public class SizeReport
{
    private int size;
    private int currentFrame = 1;
    private int compressedSize;
    private Map<Integer, String> symbols;
    private Map<Integer, DefinitionData> definitionTypes;
    private int prevFrameStart = 0;
    private String prevFrameLabel = null;
        
    // DefinitionEntry Types
    public static final int BINARY = 0;
    public static final int BITMAP = 1;
    public static final int FONT = 2;
    public static final int FRAME = 3;
    public static final int FRAME_DATA = 4;
    public static final int HEADER_DATA = 5;
    public static final int SCRIPT = 6;
    public static final int SHAPE = 7;
    public static final int SOUND = 8;
    public static final int SPRITE = 9;
    public static final int VIDEO = 10;
    
    public SizeReport()
    {
        symbols = new HashMap<Integer,String>();
        definitionTypes = new HashMap<Integer, DefinitionData>();
        registerDefinitionType(BINARY, "binaryData", "data",
            "SWF, Pixel Bender, or other miscellaneous embed data.");
        registerDefinitionType(BITMAP, "bitmaps", "bitmap",
           "defineBits, definebitsJPEG2/3/4, or defineBitsLossless/2");
        registerDefinitionType(FONT, "fonts", "font",
           "defineFont/2/3/4.");
        registerDefinitionType(FRAME, "frames", "frame",
           "Cumulative frame size summary.");
        registerDefinitionType(FRAME_DATA, "frameData", "tag",
           "Additional frame tags (symbolClass, exportAssets, showFrame, etc).");
        registerDefinitionType(HEADER_DATA, "headerData", "data",
           "Header data (SWF attributes, product info, markers, etc.)");
        registerDefinitionType(SCRIPT, "actionScript", "abc",
            "Actionscript code and constant data.");
        registerDefinitionType(SHAPE, "shapes", "shape",
            "defineShape/2/3/4.");
        registerDefinitionType(SOUND, "sounds", "sound",
            "defineSound.");
        registerDefinitionType(SPRITE, "sprites", "sprite",
            "defineSprite.");
        registerDefinitionType(VIDEO, "videos", "video",
            "defineVideoStream.");
    }
    
    public String generate()
    {
        StringBuilder buffer = new StringBuilder( 2048 );
        buffer.append( "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
        buffer.append( "<report>\n" );
        {
            // Cumulative Size
            buffer.append( "  <swf size=\"");
            buffer.append(size);
            buffer.append("\" compressedSize=\"");
            buffer.append(compressedSize);
            buffer.append("\">\n");
            
            dumpDefinitionType(buffer, HEADER_DATA, "    ");
            dumpDefinitionType(buffer, FRAME, "    "); 
            dumpDefinitionType(buffer, SCRIPT, "    ");
            dumpDefinitionType(buffer, FONT, "    ");
            dumpDefinitionType(buffer, SPRITE, "    ");
            dumpDefinitionType(buffer, SHAPE, "    ");
            dumpDefinitionType(buffer, BITMAP, "    ");
            dumpDefinitionType(buffer, SOUND, "    ");
            dumpDefinitionType(buffer, VIDEO, "    ");
            dumpDefinitionType(buffer, BINARY, "    ");
            dumpDefinitionType(buffer, FRAME_DATA, "    ");
            
            buffer.append( "  </swf>\n" );
        }
        buffer.append( "</report>" );
        return buffer.toString();
    }
    
    public void setSize(int value)
    {
        size = value;
    }
    
    public void setCompressedSize(int value)
    {
        compressedSize = value;
    }
    
    private void dumpDefinitionType(StringBuilder buffer, int type, String indent)
    {
        DefinitionData data = definitionTypes.get(type);
        List<DefinitionEntry> definitions = data.definitions;
        
        if (type != FRAME)
        {
            // Sort definitions largest to smallest.
            Collections.sort(definitions, new DefinitionComparator());
        }
        
        if (definitions.size() > 0) 
        {
            buffer.append( "\n" + indent + "<!-- " + data.description + " -->\n" );
            buffer.append( indent + "<" + data.pluralMoniker + " " );
            buffer.append( "totalSize=\"" );
            buffer.append(data.totalSize);
            buffer.append( "\">\n" );
            for (DefinitionEntry n : definitions) 
            {               
                buffer.append( indent + "  <" + data.singularMoniker + " ");
                String name = (type == FRAME || type == SCRIPT) ? n.stringData : symbols.get(n.id);
                if (name != null)
                {
                    buffer.append( "name=\"");
                    buffer.append(name);
                    buffer.append( "\" ");
                }
                if (type == FONT && n.stringData != null)
                {
                    buffer.append( "fontName=\"");
                    buffer.append(n.stringData);
                    buffer.append( "\" ");
                }
                else if ((type == HEADER_DATA || type == FRAME_DATA) && n.stringData != null)
                {
                    buffer.append( "type=\"");
                    buffer.append(n.stringData);
                    buffer.append( "\" ");
                }
                buffer.append( "size=\"");
                buffer.append(n.size);
                
                if (n.frame != -1 && type != HEADER_DATA)
                {
                    buffer.append( "\" ");
                    buffer.append( "frame=\"");
                    buffer.append(n.frame);
                }
                
                buffer.append("\"/>\n");
            }
            buffer.append( indent + "</" + data.pluralMoniker + ">\n" );
        }
    }
        
    public void startEntry(int type, int startOffset, int id, String stringData) 
    {
        if (type == FRAME)
        {
            prevFrameStart = startOffset;
            prevFrameLabel = stringData;
        }
        else
        {
            DefinitionData data = definitionTypes.get(type);
            DefinitionEntry entry = new DefinitionEntry();
            entry.stringData = stringData;
            entry.size = startOffset;
            entry.id = id;
            entry.frame = currentFrame;
            data.definitions.add(entry);
        }
    }
        
    public void endEntry(int type, int endOffset, String stringData) 
    {
        if (type == FRAME)
        {
            DefinitionData data = definitionTypes.get(type);
            DefinitionEntry entry = new DefinitionEntry();
            entry.size = endOffset - prevFrameStart;
            entry.stringData = prevFrameLabel;
            entry.frame = currentFrame;
            data.definitions.add(entry);
            data.totalSize += entry.size; 
            currentFrame++;
        }
        else
        {
            if (type == HEADER_DATA)
            {
                // In the case where we have no explicit frame label keep track
                // of the start of our frame.
                prevFrameStart = endOffset;
            }
                
            DefinitionData data = definitionTypes.get(type);
            DefinitionEntry entry = data.definitions.get(data.definitions.size() - 1);
            entry.size = endOffset - entry.size;
            data.totalSize += entry.size;
        }
    }
    
    public void addEntry(int type, int id, int size, String stringData) 
    {
        DefinitionData data = definitionTypes.get(type);
        DefinitionEntry entry = new DefinitionEntry();
        data.totalSize += size;
        entry.stringData = stringData;
        entry.size = size;
        entry.id = id;
        entry.frame = currentFrame;
        data.definitions.add(entry);
    }
        
    public void startEntry(int type, int startOffset, int id) 
    {
        startEntry(type, startOffset, id, null);
    }
    
    public void endEntry(int type, int endOffset) 
    {
        endEntry(type, endOffset, null);
    }
        
    public void addEntry(int type, int id, int size) 
    {
        addEntry(type, id, size, null);
    }
    
    public void addSymbol(String name, int id)
    {
        symbols.put(id, name);
    }
    
    private void registerDefinitionType(int type, String pluralMoniker, String singularMoniker, String description)
    {
        definitionTypes.put(type, new DefinitionData(pluralMoniker, singularMoniker, description));
    }
    
    // Private helper classes used to keep track of each definition by type as
    // well as cumulative size for each type.
    
    private class DefinitionEntry
    {
        public Integer size;
        public Integer id;
        public String stringData;
        public Integer frame = -1;
    }
    
    private class DefinitionData
    {
        public DefinitionData(String pluralMoniker, String singularMoniker, String description)
        {
            this.singularMoniker = singularMoniker;
            this.pluralMoniker = pluralMoniker;
            this.description = description;
            definitions = new ArrayList<DefinitionEntry>();
        }
        
        public List<DefinitionEntry> definitions;
        public int totalSize;
        public String singularMoniker;
        public String pluralMoniker;
        public String description;
    }
    
    private class DefinitionComparator implements Comparator<DefinitionEntry>
    {
        public final int compare (DefinitionEntry a, DefinitionEntry b)
        {
            // Largest to smallest.
            return -(a.size.compareTo(b.size));
        }
    }
       
}