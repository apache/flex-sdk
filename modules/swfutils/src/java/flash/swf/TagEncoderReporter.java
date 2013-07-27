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

package flash.swf;

import flash.swf.tools.SizeReport;
import flash.swf.tags.*;

import java.io.IOException;
import java.io.OutputStream;
import java.util.Iterator;
import java.util.Map;

/**
 * Tag encoder which tracks size information about the resulting SWF.
 *
 * @author Corey Lucier
 */
public class TagEncoderReporter extends TagEncoder
{
    private SizeReport report;
    private Boolean definingSprite = false;
    
    public TagEncoderReporter()
    {
        this(new Dictionary());
    }
    
    public TagEncoderReporter(Dictionary dict)
    {
        super(dict);
        report = new SizeReport();
    }
    
    public String getSizeReport()
    {
        return report.generate();
    }
    
    public void productInfo(ProductInfo tag)
    {
        report.startEntry(SizeReport.HEADER_DATA, writer.getPos(), -1, "productInfo");
        super.productInfo(tag);
        report.endEntry(SizeReport.HEADER_DATA, writer.getPos());
    }
    
    public void fileAttributes(FileAttributes tag)
    {
        report.startEntry(SizeReport.HEADER_DATA, writer.getPos(), -1, "fileAttributes");
        super.fileAttributes(tag);
        report.endEntry(SizeReport.HEADER_DATA, writer.getPos());
    }
    
    public void enableTelemetry(EnableTelemetry tag)
    {
        report.startEntry(SizeReport.HEADER_DATA, writer.getPos(), -1, "enableTelemetry");
        super.enableTelemetry(tag);
        report.endEntry(SizeReport.HEADER_DATA, writer.getPos());
    }
    
    public void enableDebugger(EnableDebugger tag)
    {
        report.startEntry(SizeReport.HEADER_DATA, writer.getPos(), -1, "enableDebugger");
        super.enableDebugger(tag);
        report.endEntry(SizeReport.HEADER_DATA, writer.getPos());
    }
    
    public void enableDebugger2(EnableDebugger tag)
    {
        report.startEntry(SizeReport.HEADER_DATA, writer.getPos(), -1, "enableDebugger");
        super.enableDebugger2(tag);
        report.endEntry(SizeReport.HEADER_DATA, writer.getPos());
    }
    
    public void debugID(DebugID tag)
    {
        report.startEntry(SizeReport.HEADER_DATA, writer.getPos(), -1, "debugID");
        super.debugID(tag);
        report.endEntry(SizeReport.HEADER_DATA, writer.getPos());
    }
    
    public void scriptLimits(ScriptLimits tag)
    {
        report.startEntry(SizeReport.HEADER_DATA, writer.getPos(), -1, "scriptLimits");
        super.scriptLimits(tag);
        report.endEntry(SizeReport.HEADER_DATA, writer.getPos());
    }
    
    public void metadata(Metadata tag)
    {
        report.startEntry(SizeReport.HEADER_DATA, writer.getPos(), -1, "metaData");
        super.metadata(tag);
        report.endEntry(SizeReport.HEADER_DATA, writer.getPos());
    }
    
    public void header(Header header)
    {
        report.startEntry(SizeReport.HEADER_DATA, 0, -1, "swfHeader");
        super.header(header);
        report.endEntry(SizeReport.HEADER_DATA, writer.getPos());
    }
    
    public void setBackgroundColor(SetBackgroundColor tag)
    {
        report.startEntry(SizeReport.HEADER_DATA, writer.getPos(), -1, "backgroundColor");
        super.setBackgroundColor(tag);
        report.endEntry(SizeReport.HEADER_DATA, writer.getPos());
    }
    
    public void finish()
    {
        super.finish();
        report.addEntry(SizeReport.HEADER_DATA, -1, 2, "endMarker");
        report.setSize(writer.getPos());
    }
    
    public void writeTo(OutputStream out) throws IOException
    {
        super.writeTo(out);
        report.setCompressedSize(writer.getBytesWritten());
    }
    
    public void writeDebugTo(OutputStream out) throws IOException
    {
        super.writeDebugTo(out);
        report.setCompressedSize(debug.getBytesWritten());
    }
    
    public void exportAssets(ExportAssets tag)
    {
        report.startEntry(SizeReport.FRAME_DATA, writer.getPos(), -1, "exportAssets");
        super.exportAssets(tag);
        report.endEntry(SizeReport.FRAME_DATA, writer.getPos());
    }
        
