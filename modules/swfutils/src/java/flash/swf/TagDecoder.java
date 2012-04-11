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

import flash.swf.debug.DebugTable;
import flash.swf.tags.*;
import flash.swf.types.ButtonCondAction;
import flash.swf.types.ButtonRecord;
import flash.swf.types.CXForm;
import flash.swf.types.CXFormWithAlpha;
import flash.swf.types.CurvedEdgeRecord;
import flash.swf.types.FillStyle;
import flash.swf.types.Filter;
import flash.swf.types.FlashUUID;
import flash.swf.types.GlyphEntry;
import flash.swf.types.GradRecord;
import flash.swf.types.ImportRecord;
import flash.swf.types.KerningRecord;
import flash.swf.types.LineStyle;
import flash.swf.types.Matrix;
import flash.swf.types.MorphFillStyle;
import flash.swf.types.MorphGradRecord;
import flash.swf.types.MorphLineStyle;
import flash.swf.types.Rect;
import flash.swf.types.Shape;
import flash.swf.types.ShapeRecord;
import flash.swf.types.ShapeWithStyle;
import flash.swf.types.SoundInfo;
import flash.swf.types.StraightEdgeRecord;
import flash.swf.types.StyleChangeRecord;
import flash.swf.types.TextRecord;
import flash.swf.types.DropShadowFilter;
import flash.swf.types.BlurFilter;
import flash.swf.types.GlowFilter;
import flash.swf.types.BevelFilter;
import flash.swf.types.GradientGlowFilter;
import flash.swf.types.ConvolutionFilter;
import flash.swf.types.ColorMatrixFilter;
import flash.swf.types.GradientBevelFilter;
import flash.swf.types.Gradient;
import flash.swf.types.FocalGradient;

import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.zip.InflaterInputStream;

/**
 * A SWF tag decoder.  It is typically used by passing an InputStream
 * to the constructor and then calling parse() with a TagHandler.
 *
 * @author Clement Wong
 */