    public void defineBinaryData(DefineBinaryData tag)
    {
        int startPos = writer.getPos();
        super.defineBinaryData(tag);
        report.addEntry(SizeReport.BINARY, dict.getId(tag), writer.getPos() - startPos);
    }
    
    public void defineBits(DefineBits tag)
    {
        int startPos = writer.getPos();
        super.defineBits(tag);
        report.addEntry(SizeReport.BITMAP, dict.getId(tag), writer.getPos() - startPos);
    }
    
    public void defineBitsJPEG3(DefineBitsJPEG3 tag)
    {
        int startPos = writer.getPos();
        super.defineBitsJPEG3(tag);
        report.addEntry(SizeReport.BITMAP, dict.getId(tag), writer.getPos() - startPos);        
    }
    
    public void defineBitsLossless(DefineBitsLossless tag)
    {
        int startPos = writer.getPos();
        super.defineBitsLossless(tag);
        report.addEntry(SizeReport.BITMAP, dict.getId(tag), writer.getPos() - startPos);
    }
    
    public void defineBitsLossless2(DefineBitsLossless tag)
    {
        int startPos = writer.getPos();
        super.defineBitsLossless2(tag);
        report.addEntry(SizeReport.BITMAP, dict.getId(tag), writer.getPos() - startPos);
    }
    
    public void defineFont(DefineFont1 tag)
    {
        int startPos = writer.getPos();
        super.defineFont(tag);        
        report.addEntry(SizeReport.FONT, dict.getId(tag), writer.getPos() - startPos, tag.getFontName());      
    }
    
    public void defineFont2(DefineFont2 tag)
    {
        int startPos = writer.getPos();
        super.defineFont2(tag);        
        report.addEntry(SizeReport.FONT, dict.getId(tag), writer.getPos() - startPos, tag.fontName);     
    }
    
    public void defineFont4(DefineFont4 tag)
    {
        int startPos = writer.getPos();
        super.defineFont4(tag);        
        report.addEntry(SizeReport.FONT, dict.getId(tag), writer.getPos() - startPos, tag.fontName);       
    }
    
    public void defineShape(DefineShape tag)
    {
        int startPos = writer.getPos();
        super.defineShape(tag);
        report.addEntry(SizeReport.SHAPE, dict.getId(tag), writer.getPos() - startPos);
    }
    
    public void defineSound(DefineSound tag)
    {
        int startPos = writer.getPos();
        super.defineSound(tag);
        report.addEntry(SizeReport.SOUND, dict.getId(tag), writer.getPos() - startPos);
    }
    
    public void defineSprite(DefineSprite tag)
    {
        int startPos = writer.getPos();
        definingSprite = true;
        super.defineSprite(tag);
        definingSprite = false;
        report.addEntry(SizeReport.SPRITE, dict.getId(tag), writer.getPos() - startPos);
    }
    
    public void defineVideoStream(DefineVideoStream tag)
    {
        int startPos = writer.getPos();
        super.defineVideoStream(tag);
        report.addEntry(SizeReport.VIDEO, dict.getId(tag), writer.getPos() - startPos);
    }
    
    public void symbolClass(SymbolClass tag)
    {
        Iterator it = tag.class2tag.entrySet().iterator();
        while (it.hasNext())
        {
            Map.Entry e = (Map.Entry) it.next();
            String name = (String) e.getKey();
            DefineTag ref = (DefineTag) e.getValue();
            int idref = dict.getId(ref);
            report.addSymbol(name, idref);
        }
        report.startEntry(SizeReport.FRAME_DATA, writer.getPos(), -1, "symbolClass");
        super.symbolClass(tag);
        report.endEntry(SizeReport.FRAME_DATA, writer.getPos());
    }
    
    public void frameLabel(FrameLabel tag)
    {
        report.startEntry(SizeReport.FRAME, writer.getPos(), -1, tag.label);
        report.startEntry(SizeReport.FRAME_DATA, writer.getPos(), -1, "frameLabel");
        super.frameLabel(tag);
        report.endEntry(SizeReport.FRAME_DATA, writer.getPos());
    }
    
    public void showFrame(ShowFrame tag)
    {
        super.showFrame(tag);
        if (!definingSprite) 
        {
            report.addEntry(SizeReport.FRAME_DATA, -1, 2, "showFrame");
            report.endEntry(SizeReport.FRAME, writer.getPos());
        }
    }
    
    public void doABC(DoABC tag)
    {
        report.startEntry(SizeReport.SCRIPT, writer.getPos(), -1, tag.name);
        super.doABC(tag);
        report.endEntry(SizeReport.SCRIPT, writer.getPos());
    }
}