public final class TagDecoder
        implements TagValues
{
    public TagDecoder(InputStream swfIn)
	{
		this.swfIn = swfIn;
		this.swdIn = null;
	}

    public TagDecoder(InputStream swfIn, InputStream swdIn)
	{
		this.swfIn = swfIn;
		this.swdIn = swdIn;
	}

    public TagDecoder(InputStream in, URL swfUrl)
    {
        this.swfIn = in;
        this.swfUrl = swfUrl;
    }

    private Header header;
	private InputStream swfIn;
	private InputStream swdIn;
    private URL swfUrl;
    private DebugTable swd;
    private SwfDecoder r;
    private GenericTag jpegTables;
    private TagHandler handler;
    private boolean keepOffsets;

    private Dictionary dict = new Dictionary();

    /**
     * thrown by decoders when we have a fatal error.  Many errors
     * are not fatal.  In those cases, the error is reported but
     * parsing continues.
     */
	public static class FatalParseException extends Exception {

        private static final long serialVersionUID = 5819679367367802771L;}

    public void setKeepOffsets(boolean b)
    {
        keepOffsets = b;
    }

    /**
     * process the whole SWF stream, and close the input streams when finished.
     * @param handler
     * @throws IOException
     */
	public void parse(TagHandler handler) throws IOException
	{
        this.handler = handler;
        try
        {
            try
            {
                handler.setDecoderDictionary(dict);

                header = decodeHeader();
                handler.header(header);

                decodeTags(handler);
                handler.finish();
            }
            catch( FatalParseException e )
            {
                // errors already reported to TagHandler.
            }
            finally
            {
                if (swfIn != null)
                    swfIn.close();
            }
        }
        finally
        {
            if (swdIn != null)
                swdIn.close();
        }
	}

	public int getSwfVersion()
	{
		return header.version;
	}

    private void decodeTags(TagHandler handler) throws IOException
    {
        int type, h, length, currentOffset;

        do
        {
            currentOffset = r.getOffset();
            
            type = (h = r.readUI16()) >> 6;

            // is this a long tag header (>=63 bytes)?
            if (((length = h & 0x3F) == 0x3F))
            {
                // [ed] the player treats this as a signed field and stops if it is negative.
                length = r.readSI32();
                if (length < 0)
                {
                    handler.error("negative tag length: " + length + " at offset " + currentOffset);
                    break;
                }
            }
            int o = r.getOffset();
            int eat = 0;
            

            if (type != 0)
            {
                Tag t = decodeTag(type, length);
                if (r.getOffset() - o != length)
                {
                    handler.error("offset mismatch after " + Tag.names[t.code] + ": read " + (r.getOffset() - o) + ", expected " + length);
                    if (r.getOffset() - o < length)
                    {
                        eat = length - (r.getOffset() - o);
                        
                    }
                }
                handler.setOffsetAndSize(currentOffset, r.getOffset() - currentOffset);
                handler.any( t );
                t.visit(handler);
                if (eat > 0) // try to recover.  (flash 8 sometimes writes nonsense, usually in fonts)
                {
                    r.read( new byte[eat] );
                    
                }
            }
        }
        while (type != 0);
    }

    private Tag decodeTag(int type, int length) throws IOException
    {
        Tag t;
        int pos = r.getOffset();

        switch (type)
        {
        case stagProductInfo:
            t = decodeSerialNumber();
            break;
        case stagShowFrame:
            t = new ShowFrame();
            break;
        case stagMetadata:
            t = decodeMetadata();
            break;
        case stagDefineShape:
        case stagDefineShape2:
        case stagDefineShape3:
        case stagDefineShape4:
            t = decodeDefineShape(type);
            break;
        case stagPlaceObject:
            t = decodePlaceObject(length);
            break;
        case stagRemoveObject:
        case stagRemoveObject2:
            t = decodeRemoveObject(type);
            break;
        case stagDefineBinaryData:
            t = decodeDefineBinaryData(length);
            break;
        case stagDefineBits:
            t = decodeDefineBits(length);
            break;
        case stagDefineButton:
            t = decodeDefineButton(length);
            break;
        case stagJPEGTables:
            t = jpegTables = decodeJPEGTables(length);
            break;
        case stagSetBackgroundColor:
            t = decodeSetBackgroundColor();
            break;
        case stagDefineFont:
            t = decodeDefineFont();
            break;
        case stagDefineText:
        case stagDefineText2:
            t = decodeDefineText(type);
            break;
        case stagDoAction:
            t = decodeDoAction(length);
            break;
        case stagDefineFontInfo:
        case stagDefineFontInfo2:
            t = decodeDefineFontInfo(type, length);
            break;
        case stagDefineSound:
            t = decodeDefineSound(length);
            break;
        case stagStartSound:
            t = decodeStartSound();
            break;
        case stagDefineButtonSound:
            t = decodeDefineButtonSound();
            break;
        case stagSoundStreamHead2:
        case stagSoundStreamHead:
            t = decodeSoundStreamHead(type);
            break;
        case stagSoundStreamBlock:
            t = decodeSoundStreamBlock(length);
            break;
        case stagDefineBitsLossless:
            t = decodeDefineBitsLossless(length);
            break;
        case stagDefineBitsJPEG2:
            t = decodeDefineJPEG2(length);
            break;
        case stagDefineButtonCxform:
            t = decodeDefineButtonCxform();
            break;
        case stagProtect:
            t = decodeProtect(length);
            break;
        case stagPlaceObject2:
            t = decodePlaceObject23(stagPlaceObject2, length);
            break;
        case stagPlaceObject3:
            t = decodePlaceObject23(stagPlaceObject3, length);
            break;
        case stagDefineButton2:
            t = decodeDefineButton2(length);
            break;
        case stagDefineBitsJPEG3:
            t = decodeDefineJPEG3(length);
            break;
        case stagDefineBitsLossless2:
            t = decodeDefineBitsLossless2(length);
            break;
        case stagDefineEditText:
            t = decodeDefineEditText();
            break;
        case stagDefineSprite:
            t = decodeDefineSprite(pos+length);
            break;
        case stagDefineScalingGrid:
            t = decodeDefineScalingGrid();
            break;
        case stagFrameLabel:
            t = decodeFrameLabel(length);
            break;
        case stagDefineMorphShape:
            t = decodeDefineMorphShape();
            break;
        case stagDefineMorphShape2:
            t = decodeDefineMorphShape2();
            break;
        case stagDefineFont2:
            t = decodeDefineFont2();
            break;
        case stagDefineFont3:
            t = decodeDefineFont3();
            break;
        case stagDefineFont4:
            t = decodeDefineFont4(length);
            break;
        case stagExportAssets:
            t = decodeExportAssets();
            break;
        case stagImportAssets:
        case stagImportAssets2:
            t = decodeImportAssets(type);
            break;
        case stagEnableDebugger2:
        case stagEnableDebugger:
            t = decodeEnableDebugger(type);
            break;
        case stagDoInitAction:
            t = decodeDoInitAction(length);
            break;
        case stagDefineVideoStream:
            t = decodeDefineVideoStream();
            break;
        case stagVideoFrame:
            t = decodeVideoFrame(length);
            break;
        case stagDebugID:
            t = decodeDebugID(type, length);
            break;
        case stagScriptLimits:
            t = decodeScriptLimits();
            break;
        case stagSetTabIndex:
            t = decodeSetTabIndex();
            break;
        case stagDoABC:
        case stagDoABC2:
            t = decodeDoABC(type, length);
            break;
        case stagSymbolClass:
            t = decodeSymbolClass();
            break;
        case stagFileAttributes:
            t = decodeFileAttributes();
            break;
        case stagDefineFontAlignZones:
            t = decodeDefineFontAlignZones();
            break;
        case stagCSMTextSettings:
            t = decodeCSMTextSettings();
            break;
        case stagDefineSceneAndFrameLabelData:
            t = decodeDefineSceneAndFrameData(length);
            break;
        case stagDefineFontName:
            t = decodeDefineFontName();
            break;
        default:
            t = decodeUnknown(length, type);
            break;
        }

        int consumed = r.getOffset() - pos;

        // [preilly] It looks like past Authoring tools have generated some SWF's with
        // stagSoundStreamHead tags of length 4 with compression set to mp3, but the tag
        // really has 6 bytes in it and the player always reads the 6 bytes, so ignore the
        // difference between the consumed and the length for this special case.
        if ((consumed != length) && (type == stagSoundStreamHead) && (consumed != (length + 2)))
        {
            throw new SwfFormatException(TagValues.names[type] + " at pos "+pos+ ": " + consumed +
                                  " bytes were read. " + length + " byte were required.");
        }
        return t;
    }

    private Tag decodeDefineSceneAndFrameData(int length) throws IOException
    {
        DefineSceneAndFrameLabelData t = new DefineSceneAndFrameLabelData();
        t.data = new byte[length];
        r.readFully(t.data);
        return t;
    }

    private Tag decodeDoABC(int type, int length) throws IOException
	{
		DoABC t;

        if (type == stagDoABC2)
        {
            int pos = r.getOffset();
            int skip = r.readSI32();
            String name = r.readString();
            t = new DoABC( name , skip );
            // cannot just use length of string, because might not match
            // the number of bytes in the string for nonascii characters
            //length -= (4 + name.length() + 1);
            length -= (r.getOffset() - pos);
        }
        else
        {
            t = new DoABC();
        }

		t.abc = new byte[length];
		r.readFully(t.abc);
		return t;
	}

	private Tag decodeSymbolClass() throws IOException
	{
		SymbolClass t = new SymbolClass();
		int count = r.readUI16();

		t.class2tag = new HashMap<String, Tag>(count);

		for (int i=0; i < count; i++)
		{
			int idref = r.readUI16();
			String name = r.readString();
			if (idref == 0)
			{
				t.topLevelClass = name;
				continue;
			}
			DefineTag ref = dict.getTag(idref);
			t.class2tag.put(name, ref);
			if (ref.name != null)
			{
				if (!ref.name.equals(name))
				{
					handler.error("SymbolClass: symbol " + idref + " already exported as " + ref.name);
				}
				//else
				//{
                    // FIXME: is this right?  seem to be getting redundant message in swfdumps that work right in the player
                    // FIXME: We should eventually enforce that export names not be used in zaphod movies,
                    // FIXME: but in the short term, all this message means is that the symbol was both exported
                    // FIXME: via ExportAssets and also associated with a class via SymbolClass.  They have
                    // FIXME: different semantic meanings, so this error is a bit off-base.  --rg 
				//	handler.error("Redundant SymbolClass of " + ref.name + ".  Found " + ref.getClass().getName() + " of same name in dictionary.");
				//}
			}
			else
			{
				DefineTag other = dict.getTag(name);
				if (other != null)
				{
					int id = dict.getId(other);
					handler.error("Symbol " + name + " already refers to ID " + id);
				}
				ref.name = name;
				dict.addName(ref, name);
			}
		}
		return t;
	}

    private Tag decodeSetTabIndex() throws IOException
    {
        int depth = r.readUI16();
        int index = r.readUI16();
        return new SetTabIndex(depth, index);
    }

    private Tag decodeUnknown(int length, int code) throws IOException
    {
        GenericTag t;
        t = new GenericTag(code);
        t.data = new byte[length];
        r.readFully(t.data);
        return t;
    }

    private ScriptLimits decodeScriptLimits() throws IOException
    {
        ScriptLimits scriptLimits = new ScriptLimits(r.readUI16(), r.readUI16());
        return scriptLimits;
    }

    private Tag decodeDebugID(int type, int length) throws IOException
    {
        DebugID t;
        t = new DebugID(type);
        t.uuid = decodeFlashUUID(length);

		if (swdIn != null)
		{
			InputStream in = swdIn;
            DebugTable swd = new DebugTable();
            new DebugDecoder(in).readSwd(swd);

            if (!t.uuid.equals(swd.uuid))
            {
                handler.error("SWD uuid "+swd.uuid+" doesn't match "+t.uuid);
            }
            else if (swd.version != getSwfVersion())
            {
                handler.error("SWD version number "+swd.version+" doesn't match SWF version number "+getSwfVersion());
            }
            else
            {
                this.swd = swd;
            }
		}
        else if (swfUrl != null)
        {
            // look for a SWD file in the same place the player would look
            String path = swfUrl.toString();

			int q = path.indexOf("?");
			String query = null;
            if (q != -1)
			{
				query = path.substring(q);
                path = path.substring(0, q);
			}

			URL swdUrl;
            if (path.endsWith(".swf"))
            {
                path = path.substring(0,path.length()-4)+".swd";
            }
            else
            {
                path = path + ".swd";
            }

            if (query != null)
            {
                path = path + query;
            }

            swdUrl = new URL(path);

            try
            {
                InputStream in = swdUrl.openStream();
                DebugTable swd = new DebugTable();
                new DebugDecoder(in).readSwd(swd);

                if (!t.uuid.equals(swd.uuid))
                {
                    handler.error("SWD uuid "+swd.uuid+" doesn't match "+t.uuid);
                }
				else if (swd.version != getSwfVersion())
				{
					handler.error("SWD version number "+swd.version+" doesn't match SWF version number "+getSwfVersion());
				}
                else
                {
                    this.swd = swd;
                }
            }
            catch (FileNotFoundException ex)
            {
                handler.error("SWD not found at url " + swdUrl);
            }
        }

        return t;
    }

    private FlashUUID decodeFlashUUID(int length) throws IOException
    {
        byte[] uuid = new byte[length];
        r.readFully(uuid);
        return new FlashUUID(uuid);
    }

    private Tag decodeVideoFrame(int length) throws IOException
    {
        VideoFrame t;
        t = new VideoFrame();
        int pos = r.getOffset();

        int idref = r.readUI16();
        t.stream = (DefineVideoStream) dict.getTag(idref);
        t.frameNum = r.readUI16();

        length -= r.getOffset() - pos;

        t.videoData = new byte[length];
        r.readFully(t.videoData);
        return t;
    }

    private Tag decodeDefineVideoStream() throws IOException
    {
        DefineVideoStream t;
        t = new DefineVideoStream();
        int id = r.readUI16();
        t.numFrames = r.readUI16();
        t.width = r.readUI16();
        t.height = r.readUI16();

        r.syncBits();

        r.readUBits(4); // reserved
        t.deblocking = r.readUBits(3);
        t.smoothing = r.readBit();

        t.codecID = r.readUI8();

        dict.add(id, t);
        return t;
    }

    private Tag decodeDoInitAction(int length) throws IOException
    {
        DoInitAction t;
        t = new DoInitAction();
        int idref = r.readUI16();
        try
        {
            t.sprite = (DefineSprite) dict.getTag(idref);
            if (t.sprite.initAction != null)
            {
                handler.error("Sprite " + idref + " initaction redefined");
            }
            else
            {
                t.sprite.initAction = t;
            }
        }
        catch (IllegalArgumentException e)
        {
            handler.error(e.getMessage());
        }
        ActionDecoder actionDecoder = new ActionDecoder(r,swd);
        actionDecoder.setKeepOffsets(keepOffsets);
        t.actionList = actionDecoder.decode(length-2);
        return t;
    }

    private Tag decodeEnableDebugger(int code) throws IOException
    {
        EnableDebugger t;
        t = new EnableDebugger(code);
        if (code == stagEnableDebugger2)
        {
            if (getSwfVersion() < 6)
                handler.error("EnableDebugger2 not valid before SWF 6");
            t.reserved = r.readUI16(); // reserved
        }
        t.password = r.readString();
        return t;
    }

    private Tag decodeImportAssets(int code) throws IOException
    {
        ImportAssets t;
        t = new ImportAssets(code);

        t.url = r.readString();
        if (code == stagImportAssets2)
        {
        	t.downloadNow = (r.readUI8() == 1);
        	if (r.readUI8() == 1) // hasDigest == 1
        	{
        		t.SHA1 = new byte[20];
        		r.readFully(t.SHA1);
        	}
        }
        
        int count = r.readUI16();
        t.importRecords = new ArrayList<ImportRecord>();

        for (int i=0; i < count; i++)
        {
            ImportRecord ir = new ImportRecord();
            int id = r.readUI16();
            ir.name = r.readString();
            t.importRecords.add(ir);
            dict.add(id, ir);
            dict.addName(ir, ir.name);
        }
        return t;
    }

    private Tag decodeExportAssets() throws IOException
    {
        ExportAssets t;
        t = new ExportAssets();

        int count = r.readUI16();

        t.exports = new ArrayList<Tag>(count);

        for (int i=0; i < count; i++)
        {
            int idref = r.readUI16();
            String name = r.readString();
            DefineTag ref = dict.getTag(idref);
            t.exports.add(ref);
            if (ref.name != null)
            {
                if (!ref.name.equals(name))
                    handler.error("ExportAsset: symbol " + idref + " already exported as " + ref.name);
                else
                    handler.error("redundant export of "+ref.name);
            }
            else
            {
                DefineTag other = dict.getTag(name);
                if (other != null)
                {
                    int id = dict.getId(other);
                    handler.error("Symbol "+name+" already refers to ID "+id);
                }
                ref.name = name;
                dict.addName(ref, name);
            }
        }
        return t;
    }

    private Tag decodeDefineFont2() throws IOException
    {
        DefineFont2 t = new DefineFont2();
        return decodeDefineFont2And3(t);
    }

    private Tag decodeDefineFont3() throws IOException
    {
        DefineFont3 t = new DefineFont3();
        return decodeDefineFont2And3(t);
    }

    private Tag decodeDefineFont2And3(DefineFont2 t) throws IOException
    {
        int id = r.readUI16();

        r.syncBits();

        t.hasLayout = r.readBit();
        t.shiftJIS = r.readBit();
        t.smallText = r.readBit();
        t.ansi = r.readBit();
        t.wideOffsets = r.readBit();
        t.wideCodes = r.readBit();
        // enable after we're sure that bug 147073 isn't a bug.  If it is a bug, then this can be
        // removed as well as the stageDefineFont3-specific code in TagEncoder.defineFont2()
        //if (t.code == stagDefineFont3 && ! t.wideCodes)
        //{
        //    handler.error("widecodes must be true in DefineFont3");
        //}

        t.italic = r.readBit();
        t.bold = r.readBit();

        t.langCode = r.readUI8();

        t.fontName = r.readLengthString();

        int numGlyphs = r.readUI16();

        long[] offsets = new long[numGlyphs];
        for (int i = 0; i < numGlyphs; i++)
        {
            if (t.wideOffsets)
                offsets[i] = r.readUI32();
            else
                offsets[i] = r.readUI16();
        }

        long codeTableOffset = 0;
        if (numGlyphs > 0)
        {
	        if (t.wideOffsets)
	            codeTableOffset = r.readUI32();
	        else
	            codeTableOffset = r.readUI16();
        }

        t.glyphShapeTable = new Shape[numGlyphs];

        for (int i = 0; i < numGlyphs; i++)
        {
            int glyphLength;
            if (i < (numGlyphs - 1))
                glyphLength = (int)(offsets[i+1] - offsets[i]);
            else
                glyphLength = (int)(codeTableOffset - offsets[i]);

            t.glyphShapeTable[i] = decodeGlyph(stagDefineShape3, glyphLength);
        }

        t.codeTable = new char[numGlyphs];
        if (t.wideCodes)
        {
            for (int i = 0; i < numGlyphs; i++)
                t.codeTable[i] = (char) r.readUI16();
        }
        else
        {
            for (int i = 0; i < numGlyphs; i++)
                t.codeTable[i] = (char) r.readUI8();
        }

        if (t.hasLayout)
        {
            t.ascent = r.readSI16();
            t.descent = r.readSI16();
            t.leading = r.readSI16();
            t.advanceTable = new short[numGlyphs];
            for (int i = 0; i < numGlyphs; i++)
            {
                t.advanceTable[i] = (short)r.readSI16();
            }
            t.boundsTable = new Rect[numGlyphs];
            for (int i = 0; i < numGlyphs; i++)
            {
                t.boundsTable[i] = decodeRect();
            }

            t.kerningCount = r.readUI16();
            t.kerningTable = new KerningRecord[t.kerningCount];
            for (int i = 0; i < t.kerningCount; i++)
            {
                t.kerningTable[i] = decodeKerningRecord(t.wideCodes);
            }
        }

        dict.add(id, t);
        dict.addFontFace( t );
        return t;
    }

    private Tag decodeDefineFont4(int length) throws IOException
    {
        DefineFont4 t = new DefineFont4();
        int pos = r.getOffset();

        int id = r.readUI16();

        r.syncBits();
        r.readUBits(5); // reserved
        t.hasFontData = r.readBit();
        //t.smallText = r.readBit();
        t.italic = r.readBit();
        t.bold = r.readBit();

        //t.langCode = r.readUI8();
        t.fontName = r.readString();

        if (t.hasFontData)
        {
            length -= r.getOffset() - pos;
            t.data = new byte[length];
            r.readFully(t.data);
        }

        dict.add(id, t);
        dict.addFontFace(t);
        return t;
    }
    
    private KerningRecord decodeKerningRecord(boolean wideCodes) throws IOException
    {
        KerningRecord kr = new KerningRecord();

        kr.code1 = (wideCodes) ? r.readUI16() : r.readUI8();
        kr.code2 = (wideCodes) ? r.readUI16() : r.readUI8();
        kr.adjustment = r.readUI16();

        return kr;
    }

    private Tag decodeDefineMorphShape() throws IOException
    {
    	return decodeDefineMorphShape(stagDefineMorphShape);
    }

    private Tag decodeDefineMorphShape2() throws IOException
    {
    	return decodeDefineMorphShape(stagDefineMorphShape2);
    }

    private Tag decodeDefineMorphShape(int code) throws IOException
    {
        DefineMorphShape t = new DefineMorphShape(code);
        int id = r.readUI16();
        t.startBounds = decodeRect();
        t.endBounds = decodeRect();
        if (code == stagDefineMorphShape2)
        {
        	t.startEdgeBounds = decodeRect();
        	t.endEdgeBounds = decodeRect();
            r.readUBits(6);
            t.usesNonScalingStrokes = r.readBit();
            t.usesScalingStrokes = r.readBit();
        }
        int offset = (int)r.readUI32(); // offset to EndEdges
        t.fillStyles = decodeMorphFillstyles(code);
        t.lineStyles = decodeMorphLinestyles(code);
        t.startEdges = decodeShape(stagDefineShape3);
        if (offset != 0)
            t.endEdges = decodeShape(stagDefineShape3);
        dict.add(id, t);
        return t;
    }

    private MorphLineStyle[] decodeMorphLinestyles(int code) throws IOException
    {
        int count = r.readUI8();
        if (count == 0xFF)
        {
            count = r.readUI16();
        }

        MorphLineStyle[] styles = new MorphLineStyle[count];

        for (int i = 0; i < count; i++)
        {
            MorphLineStyle s = new MorphLineStyle();
            s.startWidth = r.readUI16();
            s.endWidth = r.readUI16();
            if (code == stagDefineMorphShape2)
            {
            	s.startCapsStyle = r.readUBits(2);
            	s.jointStyle = r.readUBits(2);
            	s.hasFill = r.readBit();
            	s.noHScale = r.readBit();
            	s.noVScale = r.readBit();
            	s.pixelHinting = r.readBit();
            	r.readUBits(5); // reserved
            	s.noClose = r.readBit();
            	s.endCapsStyle = r.readUBits(2);
            	if (s.jointStyle == 2)
            	{
            		s.miterLimit = r.readUI16();
            	}
            }
            if (!s.hasFill)
            {
            	s.startColor = decodeRGBA(r);
                s.endColor = decodeRGBA(r);
            }
            if (s.hasFill)
            {
            	s.fillType = decodeMorphFillStyle(code);
            }

            styles[i] = s;
        }

        return styles;
    }

    private MorphFillStyle[] decodeMorphFillstyles(int shape) throws IOException
    {
        int count = r.readUI8();
        if (count == 0xFF)
        {
            count = r.readUI16();
        }

        MorphFillStyle[] styles = new MorphFillStyle[count];

        for (int i = 0; i < count; i++)
        {
            styles[i] = decodeMorphFillStyle(shape);
        }

        return styles;
    }

    private MorphFillStyle decodeMorphFillStyle(int shape) throws IOException
    {
        MorphFillStyle s = new MorphFillStyle();

        s.type = r.readUI8();
        switch (s.type)
        {
        case FillStyle.FILL_SOLID: // 0x00
            s.startColor = decodeRGBA(r);
            s.endColor = decodeRGBA(r);
            break;
        case FillStyle.FILL_GRADIENT: // 0x10 linear gradient fill
        case FillStyle.FILL_RADIAL_GRADIENT: // 0x12 radial gradient fill
        case FillStyle.FILL_FOCAL_RADIAL_GRADIENT: // 0x13 focal radial gradient fill
            s.startGradientMatrix = decodeMatrix();
            s.endGradientMatrix = decodeMatrix();
            s.gradRecords = decodeMorphGradient();
            if (s.type == FillStyle.FILL_FOCAL_RADIAL_GRADIENT && shape == stagDefineMorphShape2)
            {
            	s.ratio1 = r.readSI16();
            	s.ratio2 = r.readSI16();
            }
            break;
        case FillStyle.FILL_BITS: // 0x40 tiled bitmap fill
        case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP): // 0x41 clipped bitmap fill
        case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_NOSMOOTH): // 0x42 tiled non-smoothed fill
        case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP | FillStyle.FILL_BITS_NOSMOOTH): // 0x43 clipped non-smoothed fill
            int idref = r.readUI16();
            try
            {
                s.bitmap = dict.getTag(idref);
            }
            catch (IllegalArgumentException ex)
            {
                handler.error(ex.getMessage());
                s.bitmap = null;
            }
            s.startBitmapMatrix = decodeMatrix();
            s.endBitmapMatrix = decodeMatrix();
            break;
        default:
            throw new SwfFormatException("unrecognized fill style type: " + s.type);
        }

        return s;
    }

    private MorphGradRecord[] decodeMorphGradient() throws IOException
    {
        int num = r.readUI8();
        MorphGradRecord[] gradRecords = new MorphGradRecord[num];

        for (int i = 0; i < num; i++)
        {
            MorphGradRecord g = new MorphGradRecord();
            g.startRatio = r.readUI8();
            g.startColor = decodeRGBA(r);
            g.endRatio = r.readUI8();
            g.endColor = decodeRGBA(r);

            gradRecords[i] = g;
        }

        return gradRecords;
    }

    private Tag decodeFrameLabel(int length) throws IOException
    {
        FrameLabel t = new FrameLabel();
        int pos = r.getOffset();
        t.label = r.readString();
        if (getSwfVersion() >= 6)
        {
            if (length - r.getOffset() + pos == 1)
            {
                int anchor = r.readUI8();
                if (anchor != 0 && anchor != 1)
                    handler.error("illegal anchor value: "+anchor+".  Must be 0 or 1");
                // player treats any nonzero value as true
                t.anchor = (anchor != 0);
            }
        }
        return t;
    }

    private Tag decodeDefineEditText() throws IOException
    {
        DefineEditText t;
        t = new DefineEditText();
        int id = r.readUI16();
        t.bounds = decodeRect();

        r.syncBits();

        t.hasText = r.readBit();
        t.wordWrap = r.readBit();
        t.multiline = r.readBit();
        t.password = r.readBit();
        t.readOnly = r.readBit();
        t.hasTextColor = r.readBit();
        t.hasMaxLength = r.readBit();
        t.hasFont = r.readBit();
        t.hasFontClass = r.readBit(); // FP 9.0.45 or later
        t.autoSize = r.readBit();
        t.hasLayout = r.readBit();
        t.noSelect = r.readBit();
        t.border = r.readBit();
        t.wasStatic = r.readBit();
        t.html = r.readBit();
        t.useOutlines = r.readBit();

        if (t.hasFont)
        {
            int idref = r.readUI16();
            t.font = (DefineFont) dict.getTag(idref);
            t.height = r.readUI16();
        }

        if (t.hasFontClass)
        {
            t.fontClass = r.readString();
            t.height = r.readUI16();
        }

        if (t.hasTextColor)
        {
            t.color = decodeRGBA(r);
        }

        if (t.hasMaxLength)
        {
            t.maxLength = r.readUI16();
        }

        if (t.hasLayout)
        {
            t.align = r.readUI8();
            t.leftMargin = r.readUI16();
            t.rightMargin = r.readUI16();
            t.ident = r.readUI16();
            t.leading = r.readSI16(); // see errata, leading is signed
        }

        t.varName = r.readString();

        if (t.hasText)
        {
            t.initialText = r.readString();
        }

        dict.add(id, t);
        return t;
    }

    private Tag decodeDefineScalingGrid() throws IOException
    {
        DefineScalingGrid t = new DefineScalingGrid();
        int idref = r.readUI16();
        try
        {
            t.scalingTarget = dict.getTag(idref);
            if (t.scalingTarget instanceof DefineSprite)
            {
                DefineSprite targetSprite = (DefineSprite) t.scalingTarget;
                if (targetSprite.scalingGrid != null)
                {
                    handler.error("Sprite " + idref + " scaling grid redefined" );
                }
                targetSprite.scalingGrid = t;
            }
            else if (t.scalingTarget instanceof DefineButton)
            {
                DefineButton targetButton = (DefineButton) t.scalingTarget;
                if (targetButton.scalingGrid != null)
                {
                    handler.error("Button " + idref + " scaling grid redefined");
                }
                targetButton.scalingGrid = t;
            }
        }
        catch (Exception e)
        {
            return null;
        }
        t.rect = decodeRect();
        return t;
    }

    private Tag decodeDefineBitsLossless2(int length) throws IOException
    {
        DefineBitsLossless t;
        t = new DefineBitsLossless(stagDefineBitsLossless2);
        SwfDecoder r1 = r;

        int pos = r1.getOffset();

        int id = r1.readUI16();
        t.format = r1.readUI8();
        t.width = r1.readUI16();
        t.height = r1.readUI16();

        byte[] data;

        switch (t.format)
        {
        case 3:
            int colorTableSize = r1.readUI8()+1;
            length -= r1.getOffset() - pos;
            data = new byte[length];
            r1.readFully(data);
            r1 = new SwfDecoder(new InflaterInputStream(new ByteArrayInputStream(data)), getSwfVersion());
            decodeAlphaColorMapData(r1, t, colorTableSize);
            break;
        case 4:
        case 5:
            length -= r1.getOffset() - pos;
            data = new byte[length];
            r1.readFully(data);
            r1 = new SwfDecoder(new InflaterInputStream(new ByteArrayInputStream(data)), getSwfVersion());
            t.data = new byte[t.width * t.height * 4];
            r1.readFully(t.data);
            break;
        default:
            throw new SwfFormatException("Illegal bitmap format " + t.format);
        }

        dict.add(id, t);
        return t;
    }

    private void decodeAlphaColorMapData(SwfDecoder r1, DefineBitsLossless tag, int tableSize) throws IOException
    {
        int width = tag.width;
        int height = tag.height;

        tag.colorData = new int[tableSize];

        for (int i = 0; i < tableSize; i++)
        {
            tag.colorData[i] = decodeRGBA(r1);
        }

        if (width % 4 != 0)
        {
            width = (width / 4 + 1) * 4;
        }

        int data_size = width * height;

        tag.data = new byte[data_size];
        //r1.read(tag.data);

        int i = 0;
        int b;
        while (i < data_size)
        {
            b = r1.readUI8();
            if (b != -1)
            {
                tag.data[i] = (byte) b;
                i++;
            }
            else
            {
                break;
            }
        }

        int extra = 0;
        while (r1.readUI8() != -1)
        {
            extra++;
        }

        if (extra > 0)
        {
            throw new SwfFormatException(extra + " bytes of bitmap data (" + width + "x" + height + ") not read!");
        }
        else if (i != data_size)
        {
            throw new SwfFormatException("(" + width + "x" + height + ") data buffer " + (data_size - i) + " bytes too big...");
        }
    }

    private Tag decodeDefineJPEG3(int length) throws IOException
    {
        DefineBitsJPEG3 t;
        t = new DefineBitsJPEG3();
        int pos = r.getOffset();
        int id = r.readUI16();
        t.alphaDataOffset = r.readUI32();

        t.data = new byte[(int) t.alphaDataOffset];
        r.readFully(t.data);

        length -= r.getOffset() - pos;
        byte[] temp = new byte[length];
        r.readFully(temp);

        SwfDecoder r1 = new SwfDecoder(new InflaterInputStream(new ByteArrayInputStream(temp)), getSwfVersion());

        int alpha, i = 0;
        byte[] alphaData = new byte[length];

        while ((alpha = r1.readUI8()) != -1)
        {
            if (i == alphaData.length)
            {
                byte[] b = new byte[i + length];
                System.arraycopy(alphaData, 0, b, 0, alphaData.length);
                alphaData = b;
            }
            alphaData[i] = (byte)alpha;
            i++;
        }

        t.alphaData = new byte[i];
        System.arraycopy(alphaData, 0, t.alphaData, 0, i);

        dict.add(id, t);
        return t;
    }

    private Tag decodeDefineButton2(int length) throws IOException
    {
		int endpos = r.getOffset()+length;
        DefineButton t = new DefineButton(stagDefineButton2);

        int id = r.readUI16();

        r.syncBits();
        r.readUBits(7); // reserved
        t.trackAsMenu = r.readBit();

        int actionOffset = r.readUI16();

        // read button data
        ArrayList<Object> list = new ArrayList<Object>(5);
        ButtonRecord record;
        while ((record = decodeButtonRecord(t.code)) != null)
        {
            list.add(record);
        }

        t.buttonRecords = new ButtonRecord[list.size()];
        list.toArray(t.buttonRecords);
        list.clear();

        if (actionOffset > 0)
        {
            list = new ArrayList<Object>();

            int pos = r.getOffset();
            while ((actionOffset = r.readUI16()) > 0)
            {
                list.add(decodeButtonCondAction(actionOffset-2));
                if (r.getOffset() != pos+actionOffset)
                {
                    throw new SwfFormatException("incorrect offset read in ButtonCondAction. read "+actionOffset+"");
                }
                pos = r.getOffset();
            }
			// actionOffset == 0 means this will be the last record
            list.add(decodeButtonCondAction(endpos-r.getOffset()));

            t.condActions = new ButtonCondAction[list.size()];
            list.toArray(t.condActions);
        }
        else
        {
            t.condActions = new ButtonCondAction[0];
        }
        while (r.getOffset() < endpos)
        {
            int b = r.readUI8();
            if (b != 0)
            {
                throw new SwfFormatException("nonzero data past end of DefineButton2");
            }
        }

        dict.add(id, t);
        return t;
    }

    private ButtonCondAction decodeButtonCondAction(int length) throws IOException
    {
        ButtonCondAction a = new ButtonCondAction();
        r.syncBits();
        a.keyPress = r.readUBits(7);
        a.overDownToIdle = r.readBit();

        a.idleToOverDown = r.readBit();
        a.outDownToIdle = r.readBit();
        a.outDownToOverDown = r.readBit();
        a.overDownToOutDown = r.readBit();
        a.overDownToOverUp = r.readBit();
        a.overUpToOverDown = r.readBit();
        a.overUpToIdle = r.readBit();
        a.idleToOverUp = r.readBit();

        ActionDecoder actionDecoder = new ActionDecoder(r,swd);
        actionDecoder.setKeepOffsets(keepOffsets);
        a.actionList = actionDecoder.decode(length-2);

        return a;
    }

    private Tag decodePlaceObject23(int type, int length) throws IOException
    {
        PlaceObject t = new PlaceObject(type);
        int pos = r.getOffset();
        t.flags = r.readUI8();
        if (type == stagPlaceObject3)
        {
            t.flags2 = r.readUI8();
        }
        t.depth = r.readUI16();
        if (t.hasClassName())
        {
            t.className = r.readString();
        }
        if (t.hasCharID())
        {
            int idref = r.readUI16();
            t.setRef(dict.getTag(idref));
        }
        if (t.hasMatrix())
        {
            t.matrix = decodeMatrix();
        }
        if (t.hasCxform())
        {
            t.setCxform(decodeCxforma());
        }
        if (t.hasRatio())
        {
            t.ratio = r.readUI16();
        }
        if (t.hasName())
        {
            t.name = r.readString();
        }
        if (t.hasClipDepth())
        {
            t.clipDepth = r.readUI16();
        }
        if (type == stagPlaceObject3)
        {
            if (t.hasFilterList())
            {
                t.filters = decodeFilterList();
            }
            if (t.hasBlendMode())
            {
                t.blendMode = r.readUI8();
            }
        }
        if (t.hasClipAction())
        {
            ActionDecoder actionDecoder = new ActionDecoder(r,swd);
            actionDecoder.setKeepOffsets(keepOffsets);
            t.clipActions = actionDecoder.decodeClipActions(length - (r.getOffset() - pos));
        }
        return t;
    }

    private List<Filter> decodeFilterList() throws IOException
    {
        LinkedList<Filter> filters = new LinkedList<Filter>();
        int count = r.readUI8();
        for (int i = 0; i < count; ++i)
        {
            int filterID = r.readUI8();
            switch( filterID )
            {
            // NOTE: the filter decoding is pretty much just "save enough bits to regenerate", and ignores
            // the real formatting of the filters (i.e. fixed 8.8 types, etc.)  If you need the actual
            // values rather than just acting as a passthrough, you will need to enhance the types.

                case DropShadowFilter.ID:    filters.add( decodeDropShadowFilter() );    break;
                case BlurFilter.ID:          filters.add( decodeBlurFilter() );          break;
                case GlowFilter.ID:          filters.add( decodeGlowFilter() );          break;
                case BevelFilter.ID:         filters.add( decodeBevelFilter() );         break;
                case GradientGlowFilter.ID:  filters.add( decodeGradientGlowFilter() );  break;
                case ConvolutionFilter.ID:   filters.add( decodeConvolutionFilter() );   break;
                case ColorMatrixFilter.ID:   filters.add( decodeColorMatrixFilter() );   break;
                case GradientBevelFilter.ID: filters.add( decodeGradientBevelFilter() ); break;
            }
        }
        return filters;
    }

    private DropShadowFilter decodeDropShadowFilter() throws IOException
    {
        DropShadowFilter f = new DropShadowFilter();
        f.color = decodeRGBA( r );
        f.blurX = r.readSI32();
        f.blurY = r.readSI32();
        f.angle = r.readSI32();
        f.distance = r.readSI32();
        f.strength = r.readUI16();  // really fixed8
        f.flags = r.readUI8();
        return f;
    }
    private BlurFilter decodeBlurFilter() throws IOException
    {
        BlurFilter f = new BlurFilter();
        f.blurX = r.readSI32(); // FIXED
        f.blurY = r.readSI32();
        f.passes = r.readUI8();
        return f;
    }

    private GlowFilter decodeGlowFilter() throws IOException
    {
        GlowFilter f = new GlowFilter();
        f.color = decodeRGBA( r );
        f.blurX = r.readSI32();
        f.blurY = r.readSI32();
        f.strength = r.readUI16();          // fixed 8.8
        f.flags = r.readUI8();  // bunch of fields
        return f;
    }
    private BevelFilter decodeBevelFilter() throws IOException
    {
        BevelFilter f = new BevelFilter();
        f.highlightColor = decodeRGBA(r);
        f.shadowColor = decodeRGBA(r);
        f.blurX = r.readSI32();
        f.blurY = r.readSI32();
        f.angle = r.readSI32();
        f.distance = r.readSI32();
        f.strength = r.readUI16();  // fixed 8.8
        f.flags = r.readUI8();  // bunch of fields
        return f;
    }
    private GradientGlowFilter decodeGradientGlowFilter() throws IOException
    {
        GradientGlowFilter f = new GradientGlowFilter();
        f.numcolors = r.readUI8();
        f.gradientColors = new int[f.numcolors];
        for (int i = 0; i < f.numcolors; ++i)
            f.gradientColors[i] = decodeRGBA( r );
        f.gradientRatio = new int[f.numcolors];
        for (int i = 0; i < f.numcolors; ++i)
            f.gradientRatio[i] = r.readUI8();
//        f.color = decodeRGBA( r );
        f.blurX = r.readSI32();
        f.blurY = r.readSI32();
        f.angle = r.readSI32();
        f.distance = r.readSI32();
        f.strength = r.readUI16();  // fixed 8.8
        f.flags = r.readUI8();  // bunch of fields

        return f;
    }
    private ConvolutionFilter decodeConvolutionFilter() throws IOException
    {
        ConvolutionFilter f = new ConvolutionFilter();
        f.matrixX = r.readUI8();
        f.matrixY = r.readUI8();
        f.divisor = r.readFloat();
        f.bias = r.readFloat();
        f.matrix = new float[f.matrixX*f.matrixY];
        for (int i = 0; i <f.matrixX*f.matrixY; ++i)
            f.matrix[i] = r.readFloat();
        f.color = decodeRGBA( r );
        f.flags = r.readUI8();
        return f;
    }

    private ColorMatrixFilter decodeColorMatrixFilter() throws IOException
    {
        ColorMatrixFilter f = new ColorMatrixFilter();

        for (int i = 0; i < 20; ++i)
        {
            f.values[i] = r.readFloat();
        }
        return f;
    }

    private GradientBevelFilter decodeGradientBevelFilter() throws IOException
    {
        GradientBevelFilter f = new GradientBevelFilter();
        f.numcolors = r.readUI8();
        f.gradientColors = new int[f.numcolors];
        for (int i = 0; i < f.numcolors; ++i)
            f.gradientColors[i] = decodeRGBA( r );
        f.gradientRatio = new int[f.numcolors];
        for (int i = 0; i < f.numcolors; ++i)
            f.gradientRatio[i] = r.readUI8();
//        f.shadowColor = decodeRGBA( r );
//        f.highlightColor = decodeRGBA( r );
        f.blurX = r.readSI32();
        f.blurY = r.readSI32();
        f.angle = r.readSI32();
        f.distance = r.readSI32();
        f.strength = r.readUI16();
        f.flags = r.readUI8();

        return f;

    }


    private Tag decodePlaceObject(int length) throws IOException
    {
        PlaceObject t = new PlaceObject(stagPlaceObject);
        int pos = r.getOffset();
        int idref = r.readUI16();
        t.depth = r.readUI16();
        t.setMatrix(decodeMatrix());
        if (length - r.getOffset() + pos != 0)
        {
            t.setCxform(decodeCxform());
        }
        t.setRef(dict.getTag(idref));
        return t;
    }

    private Tag decodePlaceObject2(int length) throws IOException
    {
        PlaceObject t;
        t = new PlaceObject(stagPlaceObject2);
        r.syncBits();

        int pos = r.getOffset();

        t.flags = r.readUI8();
        t.depth = r.readUI16();

        if (t.hasCharID())
        {
            int idref = r.readUI16();
            t.ref = dict.getTag(idref);
        }
        if (t.hasMatrix())
        {
            t.matrix = decodeMatrix();
        }
        if (t.hasCxform())
        {
            // ed 5/22/03 the SWF 6 file format spec says this will be a CXFORM, but
            // the spec is wrong.  the player expects a CXFORMA.
            t.colorTransform = decodeCxforma();
        }
        if (t.hasRatio())
        {
            t.ratio = r.readUI16();
        }
        if (t.hasName())
        {
            t.name = r.readString();
        }
        if (t.hasClipDepth())
        {
            t.clipDepth = r.readUI16();
        }
        if (t.hasClipAction())
        {
            ActionDecoder actionDecoder = new ActionDecoder(r,swd);
            actionDecoder.setKeepOffsets(keepOffsets);
            t.clipActions = actionDecoder.decodeClipActions(length - (r.getOffset() - pos));
        }
        return t;
    }


    private CXFormWithAlpha decodeCxforma() throws IOException
    {
        CXFormWithAlpha c = new CXFormWithAlpha();
        r.syncBits();
        c.hasAdd = r.readBit();
        c.hasMult = r.readBit();
        int nbits = r.readUBits(4);
        if (c.hasMult)
        {
            c.redMultTerm = r.readSBits(nbits);
            c.greenMultTerm = r.readSBits(nbits);
            c.blueMultTerm = r.readSBits(nbits);
            c.alphaMultTerm = r.readSBits(nbits);
        }
        if (c.hasAdd)
        {
            c.redAddTerm = r.readSBits(nbits);
            c.greenAddTerm = r.readSBits(nbits);
            c.blueAddTerm = r.readSBits(nbits);
            c.alphaAddTerm = r.readSBits(nbits);
        }
        return c;
    }

    private Tag decodeProtect(int length) throws IOException
    {
        GenericTag t;
        t = new GenericTag(stagProtect);
        t.data = new byte[length];
        r.readFully(t.data);
        return t;
    }

    private Tag decodeDefineButtonCxform() throws IOException
    {
        DefineButtonCxform t;
        t = new DefineButtonCxform();
        int idref = r.readUI16();
        t.button = (DefineButton) dict.getTag(idref);
        if (t.button.cxform != null)
        {
            handler.error("button " + dict.getId(t.button) + " cxform redefined");
        }
        t.button.cxform = t;
        t.colorTransform = decodeCxform();
        return t;
    }

    private Tag decodeDefineJPEG2(int length) throws IOException
    {
        DefineBits t = new DefineBits(stagDefineBitsJPEG2);
        int pos = r.getOffset();
        int id = r.readUI16();
        length -= r.getOffset() - pos;
        t.data = new byte[length];
        r.readFully(t.data);

        dict.add(id, t);
        return t;
    }

    private Tag decodeDefineBitsLossless(int length) throws IOException
    {
        DefineBitsLossless t = new DefineBitsLossless(stagDefineBitsLossless);
        SwfDecoder r1 = r;

        int pos = r1.getOffset();

        int id = r1.readUI16();
        t.format = r1.readUI8();
        t.width = r1.readUI16();
        t.height = r1.readUI16();

        byte[] data;

        switch (t.format)
        {
        case 3:
            int tableSize = r1.readUI8() + 1;
            length -= r1.getOffset() - pos;
            data = new byte[length];
            r1.readFully(data);
            r1 = new SwfDecoder(new InflaterInputStream(new ByteArrayInputStream(data)), getSwfVersion());
            decodeColorMapData(r1, t, tableSize);
            break;
        case 4:
        case 5:
            length -= r1.getOffset() - pos;
            data = new byte[length];
            r1.readFully(data);
            r1 = new SwfDecoder(new InflaterInputStream(new ByteArrayInputStream(data)), getSwfVersion());
            t.data = new byte[t.width * t.height * 4];
            r1.readFully(t.data);
            break;
        default:
            throw new SwfFormatException("Illegal bitmap format " + t.format);
        }

        dict.add(id, t);
        return t;
    }

    private void decodeColorMapData(SwfDecoder r1, DefineBitsLossless tag, int tableSize) throws IOException
    {
        tag.colorData = new int[tableSize];

        for (int i = 0; i < tableSize; i++)
        {
            tag.colorData[i] = decodeRGB(r1);
        }

        int width = tag.width;
        int height = tag.height;

        if (width % 4 != 0)
        {
            width = (width / 4 + 1) * 4;
        }

        tag.data = new byte[width * height];

        r1.readFully(tag.data);
    }

    private Tag decodeSoundStreamBlock(int length) throws IOException
    {
        GenericTag t = new GenericTag(stagSoundStreamBlock);
        t.data = new byte[length];
        r.readFully(t.data);
        return t;
    }

    private Tag decodeSoundStreamHead(int code) throws IOException
    {
        SoundStreamHead t;
        t = new SoundStreamHead(code);
        r.syncBits();

        // mixFormat
        r.readUBits(4); // reserved
        t.playbackRate = r.readUBits(2);
        t.playbackSize = r.readUBits(1);
        t.playbackType = r.readUBits(1);

        // format
        t.compression = r.readUBits(4);
        t.streamRate = r.readUBits(2);
        t.streamSize = r.readUBits(1);
        t.streamType = r.readUBits(1);

        t.streamSampleCount = r.readUI16();

		if (t.compression == SoundStreamHead.sndCompressMP3)
		{
			t.latencySeek = r.readSI16();
		}
        return t;
    }

    private Tag decodeDefineButtonSound() throws IOException
    {
        DefineButtonSound t;
        t = new DefineButtonSound();
        int idref = r.readUI16();
        t.button = (DefineButton) dict.getTag(idref);
        if (t.button.sounds != null)
        {
            handler.error("button " + idref + " sound redefined");
        }
        t.button.sounds = t;

        idref = r.readUI16();
        if (idref != 0)
        {
            t.sound0 = dict.getTag(idref);
            t.info0 = decodeSoundInfo();
        }
        idref = r.readUI16();
        if (idref != 0)
        {
            t.sound1 = dict.getTag(idref);
            t.info1 = decodeSoundInfo();
        }
        idref = r.readUI16();
        if (idref != 0)
        {
            t.sound2 = dict.getTag(idref);
            t.info2 = decodeSoundInfo();
        }
        idref = r.readUI16();
        if (idref != 0)
        {
            t.sound3 = dict.getTag(idref);
            t.info3 = decodeSoundInfo();
        }
        return t;
    }

    private Tag decodeStartSound() throws IOException
    {
        StartSound t;
        t = new StartSound();
        int idref = r.readUI16();
        t.sound = (DefineSound) dict.getTag(idref);
        t.soundInfo = decodeSoundInfo();
        return t;
    }

    private SoundInfo decodeSoundInfo() throws IOException
    {
        SoundInfo i = new SoundInfo();

        r.syncBits();

        r.readUBits(2); // reserved
        i.syncStop = r.readBit();
        i.syncNoMultiple = r.readBit();

        boolean hasEnvelope = r.readBit();
        boolean hasLoops = r.readBit();
        boolean hasOutPoint = r.readBit();
        boolean hasInPoint = r.readBit();

        if (hasInPoint)
        {
            i.inPoint = r.readUI32();
        }
        if (hasOutPoint)
        {
            i.outPoint = r.readUI32();
        }
        if (hasLoops)
        {
            i.loopCount = r.readUI16();
        }
        if (hasEnvelope)
        {
            int points = r.readUI8();
            i.records = new long[points];
            for (int k = 0; k < points; k++)
            {
                i.records[k] = r.read64();
            }
        }

        return i;
    }

    private Tag decodeDefineSound(int length) throws IOException
    {
        DefineSound t;
        t = new DefineSound();
        int pos = r.getOffset();

        int id = r.readUI16();

        r.syncBits();

        t.format = r.readUBits(4);
        t.rate = r.readUBits(2);
        t.size = r.readUBits(1);
        t.type = r.readUBits(1);
        t.sampleCount = r.readUI32();

        length -= r.getOffset() - pos;

        t.data = new byte[length];
        r.readFully(t.data);

        dict.add(id, t);
        return t;
    }

    private Tag decodeDefineFontInfo(int code, int length) throws IOException
    {
        DefineFontInfo t;
        t = new DefineFontInfo(code);
        int pos = r.getOffset();

        int idref = r.readUI16();
        t.font = (DefineFont1) dict.getTag(idref);
        if (t.font.fontInfo != null)
        {
            handler.error("font " + idref + " info redefined");
        }
        t.font.fontInfo = t;
        t.name = r.readLengthString();

        r.syncBits();

        r.readUBits(3); // reserved
        t.shiftJIS = r.readBit();
        t.ansi = r.readBit();
        t.italic = r.readBit();
        t.bold = r.readBit();
        t.wideCodes = r.readBit();

        if (code == stagDefineFontInfo2)
        {
            if (!t.wideCodes)
                handler.error("widecodes must be true in DefineFontInfo2");
            if (getSwfVersion() < 6)
                handler.error("DefineFont2 not valid before SWF6");
            t.langCode = r.readUI8();
        }

        length -= r.getOffset() - pos;

        if (t.wideCodes)
        {
            length = length / 2;
            t.codeTable = new char[length];
            for (int i = 0; i < length; i++)
            {
                t.codeTable[i] = (char)r.readUI16();
            }
        }
        else
        {
            t.codeTable = new char[length];
            for (int i = 0; i < length; i++)
            {
                t.codeTable[i] = (char)r.readUI8();
            }
        }
        return t;
    }

    private Tag decodeDoAction(int length) throws IOException
    {
        DoAction t = new DoAction();
        ActionDecoder actionDecoder = new ActionDecoder(r,swd);
        actionDecoder.setKeepOffsets(keepOffsets);
        t.actionList = actionDecoder.decode(length);
        return t;
    }

    private Tag decodeDefineText(int type) throws IOException
    {
        DefineText t = new DefineText(type);

        int id = r.readUI16();
        t.bounds = decodeRect();
        t.matrix = decodeMatrix();

        int glyphBits = r.readUI8();
        int advanceBits = r.readUI8();
        // todo range check - glyphBits and advanceBits must be <= 32
        ArrayList<TextRecord> list = new ArrayList<TextRecord>(2);

        int code;
        while ((code = r.readUI8()) != 0)
        {
            list.add(decodeTextRecord(type, code, glyphBits, advanceBits));
        }

        t.records = list;

        dict.add(id, t);
        return t;
    }

    private GlyphEntry[] decodeGlyphEntries(int glyphBits, int advanceBits, int count) throws IOException
    {
        GlyphEntry[] e = new GlyphEntry[count];

        r.syncBits();
        for (int i = 0; i < count; i++)
        {
            GlyphEntry ge = new GlyphEntry();

            ge.setIndex( r.readUBits(glyphBits) );
            ge.advance = r.readSBits(advanceBits);

            e[i] = ge;
        }

        return e;
    }

    private TextRecord decodeTextRecord(int defineText, int flags, int glyphBits, int advanceBits) throws IOException
    {
        TextRecord t = new TextRecord();

        t.flags = flags;

        if (t.hasFont())
        {
            int idref = r.readUI16();
            t.font = (DefineFont) dict.getTag(idref);
        }

        if (t.hasColor())
        {
            switch (defineText)
            {
            case stagDefineText:
                t.color = decodeRGB(r);
                break;
            case stagDefineText2:
                t.color = decodeRGBA(r);
                break;
            default:
                assert false;
            }
        }

        if (t.hasX())
        {
            t.xOffset = r.readSI16();
        }

        if (t.hasY())
        {
            t.yOffset = r.readSI16();
        }

        if (t.hasHeight())
        {
            t.height = r.readUI16();
        }

        int count = r.readUI8();
        t.entries = decodeGlyphEntries(glyphBits, advanceBits, count);

        return t;
    }

    private Tag decodeDefineFont() throws IOException
    {
        DefineFont1 t;
        t = new DefineFont1();
        int id = r.readUI16();
        int offset = r.readUI16();
        int numGlyphs = offset/2;

        t.glyphShapeTable = new Shape[numGlyphs];

        // skip the offset table
        for (int i = 1; i < numGlyphs; i++)
        {
            r.readUI16();
        }

        for (int i = 0; i < numGlyphs; i++)
        {
            t.glyphShapeTable[i] = decodeShape(stagDefineShape3);
        }

        dict.add(id, t);
        dict.addFontFace( t );
        return t;
    }

    private Tag decodeSetBackgroundColor() throws IOException
    {
        SetBackgroundColor t;
        t = new SetBackgroundColor( decodeRGB(r));
        return t;
    }

	/**
	 * decode jpeg tables.  only one per movie.  second and subsequent
	 * occurences of this tag are ignored by the player.
	 * @param length
	 * @return
	 * @throws IOException
	 */
    private GenericTag decodeJPEGTables(int length) throws IOException
    {
        GenericTag t;
        t = new GenericTag(stagJPEGTables);
        t.data = new byte[length];
        r.readFully(t.data);
        return t;
    }

    private Tag decodeDefineButton(int length) throws IOException
    {
		int startPos = r.getOffset();
        DefineButton t;
        t = new DefineButton(stagDefineButton);
        int id = r.readUI16();

        ArrayList<ButtonRecord> list = new ArrayList<ButtonRecord>();
        ButtonRecord record;
        do
        {
            record = decodeButtonRecord(t.code);
            if (record != null)
            {
                list.add(record);
            }
        }
        while (record != null);

        t.buttonRecords = new ButtonRecord[list.size()];
        list.toArray(t.buttonRecords);

        // old school button actions only handle one possible transition
        int consumed = r.getOffset()-startPos;
        t.condActions = new ButtonCondAction[1];
        t.condActions[0].overDownToOverUp = true;
        ActionDecoder actionDecoder = new ActionDecoder(r,swd);
        actionDecoder.setKeepOffsets(keepOffsets);
        t.condActions[0].actionList = actionDecoder.decode(length-consumed);
        t.trackAsMenu = false;

        dict.add(id, t);
        return t;
    }

    private ButtonRecord decodeButtonRecord(int type) throws IOException
    {
    	boolean hasFilterList = false, hasBlendMode = false;
        ButtonRecord b = new ButtonRecord();

        r.syncBits();

        int reserved;
        if (type == stagDefineButton2)
        {
            reserved = r.readUBits(2);
            hasBlendMode = r.readBit();
            hasFilterList = r.readBit();
        }
        else
        {
            reserved = r.readUBits(4);
        }
        b.hitTest = r.readBit();
        b.down = r.readBit();
        b.over = r.readBit();
        b.up = r.readBit();

        if (reserved == 0 && !b.hitTest && !b.down && !b.over && !b.up)
        {
            return null;
        }

        int idref = r.readUI16();
        b.characterRef = dict.getTag(idref);
        b.placeDepth = r.readUI16();
        b.placeMatrix = decodeMatrix();

        if (type == stagDefineButton2)
        {
            b.colorTransform = decodeCxforma();
            if (hasFilterList)
            {
            	b.filters = decodeFilterList();
            }
            if (hasBlendMode)
            {
            	b.blendMode = r.readUI8();
            }
        }

        return b;
    }

    private Tag decodeDefineBinaryData(int length) throws IOException
    {
        DefineBinaryData t = new DefineBinaryData();
        int pos = r.getOffset();
        int id = r.readUI16();
        t.reserved = r.readSI32();
        length -= r.getOffset() - pos;
        t.data = new byte[length];
        r.readFully(t.data);
        dict.add(id, t);
        return t;
    }

    private Tag decodeDefineBits(int length) throws IOException
    {
        DefineBits t;
        t = new DefineBits(stagDefineBits);
        int pos = r.getOffset();
        int id = r.readUI16();
        length -= r.getOffset() - pos;
        t.data = new byte[length];
        r.readFully(t.data);
        t.jpegTables = jpegTables;
        dict.add(id, t);
        return t;
    }

    private Tag decodeRemoveObject(int code) throws IOException
    {
        RemoveObject t;
        t = new RemoveObject(code);
        if (code == stagRemoveObject)
        {
            int idref = r.readUI16();
            t.ref = dict.getTag(idref);
        }
        t.depth = r.readUI16();
        return t;
    }

    private CXForm decodeCxform() throws IOException
    {
        CXForm c = new CXForm();
        r.syncBits();

        c.hasAdd = r.readBit();
        c.hasMult = r.readBit();
        int nbits = r.readUBits(4);
        if (c.hasMult)
        {
            c.redMultTerm = r.readSBits(nbits);
            c.greenMultTerm = r.readSBits(nbits);
            c.blueMultTerm = r.readSBits(nbits);
        }
        if (c.hasAdd)
        {
            c.redAddTerm = r.readSBits(nbits);
            c.greenAddTerm = r.readSBits(nbits);
            c.blueAddTerm = r.readSBits(nbits);
        }
        return c;
    }

    private Tag decodeMetadata() throws IOException
    {
        Metadata t = new Metadata();
        t.xml = r.readString();
        return t;
    }

    private Tag decodeDefineShape(int shape) throws IOException
    {
        DefineShape t = new DefineShape(shape);

        int id = r.readUI16();
        t.bounds = decodeRect();
        if (shape == stagDefineShape4)
        {
            t.edgeBounds = decodeRect();
            r.readUBits(5);
            t.usesFillWindingRule = r.readBit();
            t.usesNonScalingStrokes = r.readBit();
            t.usesScalingStrokes = r.readBit();
        }
        t.shapeWithStyle = decodeShapeWithStyle(shape);

        dict.add(id, t);
        return t;
    }

    private ShapeWithStyle decodeShapeWithStyle(int shape) throws IOException
    {
        ShapeWithStyle sw = new ShapeWithStyle();

        r.syncBits();

        sw.fillstyles = decodeFillstyles(shape);
        sw.linestyles = decodeLinestyles(shape);

        Shape s = decodeShape(shape);

        sw.shapeRecords = s.shapeRecords;

        return sw;
    }

    private ArrayList<LineStyle> decodeLinestyles(int shape) throws IOException
    {
        ArrayList<LineStyle> a = new ArrayList<LineStyle>();

        int count = r.readUI8();
        if (count == 0xFF)
        {
            count = r.readUI16();
        }

        for (int i = 0; i < count; i++)
        {
            a.add(decodeLineStyle(shape));
        }

        return a;
    }

    private LineStyle decodeLineStyle(int shape) throws IOException
    {
        LineStyle s = new LineStyle();
        s.width = r.readUI16();

        if (shape == stagDefineShape4)
        {
            s.flags = r.readUI16();
            if (s.hasMiterJoint())
                s.miterLimit = r.readUI16();    // 8.8 fixedpoint
        }
        if ((shape == stagDefineShape4) && (s.hasFillStyle()))
        {
            s.fillStyle = decodeFillStyle(shape);
        }
        else if ((shape == stagDefineShape3) || (shape == stagDefineShape4))
        {
            s.color = decodeRGBA(r);
        }
        else
        {
            s.color = decodeRGB(r);
        }

        return s;
    }

    private ArrayList<FillStyle> decodeFillstyles(int shape) throws IOException
    {
        ArrayList<FillStyle> a = new ArrayList<FillStyle>();

        int count = r.readUI8();
        if (count == 0xFF)
        {
            count = r.readUI16();
        }

        for (int i = 0; i < count; i++)
        {
            a.add(decodeFillStyle(shape));
        }

        return a;
    }

    private FillStyle decodeFillStyle(int shape) throws IOException
    {
        FillStyle s = new FillStyle();

        s.type = r.readUI8();
        switch (s.type)
        {
        case FillStyle.FILL_SOLID: // 0x00
            if (shape == stagDefineShape3 || shape == stagDefineShape4)
                s.color = decodeRGBA(r);
            else if (shape == stagDefineShape2 || shape == stagDefineShape)
                s.color = decodeRGB(r);
            else
                throw new SwfFormatException("bad shape code");
            break;
        case FillStyle.FILL_GRADIENT: // 0x10 linear gradient fill
        case FillStyle.FILL_RADIAL_GRADIENT: // 0x12 radial gradient fill
        case FillStyle.FILL_FOCAL_RADIAL_GRADIENT: // 0x13 focal radial gradient fill
            s.matrix = decodeMatrix();
            s.gradient = decodeGradient(shape, s.type);
            break;
        case FillStyle.FILL_BITS: // 0x40 tiled bitmap fill
        case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP): // 0x41 clipped bitmap fill
        case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_NOSMOOTH): // 0x42 tiled non-smoothed fill
        case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP | FillStyle.FILL_BITS_NOSMOOTH): // 0x43 clipped non-smoothed fill
            int idref = r.readUI16();
            try
            {
                s.bitmap = dict.getTag(idref);
            }
            catch (IllegalArgumentException e)
            {
                s.bitmap = null;
                handler.error(e.getMessage());
            }
            s.matrix = decodeMatrix();
            break;
        default:
            throw new SwfFormatException("unrecognized fill style type: " + s.type);
        }

        return s;
    }

    private Gradient decodeGradient(int shape, int filltype) throws IOException
    {
        Gradient gradient = (filltype == FillStyle.FILL_FOCAL_RADIAL_GRADIENT)? new FocalGradient() : new Gradient();
        r.syncBits();
        gradient.spreadMode = r.readUBits( 2 );
        gradient.interpolationMode = r.readUBits( 2 );
        int count = r.readUBits( 4 );
        gradient.records = new GradRecord[count];

        for (int i = 0; i < count; i++)
        {
            gradient.records[i] = decodeGradRecord(shape);
        }

        if (filltype == FillStyle.FILL_FOCAL_RADIAL_GRADIENT)
        {
            ((FocalGradient)gradient).focalPoint = r.readFixed8();
        }

        return gradient;
    }

    private GradRecord decodeGradRecord(int shape) throws IOException
    {
        GradRecord g = new GradRecord();
        g.ratio = r.readUI8();

        switch (shape)
        {
        case stagDefineShape:
        case stagDefineShape2:
            g.color = decodeRGB(r);
            break;
        case stagDefineShape3:
        case stagDefineShape4:
            g.color = decodeRGBA(r);
            break;
        }

        return g;
    }

    private Matrix decodeMatrix() throws IOException
    {
        Matrix m = new Matrix();

        r.syncBits();
        m.hasScale = r.readBit();
        if (m.hasScale)
        {
            int nScaleBits = r.readUBits(5);
            m.scaleX = r.readSBits(nScaleBits);
            m.scaleY = r.readSBits(nScaleBits);
        }

        m.hasRotate = r.readBit();
        if (m.hasRotate)
        {
            int nRotateBits = r.readUBits(5);
            m.rotateSkew0 = r.readSBits(nRotateBits);
            m.rotateSkew1 = r.readSBits(nRotateBits);
        }

        int nTranslateBits = r.readUBits(5);
        m.translateX = r.readSBits(nTranslateBits);
        m.translateY = r.readSBits(nTranslateBits);

        return m;
    }

    private int decodeRGBA(SwfDecoder r) throws IOException
    {
        int color = r.readUI8() << 16; // red
        color |= r.readUI8() << 8; // green
        color |= r.readUI8(); // blue
        color |= r.readUI8() << 24; // alpha

        // resulting format is 0xAARRGGBB
        return color;
    }

    private int decodeRGB(SwfDecoder r) throws IOException
    {
        int color = r.readUI8() << 16; // red
        color |= r.readUI8()<<8; // green
        color |= r.readUI8(); // blue

        // resulting format is 0x00RRGGBB
        return color;
    }

    private Shape decodeGlyph(int shape, int count) throws IOException
    {
        Shape s1 = new Shape();

        r.syncBits();

        // SDK-18153 - Hack to work around third-party generated SWFs that
        // do not include at least one shape record in glyph SHAPE.
        if (count > 0)
        {
            // we use int[1] so we can pass numBits by reference
            int[] numFillBits = new int[] { r.readUBits(4) };
            int[] numLineBits = new int[] { r.readUBits(4) };

            if (count > 1)
            {
                s1.shapeRecords = decodeShapeRecords(shape, numFillBits, numLineBits);
            }
        }

        return s1;
    }

    private Shape decodeShape(int shape) throws IOException
    {
        Shape s1 = new Shape();

        r.syncBits();

        // we use int[1] so we can pass numBits by reference
        int[] numFillBits = new int[] { r.readUBits(4) };
        int[] numLineBits = new int[] { r.readUBits(4) };

        s1.shapeRecords = decodeShapeRecords(shape, numFillBits, numLineBits);

        return s1;
    }

    private List<ShapeRecord> decodeShapeRecords(int shape, int[] numFillBits, int[] numLineBits) throws IOException
    {
        ArrayList<ShapeRecord> list = new ArrayList<ShapeRecord>();
        boolean endShapeRecord = false;
        do
        {
            if (r.readBit())
            {
                // edge
                if (r.readBit())
                {
                    // line
                    list.add(decodeStraightEdgeRecord());
                }
                else
                {
                    // curve
                    list.add(decodeCurvedEdgeRecord());
                }
            }
            else
            {
                // style change
                boolean stateNewStyles = r.readBit();
                boolean stateLineStyle = r.readBit();
                boolean stateFillStyle1 = r.readBit();
                boolean stateFillStyle0 = r.readBit();
                boolean stateMoveTo = r.readBit();

                if (stateNewStyles || stateLineStyle || stateFillStyle1 ||
                        stateFillStyle0 || stateMoveTo)
                {
                    StyleChangeRecord s = decodeStyleChangeRecord(stateNewStyles, stateLineStyle,
                                                                  stateFillStyle1, stateFillStyle0, stateMoveTo,
                                                                  shape, numFillBits, numLineBits);

                    list.add(s);
                }
                else
                {
                    endShapeRecord = true;
                }
            }
        }
        while (!endShapeRecord);

        return list;
    }

    private CurvedEdgeRecord decodeCurvedEdgeRecord() throws IOException
    {
        CurvedEdgeRecord s = new CurvedEdgeRecord();
        int nbits = 2+r.readUBits(4);
        s.controlDeltaX = r.readSBits(nbits);
        s.controlDeltaY = r.readSBits(nbits);
        s.anchorDeltaX = r.readSBits(nbits);
        s.anchorDeltaY = r.readSBits(nbits);
        return s;
    }

    private StraightEdgeRecord decodeStraightEdgeRecord() throws IOException
    {
        int nbits = 2+r.readUBits(4);
        if (r.readBit())
        {
            // general line
            int dx = r.readSBits(nbits);
            int dy = r.readSBits(nbits);
            return new StraightEdgeRecord(dx, dy);
        }
        else
        {
            if (r.readBit())
            {
                // vertical
                int dy = r.readSBits(nbits);
                return new StraightEdgeRecord(0, dy);
            }
            else
            {
                // horizontal
                int dx = r.readSBits(nbits);
                return new StraightEdgeRecord(dx, 0);
            }
        }
    }

    private StyleChangeRecord decodeStyleChangeRecord(boolean stateNewStyles,
                                                      boolean stateLineStyle,
                                                      boolean stateFillStyle1,
                                                      boolean stateFillStyle0,
                                                      boolean stateMoveTo,
                                                      int shape,
                                                      int[] numFillBits,
                                                      int[] numLineBits) throws IOException
    {
        StyleChangeRecord s = new StyleChangeRecord();

        s.stateNewStyles = stateNewStyles;
        s.stateLineStyle = stateLineStyle;
        s.stateFillStyle1 = stateFillStyle1;
        s.stateFillStyle0 = stateFillStyle0;
        s.stateMoveTo = stateMoveTo;

        if (s.stateMoveTo)
		{
			int moveBits = r.readUBits(5);
			s.moveDeltaX = r.readSBits(moveBits);
			s.moveDeltaY = r.readSBits(moveBits);
		}

        if (s.stateFillStyle0)
        {
            s.fillstyle0 = r.readUBits(numFillBits[0]);
        }

        if (s.stateFillStyle1)
        {
            s.fillstyle1 = r.readUBits(numFillBits[0]);
        }

        if (s.stateLineStyle)
        {
            s.linestyle = r.readUBits(numLineBits[0]);
        }

        if (s.stateNewStyles)
        {
            s.fillstyles = decodeFillstyles(shape);
            s.linestyles = decodeLinestyles(shape);

            r.syncBits();

            numFillBits[0] = r.readUBits(4);
            numLineBits[0] = r.readUBits(4);
        }
        return s;
    }

    private Tag decodeDefineSprite(int endpos) throws IOException
    {
        DefineSprite t = new DefineSprite();
        t.header = header;
        int id = r.readUI16();
        t.framecount = r.readUI16();
        decodeTags(t.tagList);
        while (r.getOffset() < endpos)
        {
            // extra data at end of sprite.  must be zero
            int b = r.readUI8();
            if (b != 0)
            {
                throw new SwfFormatException("nonzero data past end of sprite");
            }
        }
        dict.add(id, t);
        return t;
    }

    public Tag decodeSerialNumber() throws IOException
    {
        int product = r.readSI32();
        int edition = r.readSI32();

        byte[] version = new byte[2];
        r.read(version);
        byte majorVersion = version[0];
        byte minorVersion = version[1];

        long build = r.read64();
        long compileDate = r.read64();

        return new ProductInfo(product, edition, majorVersion, minorVersion, build, compileDate);
    }

    public Header decodeHeader() throws IOException, FatalParseException
    {
        Header header = new Header();
        byte[] sig = new byte[8];

        new DataInputStream(swfIn).readFully(sig);
        header.version = sig[3];
        header.length = sig[4]&0xFF | (sig[5]&0xFF)<<8 | (sig[6]&0xFF)<<16 | sig[7]<<24;

        if (sig[0] == 'C' && sig[1] == 'W' && sig[2] == 'S')
        {
            header.compressed = true;
            r = new SwfDecoder(new InflaterInputStream(swfIn), header.version, 8);
        }
        else if (sig[0] == 'F' || sig[1] == 'W' || sig[2] == 'S')
        {
            r = new SwfDecoder(swfIn, header.version, 8);
        }
        else
        {
            handler.error("Invalid signature found.  Not a SWF file");
            throw new FatalParseException();
        }

        header.size = decodeRect();
        header.rate = r.readUI8() << 8 | r.readUI8();
        header.framecount = r.readUI16();

        return header;
    }

    public Tag decodeFileAttributes() throws IOException
    {
        FileAttributes tag = new FileAttributes();
        r.syncBits();
        r.readUBits(1); //reserved
        tag.useDirectBlit = r.readBit();
        tag.useGPU = r.readBit();
        tag.hasMetadata = r.readBit();
        tag.actionScript3 = r.readBit();
        tag.suppressCrossDomainCaching = r.readBit();
        tag.swfRelativeUrls = r.readBit();
        tag.useNetwork = r.readBit();
        r.readUBits(24); //reserved
        return tag;
    }

    public Tag decodeDefineFontAlignZones() throws IOException
    {
        DefineFontAlignZones zones = new DefineFontAlignZones();
        int fontID = r.readUI16();
        zones.font = (DefineFont3)dict.getTag(fontID);
        zones.font.zones = zones;
        zones.csmTableHint = r.readUBits(2);
        r.readUBits(6);  // reserved
        zones.zoneTable = new ZoneRecord[zones.font.glyphShapeTable.length];
        for (int i = 0; i < zones.font.glyphShapeTable.length; i++)
        {
            ZoneRecord record = new ZoneRecord();
            zones.zoneTable[i] = record;
            record.numZoneData = r.readUI8();
            record.zoneData = new long[record.numZoneData];
            for (int j = 0; j < record.numZoneData; j++)
            {
                record.zoneData[j] = r.readUI32();
            }
            record.zoneMask = r.readUI8();
        }
        return zones;
    }

    public Tag decodeCSMTextSettings() throws IOException
    {
        CSMTextSettings tag = new CSMTextSettings();
        int textID = r.readUI16();
        if (textID != 0)
        {
            tag.textReference = dict.getTag(textID);
            if (tag.textReference instanceof DefineText)
            {
                ((DefineText)tag.textReference).csmTextSettings = tag;
            }
            else if (tag.textReference instanceof DefineEditText)
            {
                ((DefineEditText)tag.textReference).csmTextSettings = tag;
            }
            else
            {
                handler.error("CSMTextSettings' textID must reference a valid DefineText or DefineEditText.  References " + tag.textReference);
            }
        }
        tag.styleFlagsUseSaffron = r.readUBits(2);
        tag.gridFitType = r.readUBits(3);
        r.readUBits(3); // reserved
        // FIXME: thickness/sharpness should be read in as 32 bit IEEE Single Precision format in little Endian
        tag.thickness = r.readUBits(32);
        tag.sharpness = r.readUBits(32);
        r.readUBits(8); // reserved
        return tag;
    }

	public Tag decodeDefineFontName() throws IOException
	{
	    DefineFontName tag = new DefineFontName();
	    int fontID = r.readUI16();
	    tag.font = (DefineFont)dict.getTag(fontID);
	    tag.font.license = tag;
		tag.fontName = r.readString();
		tag.copyright = r.readString();
		return tag;
	}

    private Rect decodeRect() throws IOException
    {
        r.syncBits();

        Rect rect = new Rect();

        int nBits = r.readUBits(5);
        rect.xMin = r.readSBits(nBits);
        rect.xMax = r.readSBits(nBits);
        rect.yMin = r.readSBits(nBits);
        rect.yMax = r.readSBits(nBits);

        return rect;
    }
}
