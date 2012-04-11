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

import flash.swf.tags.*;
import flash.swf.types.ButtonCondAction;
import flash.swf.types.ButtonRecord;
import flash.swf.types.CXForm;
import flash.swf.types.CXFormWithAlpha;
import flash.swf.types.CurvedEdgeRecord;
import flash.swf.types.EdgeRecord;
import flash.swf.types.FillStyle;
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
import flash.swf.types.Filter;
import flash.swf.types.DropShadowFilter;
import flash.swf.types.BlurFilter;
import flash.swf.types.ColorMatrixFilter;
import flash.swf.types.GlowFilter;
import flash.swf.types.ConvolutionFilter;
import flash.swf.types.BevelFilter;
import flash.swf.types.GradientGlowFilter;
import flash.swf.types.GradientBevelFilter;
import flash.swf.types.Gradient;
import flash.swf.types.FocalGradient;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * A SWF tag encoder.  It is typically used by calling one or more of
 * the TagHandler methods and then writeTo().
 */
public class TagEncoder extends TagHandler
        implements TagValues
{
    // changed from private to protected to support Flash Authoring - jkamerer 2007.07.30
    protected SwfEncoder writer;
    private SwfEncoder tagw;
    private int width;
    private int height;
    private int frames;
    private int framecountPos;
    protected DebugEncoder debug;
    private Header header;
    
    protected Dictionary dict;
    private int uuidOffset;

    public TagEncoder()
    {
        dict = new Dictionary();
    }

    public TagEncoder( Dictionary dict )
    {
        this.dict = dict;
    }

    public void productInfo(ProductInfo tag)
    {
        tagw.write32( tag.getProduct() );
        tagw.write32( tag.getEdition() );
        tagw.write( new byte[] { tag.getMajorVersion(), tag.getMinorVersion() } );
        tagw.write64( tag.getBuild() );
        tagw.write64( tag.getCompileDate() );
        encodeTag(tag);
    }

    public void fileAttributes(FileAttributes tag)
    {
        tagw.writeUBits(0, 1);
        tagw.writeBit(tag.useDirectBlit);
        tagw.writeBit(tag.useGPU);
        tagw.writeBit(tag.hasMetadata);
        tagw.writeBit(tag.actionScript3);
        tagw.writeBit(tag.suppressCrossDomainCaching);
        tagw.writeBit(tag.swfRelativeUrls);
        tagw.writeBit(tag.useNetwork);
        tagw.writeUBits(0, 24);
        encodeTag(tag);
    }

    public void metadata(Metadata tag)
    {
        tagw.writeString( tag.xml );
        encodeTag(tag);
    }

    public int getPos()
    {
        return writer.getPos();
    }

    protected int getSwfVersion()
    {
        return header.version;
    }

    protected int getFrameRate()
    {
        return header.rate;
    }

    public void setEncoderDictionary(Dictionary dict)
    {
        assert ( (this.dict == null) || (this.dict.ids.size() == 0));
        this.dict = dict;
    }

    public Dictionary getDictionary()
    {
        return dict;
    }

	protected SwfEncoder createEncoder(int swfVersion)
	{
		return new SwfEncoder(swfVersion);
	}

    public boolean isDebug()
    {
        return debug != null;
    }
    
	public CompressionLevel getCompressionLevel() 
	{
		return isDebug() ? CompressionLevel.BestSpeed : CompressionLevel.BestCompression;
	}

    public void header(Header header)
    {
        // get some header properties we need to know
        int swfVersion = header.version;
        this.header = header;
        this.writer = createEncoder(swfVersion);
        this.tagw = createEncoder(swfVersion);
        width = header.size.getWidth();
        height = header.size.getHeight();
        frames = 0;

        // write the header
        writer.writeUI8(header.compressed ? 'C' : 'F');
        writer.writeUI8('W');
        writer.writeUI8('S');
        writer.writeUI8(header.version);
        writer.write32((int)header.length);
        if (header.compressed)
        {
            writer.markComp();
        }
        encodeRect(header.size, writer);
        writer.writeUI8(header.rate >> 8);
        writer.writeUI8(header.rate & 255);
        framecountPos = writer.getPos();
        writer.writeUI16(header.framecount);
    }

    public int getWidth()
    {
        return width/20;
    }

    public int getHeight()
    {
        return height/20;
    }

    public void finish()
    {
        // write end marker
        writer.writeUI16(0);

        // update the length
        writer.write32at(4, writer.getPos());

        // update the frame count
        writer.writeUI16at(framecountPos, frames);
    }

    public void writeTo(OutputStream out) throws IOException
    {
        writer.writeTo(out, getCompressionLevel());
    }

    public void writeDebugTo(OutputStream out) throws IOException
    {
        debug.writeTo(out);
    }

    public void setMainDebugScript(String path)
    {
        debug.setMainDebugScript(path);
    }

    public void encodeRect(Rect r, SwfEncoder w)
    {
        int nBits = r.nbits();
        w.writeUBits(nBits, 5);
        w.writeSBits(r.xMin, nBits);
        w.writeSBits(r.xMax, nBits);
        w.writeSBits(r.yMin, nBits);
        w.writeSBits(r.yMax, nBits);
        w.flushBits();
    }

    public void debugID(DebugID tag)
    {
        encodeTagHeader(tag.code, tag.uuid.bytes.length, false);
        uuidOffset = writer.getPos();
        writer.write(tag.uuid.bytes);

        debug = new DebugEncoder();
        debug.header(getSwfVersion());
        debug.uuid(tag.uuid);
    }

    private void encodeTag(Tag tag)
    {
        try
        {
            tagw.compress(getCompressionLevel());
            encodeTagHeader(tag.code, tagw.getPos(), isLongHeader(tag));
            tagw.writeTo(writer, getCompressionLevel());
            tagw.reset();
        }
        catch (IOException e)
        {
            assert (false);
        }
    }

    private boolean isLongHeader(Tag t)
    {
        switch(t.code)
        {
        // [preilly] In the player code, ScriptThread::DefineBits() assumes all DefineBits
        // tags use a long header.  See "ch->data = AttachData(pos-8);".  If the player
        // also supported a short header, it would use "pos-4".
        case stagDefineBits:
        case stagDefineBitsJPEG2:
        case stagDefineBitsJPEG3:
        case stagDefineBitsLossless:
        case stagDefineBitsLossless2:
            return true;

        // [ed] the FlashPaper codebase also indicates that stagSoundStreamBlock must use
        // a long format header.  todo - verify by looking at the player code.
        case stagSoundStreamBlock:
            return true;

        // [edsmith] these tags have code in them.  When we're writing a SWD, we use long headers
        // so we can predict SWF offsets correctly when writing SWD line/offset records.
        case stagDefineButton:
        case stagDefineButton2:
        case stagDefineSprite:
        case stagDoInitAction:
        case stagDoAction:
            return isDebug();

        case stagPlaceObject2:
            return isDebug() && ((PlaceObject)t).hasClipAction();

        // all other tags will use short/long headers depending on their length
        default:
            return false;
        }
    }

    private void encodeTagHeader(int code, int length, boolean longHeader)
    {
        if (longHeader || length >= 63)
        {
            writer.writeUI16((code << 6) | 63);
            writer.write32(length);
        }
        else
        {
            writer.writeUI16((code << 6) | length);
        }
    }

    public void defineScalingGrid(DefineScalingGrid tag)
    {
        int idref = dict.getId(tag.scalingTarget);
        tagw.writeUI16(idref);
        encodeRect(tag.rect, tagw);
        encodeTag(tag);
    }

    public void defineBinaryData(DefineBinaryData tag)
    {
        encodeTagHeader(tag.code, 6+tag.data.length, false);
        int id = dict.add(tag);
        writer.writeUI16(id);
        writer.write32(tag.reserved);
        writer.write(tag.data);
    }

    public void defineBits(DefineBits tag)
    {
        encodeTagHeader(tag.code, 2+tag.data.length, true);
        int id = dict.add(tag);
        writer.writeUI16(id);
        writer.write(tag.data);
    }

    public void defineBitsJPEG2(DefineBits tag)
    {
        defineBits(tag);
    }

    public void defineBitsJPEG3(DefineBitsJPEG3 tag)
    {
        int id = dict.add(tag);
        tagw.writeUI16(id);
        tagw.write32(tag.data.length);
        tagw.write(tag.data);
        tagw.markComp();
        tagw.write(tag.alphaData);
        encodeTag(tag);
    }

    public void defineBitsLossless(DefineBitsLossless tag)
    {
        int id = dict.add(tag);
        tagw.writeUI16(id);
        tagw.writeUI8(tag.format);
        tagw.writeUI16(tag.width);
        tagw.writeUI16(tag.height);
        switch (tag.format)
        {
        case 3:
            tagw.writeUI8(tag.colorData.length - 1);
            tagw.markComp();
            encodeColorMapData(tag.colorData, tag.data, tagw);
            break;
        case 4:
        case 5:
            tagw.markComp();
            encodeBitmapData(tag.data, tagw);
            break;
        }
        encodeTag(tag);
    }

    private void encodeBitmapData(byte[] data, SwfEncoder w)
    {
        w.write(data);
    }

    private void encodeColorMapData(int[] colorData, byte[] pixelData, SwfEncoder w)
    {
        for (int i = 0; i < colorData.length; i++)
		{
            encodeRGB(colorData[i], w);
        }
        w.write(pixelData);
    }

    /**
     * @param rgb as 0x00RRGGBB
     * @param w
     */
    private void encodeRGB(int rgb, SwfEncoder w)
    {
        w.writeUI8(rgb>>>16);  // red. we don't mask this because if rgb has an Alpha value, something's wrong
        w.writeUI8((rgb>>>8)&255);
        w.writeUI8(rgb&255); // blue
    }

    public void defineBitsLossless2(DefineBitsLossless tag)
    {
        int id = dict.add(tag);
        tagw.writeUI16(id);
        tagw.writeUI8(tag.format);
        tagw.writeUI16(tag.width);
        tagw.writeUI16(tag.height);
        switch (tag.format)
        {
        case 3:
            tagw.writeUI8(tag.colorData.length - 1);
            tagw.markComp();
            encodeAlphaColorMapData(tag.colorData, tag.data, tagw);
            break;
        case 4:
        case 5:
            tagw.markComp();
            encodeBitmapData(tag.data, tagw);
            break;
        }
        encodeTag(tag);
    }

    private void encodeAlphaColorMapData(int[] colorData, byte[] pixelData, SwfEncoder w)
    {
        for (int i = 0; i < colorData.length; i++)
		{
            encodeRGBA(colorData[i], w);
		}
        w.write(pixelData);
    }

    /**
     * @param rgba as 0xAARRGGBB
     * @param w
     */
    private void encodeRGBA(int rgba, SwfEncoder w)
    {
        w.writeUI8((rgba>>>16)&255);    // red
        w.writeUI8((rgba>>>8)&255);     // green
        w.writeUI8(rgba&255);           // blue
        w.writeUI8(rgba>>>24);          // alpha
    }

    public void defineButton(DefineButton tag)
    {
        int id = dict.add(tag);
        tagw.writeUI16(id);

        if (isDebug())
        {
            debug.adjust = writer.getPos()+6;
        }

        for (int i = 0; i < tag.buttonRecords.length; i++)
        {
            encodeButtonRecord(tag.buttonRecords[i], tagw, tag.code);
        }
        tagw.writeUI8(0); // no more button records

        // assume there is only one condition we will handle
		new ActionEncoder(tagw,debug).encode(tag.condActions[0].actionList);
        tagw.writeUI8(0); // write action end flag, must be zero
        encodeTag(tag);

        if (isDebug())
        {
            debug.adjust = 0;
        }
    }

    private void encodeButtonRecord(ButtonRecord record, SwfEncoder w, int defineButton)
    {
    	if (defineButton == stagDefineButton2)
    	{
            w.writeUBits(0, 2);
            w.writeBit(record.blendMode != -1);
            w.writeBit(record.filters != null);
    	}
    	else
    	{
            w.writeUBits(0, 4);
    	}
        w.writeBit(record.hitTest);
        w.writeBit(record.down);
        w.writeBit(record.over);
        w.writeBit(record.up);

        w.writeUI16(dict.getId(record.characterRef));
        w.writeUI16(record.placeDepth);
        encodeMatrix(record.placeMatrix, w);

        if (defineButton == stagDefineButton2)
        {
            encodeCxforma(record.colorTransform, w);
            if (record.filters != null)
            {
            	this.encodeFilterList(record.filters, w);
            }
            if (record.blendMode != -1)
            {
            	w.writeUI8(record.blendMode);
            }
        }
    }

    private void encodeCxforma(CXFormWithAlpha cxforma, SwfEncoder w)
    {
        w.writeBit(cxforma.hasAdd);
        w.writeBit(cxforma.hasMult);

        int nbits = cxforma.nbits();
        w.writeUBits(nbits, 4);

        if (cxforma.hasMult)
        {
            w.writeSBits(cxforma.redMultTerm, nbits);
            w.writeSBits(cxforma.greenMultTerm, nbits);
            w.writeSBits(cxforma.blueMultTerm, nbits);
            w.writeSBits(cxforma.alphaMultTerm, nbits);
        }

        if (cxforma.hasAdd)
        {
            w.writeSBits(cxforma.redAddTerm, nbits);
            w.writeSBits(cxforma.greenAddTerm, nbits);
            w.writeSBits(cxforma.blueAddTerm, nbits);
            w.writeSBits(cxforma.alphaAddTerm, nbits);
        }

        w.flushBits();
    }

    private void encodeMatrix(Matrix matrix, SwfEncoder w)
    {
        w.writeBit(matrix.hasScale);
        if (matrix.hasScale)
        {
            int nScaleBits = matrix.nScaleBits();
            w.writeUBits(nScaleBits, 5);
            w.writeSBits(matrix.scaleX, nScaleBits);
            w.writeSBits(matrix.scaleY, nScaleBits);
        }

        w.writeBit(matrix.hasRotate);
        if (matrix.hasRotate)
        {
            int nRotateBits = matrix.nRotateBits();
            w.writeUBits(nRotateBits, 5);
            w.writeSBits(matrix.rotateSkew0, nRotateBits);
            w.writeSBits(matrix.rotateSkew1,  nRotateBits);
        }

        int nTranslateBits = matrix.nTranslateBits();
        w.writeUBits(nTranslateBits, 5);
        w.writeSBits(matrix.translateX, nTranslateBits);
        w.writeSBits(matrix.translateY, nTranslateBits);

        w.flushBits();
    }

    public void defineButton2(DefineButton tag)
    {
        if (isDebug())
        {
            debug.adjust = writer.getPos()+6;
        }

        int id = dict.add(tag);
        tagw.writeUI16(id);
        tagw.writeUBits(0, 7); // reserved
        tagw.writeBit(tag.trackAsMenu);
        int offsetPos = tagw.getPos();
        tagw.writeUI16(0); // actionOffset

        for (int i = 0; i < tag.buttonRecords.length; i++)
        {
            encodeButtonRecord(tag.buttonRecords[i], tagw, tag.code);
        }

        tagw.writeUI8(0); // charEndFlag

        if (tag.condActions.length > 0)
        {
            tagw.writeUI16at(offsetPos, tagw.getPos()-offsetPos);

            for (int i = 0; i < tag.condActions.length; i++)
            {
                boolean isLast = i+1 == tag.condActions.length;
                encodeButtonCondAction(tag.condActions[i], tagw, isLast);
            }
        }
        encodeTag(tag);

        if (isDebug())
        {
            debug.adjust = 0;
        }
    }

    private void encodeButtonCondAction(ButtonCondAction condAction, SwfEncoder w, boolean last)
    {
        int pos = w.getPos();
        w.writeUI16(0);

        w.writeUBits(condAction.keyPress, 7);
        w.writeBit(condAction.overDownToIdle);

        w.writeBit(condAction.idleToOverDown);
        w.writeBit(condAction.outDownToIdle);
        w.writeBit(condAction.outDownToOverDown);
        w.writeBit(condAction.overDownToOutDown);
        w.writeBit(condAction.overDownToOverUp);
        w.writeBit(condAction.overUpToOverDown);
        w.writeBit(condAction.overUpToIdle);
        w.writeBit(condAction.idleToOverUp);

        new ActionEncoder(w,debug).encode(condAction.actionList);
        w.writeUI8(0); // end action byte

        if (!last)
        {
            w.writeUI16at(pos, w.getPos()-pos);
        }
    }

    public void defineButtonCxform(DefineButtonCxform tag)
    {
        int idref = dict.getId(tag.button);
        tagw.writeUI16(idref);
        encodeCxform(tag.colorTransform, tagw);
        encodeTag(tag);
    }

    private void encodeCxform(CXForm cxform, SwfEncoder w)
    {

        w.writeBit(cxform.hasAdd);
        w.writeBit(cxform.hasMult);

        int nbits = cxform.nbits();
        w.writeUBits(nbits, 4);

        if (cxform.hasMult)
        {
            w.writeSBits(cxform.redMultTerm, nbits);
            w.writeSBits(cxform.greenMultTerm, nbits);
            w.writeSBits(cxform.blueMultTerm, nbits);
        }

        if (cxform.hasAdd)
        {
            w.writeSBits(cxform.redAddTerm, nbits);
            w.writeSBits(cxform.greenAddTerm, nbits);
            w.writeSBits(cxform.blueAddTerm, nbits);
        }

        w.flushBits();
    }

    public void defineButtonSound(DefineButtonSound tag)
    {
        int idref = dict.getId(tag.button);
        tagw.writeUI16(idref);
        if (tag.sound0 != null)
        {
            tagw.writeUI16(dict.getId(tag.sound0));
            encodeSoundInfo(tag.info0, tagw);
        }
        else
        {
            tagw.writeUI16(0);
        }
        if (tag.sound1 != null)
        {
            tagw.writeUI16(dict.getId(tag.sound1));
            encodeSoundInfo(tag.info1, tagw);
        }
        else
        {
            tagw.writeUI16(0);
        }
        if (tag.sound2 != null)
        {
            tagw.writeUI16(dict.getId(tag.sound2));
            encodeSoundInfo(tag.info2, tagw);
        }
        else
        {
            tagw.writeUI16(0);
        }
        if (tag.sound3 != null)
        {
            tagw.writeUI16(dict.getId(tag.sound3));
            encodeSoundInfo(tag.info3, tagw);
        }
        else
        {
            tagw.writeUI16(0);
        }
        encodeTag(tag);
    }

    private void encodeSoundInfo(SoundInfo info, SwfEncoder w)
    {
        w.writeUBits(0, 2); // reserved
        w.writeBit(info.syncStop);
        w.writeBit(info.syncNoMultiple);
		w.writeBit(info.records != null);
        w.writeBit(info.loopCount != SoundInfo.UNINITIALIZED);
        w.writeBit(info.outPoint != SoundInfo.UNINITIALIZED);
        w.writeBit(info.inPoint != SoundInfo.UNINITIALIZED);

        if (info.inPoint != SoundInfo.UNINITIALIZED)
        {
            w.write32((int)info.inPoint);
        }
        if (info.outPoint != SoundInfo.UNINITIALIZED)
        {
            w.write32((int)info.outPoint);
        }
        if (info.loopCount != SoundInfo.UNINITIALIZED)
        {
            w.writeUI16(info.loopCount);
        }
        if (info.records != null)
        {
            w.writeUI8(info.records.length);
            for (int k = 0; k < info.records.length; k++)
            {
                w.write64(info.records[k]);
            }
        }
    }

    public void defineEditText(DefineEditText tag)
    {
        int id = dict.add(tag);
        tagw.writeUI16(id);
        encodeRect(tag.bounds, tagw);

        tagw.writeBit(tag.hasText);
        tagw.writeBit(tag.wordWrap);
        tagw.writeBit(tag.multiline);
        tagw.writeBit(tag.password);
        tagw.writeBit(tag.readOnly);
        tagw.writeBit(tag.hasTextColor);
        tagw.writeBit(tag.hasMaxLength);
        tagw.writeBit(tag.hasFont);

        tagw.writeBit(tag.hasFontClass && !tag.hasFont); // FP 9.0.45 or later
        tagw.writeBit(tag.autoSize);
        tagw.writeBit(tag.hasLayout);
        tagw.writeBit(tag.noSelect);
        tagw.writeBit(tag.border);
        tagw.writeBit(tag.wasStatic);
        tagw.writeBit(tag.html);
        tagw.writeBit(tag.useOutlines);

        tagw.flushBits();

        if (tag.hasFont)
        {
            int idref = dict.getId(tag.font);
            tagw.writeUI16(idref);
            tagw.writeUI16(tag.height);
        }
        else if (tag.hasFontClass)
        {
            tagw.writeString(tag.fontClass);
            tagw.writeUI16(tag.height);
        }

        if (tag.hasTextColor)
        {
            encodeRGBA(tag.color, tagw);
        }

        if (tag.hasMaxLength)
        {
            tagw.writeUI16(tag.maxLength);
        }

        if (tag.hasLayout)
        {
            tagw.writeUI8(tag.align);
            tagw.writeUI16(tag.leftMargin);
            tagw.writeUI16(tag.rightMargin);
            tagw.writeUI16(tag.ident);
            tagw.writeSI16(tag.leading); // see errata, leading is signed
        }

        tagw.writeString(tag.varName);
        if (tag.hasText)
        {
            tagw.writeString(tag.initialText);
        }
        encodeTag(tag);
    }

    public void defineFont(DefineFont1 tag)
    {
        int id = dict.add(tag);
        tagw.writeUI16(id);

        int count = tag.glyphShapeTable.length;

        int offsetPos = tagw.getPos();

        // write offset placeholders
        for (int i = 0; i < count; i++)
        {
            tagw.writeUI16(0);
        }

        // now write glyphs and update the encoded offset table
        for (int i = 0; i < count; i++)
        {
            tagw.writeUI16at(offsetPos+2*i, tagw.getPos()-offsetPos);
            encodeShape(tag.glyphShapeTable[i], tagw, stagDefineShape3, 1, 0);
        }

        encodeTag(tag);
    }

    public void encodeShape(Shape s, SwfEncoder w, int shape, int nFillStyles, int nLineStyles)
    {
        int[] numFillBits = new int[] { SwfEncoder.minBits(nFillStyles,0) };
        int[] numLineBits = new int[] { SwfEncoder.minBits(nLineStyles,0) };

        w.writeUBits(numFillBits[0], 4);
        w.writeUBits(numLineBits[0], 4);

        if (s != null && s.shapeRecords != null)
        {
            Iterator<ShapeRecord> it = s.shapeRecords.iterator();
            while (it.hasNext())
            {
                ShapeRecord record = it.next();
                if (record instanceof StyleChangeRecord)
    			{
                    // style change
                    w.writeBit(false);
                    StyleChangeRecord change = (StyleChangeRecord) record;
                    encodeStyleChangeRecord(w, change, numFillBits, numLineBits, shape);
    			}
    			else
    			{
                    // edge
                    w.writeBit(true);
    				EdgeRecord e = (EdgeRecord) record;
                    boolean straight = e instanceof StraightEdgeRecord;
                    w.writeBit(straight);
                    int nbits = straight ? calcBits((StraightEdgeRecord)e) : calcBits((CurvedEdgeRecord)e);
                    if (nbits < 2)
                        nbits = 2;
    				w.writeUBits(nbits-2, 4);
                    if (straight)
                    {
                        // line
                        StraightEdgeRecord line = (StraightEdgeRecord) e;
                        encodeStraightEdgeRecord(line, w, nbits);
                    }
                    else
                    {
                        // curve
                        CurvedEdgeRecord curve = (CurvedEdgeRecord) e;
                        w.writeSBits(curve.controlDeltaX, nbits);
                        w.writeSBits(curve.controlDeltaY, nbits);
                        w.writeSBits(curve.anchorDeltaX, nbits);
                        w.writeSBits(curve.anchorDeltaY, nbits);
                    }
    			}
    		}
        }

        // endshaperecord
        w.writeUBits(0, 6);

        w.flushBits();
    }

    private int calcBits(StraightEdgeRecord edge)
    {
        return SwfEncoder.minBits(SwfEncoder.maxNum(edge.deltaX,edge.deltaY,0,0),1);
    }

    private int calcBits(CurvedEdgeRecord edge)
    {
        return SwfEncoder.minBits(SwfEncoder.maxNum(edge.controlDeltaX,
                                  edge.controlDeltaY,
                                  edge.anchorDeltaX,
                                  edge.anchorDeltaY), 1);
    }

    private void encodeStraightEdgeRecord(StraightEdgeRecord line, SwfEncoder w, int nbits)
    {
		if (line.deltaX == 0)
        {
            w.writeUBits(01, 2); // vertical line
            w.writeSBits(line.deltaY, nbits);
        }
        else if (line.deltaY == 0)
        {
            w.writeUBits(00, 2); // horizontal line
            w.writeSBits(line.deltaX, nbits);
        }
        else
		{
            w.writeBit(true); // general line
            w.writeSBits(line.deltaX, nbits);
            w.writeSBits(line.deltaY, nbits);
		}
    }

    private void encodeStyleChangeRecord(SwfEncoder w, StyleChangeRecord s,
                                         int[] numFillBits, int[] numLineBits, int shape)
    {
        w.writeBit(s.stateNewStyles);
        w.writeBit(s.stateLineStyle);
        w.writeBit(s.stateFillStyle1);
        w.writeBit(s.stateFillStyle0);
        w.writeBit(s.stateMoveTo);

        if (s.stateMoveTo)
		{
            int moveBits = s.nMoveBits();
			w.writeUBits(moveBits, 5);
			w.writeSBits(s.moveDeltaX, moveBits);
			w.writeSBits(s.moveDeltaY, moveBits);
		}

        if (s.stateFillStyle0)
        {
            w.writeUBits(s.fillstyle0, numFillBits[0]);
        }

        if (s.stateFillStyle1)
        {
            w.writeUBits(s.fillstyle1, numFillBits[0]);
        }

        if (s.stateLineStyle)
        {
            w.writeUBits(s.linestyle, numLineBits[0]);
        }

        if (s.stateNewStyles)
        {
            w.flushBits();

            encodeFillstyles(s.fillstyles, w, shape);
            encodeLinestyles(s.linestyles, w, shape);

            numFillBits[0] = SwfEncoder.minBits(s.fillstyles.size(), 0);
            numLineBits[0] = SwfEncoder.minBits(s.linestyles.size(), 0);
            w.writeUBits(numFillBits[0], 4);
            w.writeUBits(numLineBits[0], 4);
        }
    }

    private void encodeLinestyles(ArrayList<LineStyle> linestyles, SwfEncoder w, int shape)
    {
        int count = 0;

        if (linestyles != null)
            count = linestyles.size();

        if (count > 0xFF)
        {
            w.writeUI8(0xFF);
            w.writeUI16(count);
        }
        else
        {
            w.writeUI8(count);
        }

        for (int i = 0; i < count; i++)
        {
            encodeLineStyle((LineStyle)linestyles.get(i), w, shape);
        }
    }

    private void encodeLineStyle(LineStyle lineStyle, SwfEncoder w, int shape)
    {
        w.writeUI16(lineStyle.width);

        if (shape == stagDefineShape4)
        {
            w.writeUI16( lineStyle.flags );
            if (lineStyle.hasMiterJoint())
                w.writeUI16( lineStyle.miterLimit );
        }

        if (shape == stagDefineShape4 && lineStyle.hasFillStyle())
        {
            encodeFillStyle( lineStyle.fillStyle, w, shape );
        }
        else if ((shape == stagDefineShape3) || (shape == stagDefineShape4))
        {
            encodeRGBA(lineStyle.color, w);
        }
        else
        {
            encodeRGB(lineStyle.color, w);
        }
    }

    private void encodeFillstyles(ArrayList<FillStyle> fillstyles, SwfEncoder w, int shape)
    {
        int count = 0;
        if (fillstyles != null)
             count = fillstyles.size();

        if (count >= 0xFF)
        {
            w.writeUI8(0xFF);
            w.writeUI16(count);
        }
        else
        {
            w.writeUI8(count);
        }

        if (count > 0)
        {
            Iterator<FillStyle> it = fillstyles.iterator();
            while (it.hasNext())
            {
                FillStyle style = (FillStyle) it.next();
                encodeFillStyle(style, w, shape);
            }
        }
    }

    private void encodeFillStyle(FillStyle style, SwfEncoder w, int shape)
    {
        w.writeUI8(style.type);
        switch (style.type)
        {
        case FillStyle.FILL_SOLID: // 0x00
            if ((shape == stagDefineShape3) || (shape == stagDefineShape4)) encodeRGBA(style.color, w);
            else encodeRGB(style.color, w);
            break;
        case FillStyle.FILL_GRADIENT: // 0x10 linear gradient fill
        case FillStyle.FILL_RADIAL_GRADIENT: // 0x12 radial gradient fill
        case FillStyle.FILL_FOCAL_RADIAL_GRADIENT: // 0x13 focal radial gradient fill
            encodeMatrix(style.matrix, w);
            encodeGradient(style.gradient, w, shape);
            break;
        case FillStyle.FILL_BITS: // 0x40 tiled bitmap fill
        case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP): // 0x41 clipped bitmap fill
        case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_NOSMOOTH): // 0x42 tiled non-smoothed fill
        case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP | FillStyle.FILL_BITS_NOSMOOTH): // 0x43 clipped non-smoothed fill
            int id = dict.add(style.bitmap);
            w.writeUI16(id);        
            encodeMatrix(style.matrix, w);
            break;
        }
    }

    private void encodeGradient( Gradient gradient, SwfEncoder w, int shape)
    {
        w.writeUBits( gradient.spreadMode, 2 );
        w.writeUBits( gradient.interpolationMode, 2 );
        w.writeUBits( gradient.records.length, 4 );
        for (int i = 0; i < gradient.records.length; i++)
        {
            encodeGradRecord(gradient.records[i], w, shape);
        }
        if (gradient instanceof FocalGradient)
        {
            w.writeFixed8( ((FocalGradient)gradient).focalPoint );
        }
    }

    private void encodeGradRecord(GradRecord record, SwfEncoder w, int shape)
    {
        w.writeUI8(record.ratio);
        if ((shape == stagDefineShape3) || (shape == stagDefineShape4))
            encodeRGBA(record.color, w);
        else
            encodeRGB(record.color, w);
    }

    public void defineFont2(DefineFont2 tag)
    {
        int id = dict.add(tag);
        tagw.writeUI16(id);
        int startPos = tagw.getPos();
        boolean again;

        if (tag.code == stagDefineFont3)
        {
            tag.wideCodes = true;
        }

        if (! tag.wideCodes)
        {
            for (int i=0; i < tag.codeTable.length; i++)
            {
                if (tag.codeTable[i] > 255)
                {
                    tag.wideCodes = true;
                    break;
                }
            }
        }

        loop:
        do
        {
            again = false;
            tagw.writeBit(tag.hasLayout);
            tagw.writeBit(tag.shiftJIS);
            tagw.writeBit(tag.smallText);
            tagw.writeBit(tag.ansi);
            tagw.writeBit(tag.wideOffsets);
            tagw.writeBit(tag.wideCodes);
            tagw.writeBit(tag.italic);
            tagw.writeBit(tag.bold);
            tagw.flushBits();

            tagw.writeUI8(tag.langCode);

            tagw.writeLengthString(tag.fontName);
            int count = tag.glyphShapeTable.length;

            tagw.writeUI16(count);
            int offsetPos = tagw.getPos();

            // save space for the offset table
            if (tag.wideOffsets)
            {
                for (int i=0; i < count; i++)
                {
                    tagw.write32(0);
                }
            }
            else
            {
                for (int i=0; i < count; i++)
                {
                    tagw.writeUI16(0);
                }
            }

            //PJF: write placeholder for codeTableOffset, this will be changed after shapes encoded
            if (count > 0)
            {
	            if (tag.wideOffsets)
	            {
	                tagw.write32(0);
	            }
	            else
	            {
	                tagw.writeUI16(0);
	            }
            }

            for (int i = 0; i < count; i++)
            {
                // save offset to this glyph
                int offset = tagw.getPos()-offsetPos;
                if (!tag.wideOffsets && offset > 65535)
                {
                    again = true;
                    tag.wideOffsets = true;
                    tagw.setPos(startPos);
                    continue loop;
                }
                if (tag.wideOffsets)
                    tagw.write32at(offsetPos+4*i, offset);
                else
                    tagw.writeUI16at(offsetPos+2*i, offset);

                encodeShape(tag.glyphShapeTable[i], tagw, stagDefineShape3, 1, 0);
            }

            // update codeTableOffset
            int offset = tagw.getPos()-offsetPos;
            if (!tag.wideOffsets && offset > 65535)
            {
                again = true;
                tag.wideOffsets = true;
                tagw.setPos(startPos);
                continue loop;
            }
            if (tag.wideOffsets)
            {
                tagw.write32at(offsetPos+4*count, offset);
            }
            else
            {
                tagw.writeUI16at(offsetPos+2*count, offset);
            }

            // now write the codetable

            if (tag.wideCodes)
            {
                for (int i = 0; i < tag.codeTable.length; i++)
                {
                    tagw.writeUI16(tag.codeTable[i]);
                }
            }
            else
            {
                for (int i = 0; i < tag.codeTable.length; i++)
                {
                    tagw.writeUI8(tag.codeTable[i]);
                }
            }

            if (tag.hasLayout)
            {
                tagw.writeSI16(tag.ascent);
                tagw.writeSI16(tag.descent);
                tagw.writeSI16(tag.leading);

                for (int i = 0; i < tag.advanceTable.length; i++)
                {
                    tagw.writeSI16(tag.advanceTable[i]);
                }

                for (int i = 0; i < tag.boundsTable.length; i++)
                {
                    encodeRect(tag.boundsTable[i], tagw);
                }

                tagw.writeUI16(tag.kerningTable.length);

                for (int i = 0; i < tag.kerningTable.length; i++)
                {
                    if (!tag.wideCodes && ((tag.kerningTable[i].code1 > 255) ||
                                       (tag.kerningTable[i].code2 > 255)))
                    {
                        again = true;
                        tag.wideCodes = true;
                        tagw.setPos(startPos);
                        continue loop;
                    }

                    encodeKerningRecord(tag.kerningTable[i], tagw, tag.wideCodes);
                }
            }
        }
        while (again);
        
        encodeTag(tag);
    }

    public void defineFont3(DefineFont3 tag)
    {
        defineFont2(tag);
    }

    public void defineFont4(DefineFont4 tag)
    {
        int id = dict.add(tag);
        tagw.writeUI16(id);

        tagw.writeUBits(0, 5); // reserved
        tagw.writeBit(tag.hasFontData);
        //tagw.writeBit(tag.smallText);
        tagw.writeBit(tag.italic);
        tagw.writeBit(tag.bold);
        tagw.flushBits();

        //tagw.writeUI8(tag.langCode);
        tagw.writeString(tag.fontName);
        if (tag.hasFontData)
        {
            tagw.write(tag.data);
        }

        encodeTag(tag);
    }

    public void defineFontAlignZones(DefineFontAlignZones tag)
    {
        int fontID = dict.getId(tag.font);
        tagw.writeUI16(fontID);
        tagw.writeUBits(tag.csmTableHint, 2);
        tagw.writeUBits(0, 6); // reserved
        for (int i = 0; i < tag.zoneTable.length; i++)
        {
            ZoneRecord record = tag.zoneTable[i];
            tagw.writeUI8(record.numZoneData);
            for (int j = 0; j < record.numZoneData; j++)
            {
                tagw.write32((int)record.zoneData[j]);
            }
            tagw.writeUI8(record.zoneMask);
        }
        encodeTag(tag);
    }

    public void csmTextSettings(CSMTextSettings tag)
    {
        int textID = 0;
        if (tag.textReference != null)
        {
            textID = dict.getId(tag.textReference);
        }
        tagw.writeUI16(textID);
        tagw.writeUBits(tag.styleFlagsUseSaffron, 2);
        tagw.writeUBits(tag.gridFitType, 3);
        tagw.writeUBits(0, 3); // reserved
        // FIXME: thickness/sharpness should be written out as 32 bit IEEE Single Precision format in little Endian
        tagw.writeUBits((int)tag.thickness, 32);
        tagw.writeUBits((int)tag.sharpness, 32);
        tagw.writeUBits(0, 8); //reserved

        encodeTag(tag);
    }

	public void defineFontName(DefineFontName tag)
	{
		int fontID = dict.getId(tag.font);
		tagw.writeUI16(fontID);
        if (tag.fontName != null)
        {
            tagw.writeString(tag.fontName);
        }
        else
        {
            tagw.writeString("");
        }
        if (tag.copyright != null)
        {
            tagw.writeString(tag.copyright);
        }
        else
        {
            tagw.writeString("");
        }            

		encodeTag(tag);
	}

    private void encodeKerningRecord(KerningRecord kerningRecord, SwfEncoder w, boolean wideCodes)
    {
        if (wideCodes)
		{
			w.writeUI16(kerningRecord.code1);
			w.writeUI16(kerningRecord.code2);
		}
		else
		{
			w.writeUI8(kerningRecord.code1);
            w.writeUI8(kerningRecord.code2);
		}
        w.writeUI16(kerningRecord.adjustment);
    }

    public void defineFontInfo(DefineFontInfo tag)
    {
        int idref = dict.getId(tag.font);
        tagw.writeUI16(idref);

        tagw.writeLengthString(tag.name);

        tagw.writeUBits(0, 3); // reserved
        tagw.writeBit(tag.shiftJIS);
        tagw.writeBit(tag.ansi);
        tagw.writeBit(tag.italic);
        tagw.writeBit(tag.bold);

        if (tag.code == stagDefineFontInfo2)
        {
            tagw.writeBit(tag.wideCodes = true);
            tagw.writeUI8(tag.langCode);
        }
        else
        {
            if (! tag.wideCodes)
            {
                for (int i=0; i < tag.codeTable.length; i++)
                {
                    if (tag.codeTable[i] > 255)
                    {
                        tag.wideCodes = true;
                        break;
                    }
                }
            }
            tagw.writeBit(tag.wideCodes);
        }

        if (tag.wideCodes)
        {
            for (int i = 0; i < tag.codeTable.length; i++)
                tagw.writeUI16(tag.codeTable[i]);
        }
        else
        {
            for (int i = 0; i < tag.codeTable.length; i++)
                tagw.writeUI8(tag.codeTable[i]);
        }
        encodeTag(tag);
    }

    public void defineFontInfo2(DefineFontInfo tag)
    {
        defineFontInfo(tag);
    }

    public void defineMorphShape(DefineMorphShape tag)
    {
    	defineMorphShape2(tag);
    }

    public void defineMorphShape2(DefineMorphShape tag)
    {
        int id = dict.add(tag);
        tagw.writeUI16(id);
        encodeRect(tag.startBounds, tagw);
        encodeRect(tag.endBounds, tagw);
        if (tag.code == stagDefineMorphShape2)
        {
        	encodeRect(tag.startEdgeBounds, tagw);
        	encodeRect(tag.endEdgeBounds, tagw);
        	tagw.writeUBits(tag.reserved, 6);
        	tagw.writeUBits(tag.usesNonScalingStrokes ? 1 : 0, 1);
        	tagw.writeUBits(tag.usesScalingStrokes ? 1 : 0, 1);
        }
        tagw.write32(0);
        int pos = tagw.getPos();
        encodeMorphFillstyles(tag.fillStyles, tagw, tag.code);
        encodeMorphLinestyles(tag.lineStyles, tagw, tag.code);
        encodeShape(tag.startEdges, tagw, stagDefineShape3, tag.fillStyles.length, tag.lineStyles.length);
        tagw.write32at(pos-4, tagw.getPos() - pos);
        // end shape contains only edges, no style information
        encodeShape(tag.endEdges, tagw, stagDefineShape3, 0, 0);
        encodeTag(tag);
    }

    private void encodeMorphFillstyles(MorphFillStyle[] fillStyles, SwfEncoder w, int code)
    {
        int count = fillStyles.length;
        if (count >= 0xFF)
		{
			w.writeUI8(0xFF);
			w.writeUI16(count);
		}
		else
		{
			w.writeUI8(count);
		}

        for (int i = 0; i < count; i++)
        {
            encodeMorphFillstyle(fillStyles[i], w, code);
        }
    }

    private void encodeMorphFillstyle(MorphFillStyle style, SwfEncoder w, int code)
    {				
        w.writeUI8(style.type);
        switch (style.type)
        {
        case FillStyle.FILL_SOLID: // 0x00
            encodeRGBA(style.startColor, w);
            encodeRGBA(style.endColor, w);
            break;
        case FillStyle.FILL_GRADIENT: // 0x10 linear gradient fill
        case FillStyle.FILL_RADIAL_GRADIENT: // 0x12 radial gradient fill
        case FillStyle.FILL_FOCAL_RADIAL_GRADIENT: // 0x13 focal radial gradient fill
            encodeMatrix(style.startGradientMatrix, w);
            encodeMatrix(style.endGradientMatrix, w);
            encodeMorphGradient(style.gradRecords, w);
            if (style.type == FillStyle.FILL_FOCAL_RADIAL_GRADIENT && code == stagDefineMorphShape2)
            {
            	w.writeSI16(style.ratio1);
            	w.writeSI16(style.ratio2);
            }
            break;
        case FillStyle.FILL_BITS: // 0x40 tiled bitmap fill
        case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP): // 0x41 clipped bitmap fill
        case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_NOSMOOTH): // 0x42 tiled non-smoothed fill
        case (FillStyle.FILL_BITS | FillStyle.FILL_BITS_CLIP | FillStyle.FILL_BITS_NOSMOOTH): // 0x43 clipped non-smoothed fill
            int id = dict.add(style.bitmap);
            w.writeUI16(id);        
            encodeMatrix(style.startBitmapMatrix, w);
            encodeMatrix(style.endBitmapMatrix, w);
            break;
        default:
            assert (false);
            //throw new IOException("unrecognized fill style type: " + style.type);
        }
    }

    private void encodeMorphGradient(MorphGradRecord[] gradRecords, SwfEncoder w)
    {
        w.writeUI8(gradRecords.length);
        for (int i = 0; i < gradRecords.length; i++)
        {
            MorphGradRecord record = gradRecords[i];
            w.writeUI8(record.startRatio);
            encodeRGBA(record.startColor, w);
            w.writeUI8(record.endRatio);
            encodeRGBA(record.endColor, w);
        }
    }

    private void encodeMorphLinestyles(MorphLineStyle[] lineStyles, SwfEncoder w, int code)
    {
        if (lineStyles.length >= 0xFF)
		{
			w.writeUI8(0xFF);
			w.writeUI16(lineStyles.length);
		}
		else
		{
			w.writeUI8(lineStyles.length);
		}

        for (int i = 0; i < lineStyles.length; i++)
        {
            MorphLineStyle style = lineStyles[i];
            w.writeUI16(style.startWidth);
            w.writeUI16(style.endWidth);
            if (code == stagDefineMorphShape2)
            {
            	w.writeUBits(style.startCapsStyle, 2);
            	w.writeUBits(style.jointStyle, 2);
            	w.writeBit(style.hasFill);
            	w.writeBit(style.noHScale);
            	w.writeBit(style.noVScale);
            	w.writeBit(style.pixelHinting);
            	w.writeUBits(0, 5); // reserved
            	w.writeBit(style.noClose);
            	w.writeUBits(style.endCapsStyle, 2);
            	if (style.jointStyle == 2)
            	{
            		w.writeUI16(style.miterLimit);
            	}
            }
            if (!style.hasFill)
            {
            	encodeRGBA(style.startColor,w);
            	encodeRGBA(style.endColor,w);
            }
            if (style.hasFill)
            {
            	encodeMorphFillstyle(style.fillType, w, code);
            }
        }
    }

    public void defineShape(DefineShape tag)
    {
        int id = dict.add(tag);
        tagw.writeUI16(id);
        encodeRect(tag.bounds, tagw);
        if (tag.code == stagDefineShape4)
        {
            encodeRect(tag.edgeBounds, tagw);
            tagw.writeUBits(0, 5);
            tagw.writeBit(tag.usesFillWindingRule);
            tagw.writeBit(tag.usesNonScalingStrokes);
            tagw.writeBit(tag.usesScalingStrokes);
        }
        encodeShapeWithStyle(tag.shapeWithStyle, tagw, tag.code);
        encodeTag(tag);
    }

    private void encodeShapeWithStyle(ShapeWithStyle sws, SwfEncoder w, int shape)
    {
        encodeFillstyles(sws.fillstyles, w, shape);
        encodeLinestyles(sws.linestyles, w, shape);

        int fillStyleCount = sws.fillstyles == null ? 0 : sws.fillstyles.size();
        int lineStyleCount = sws.linestyles == null ? 0 : sws.linestyles.size(); 
        encodeShape(sws, w, shape, fillStyleCount, lineStyleCount);
    }

    public void defineShape2(DefineShape tag)
    {
        defineShape(tag);
    }

    public void defineShape3(DefineShape tag)
    {
        defineShape(tag);
    }

    public void defineShape4(DefineShape tag)
    {
        defineShape(tag);
    }

    public void defineSound(DefineSound tag)
    {
        int id = dict.add(tag);
        tagw.writeUI16(id);
        tagw.writeUBits(tag.format, 4);
        tagw.writeUBits(tag.rate, 2);
        tagw.writeUBits(tag.size, 1);
        tagw.writeUBits(tag.type, 1);
        tagw.write32((int)tag.sampleCount);
        tagw.write(tag.data);
        encodeTag(tag);
    }

    public void defineSprite(DefineSprite tag)
    {
        int id = dict.add(tag);
        tagw.writeUI16(id);
        tagw.writeUI16(tag.framecount);

        if (isDebug())
        {
            debug.adjust = writer.getPos()+6;
        }

        // save frame count
        int oldFrames = frames;
        frames = 0;

        // save the movie writer, and push a new writer
        SwfEncoder oldWriter = writer;
        writer = tagw;
        tagw = createEncoder(getSwfVersion());

        // write sprite tags
        List tags = tag.tagList.tags;
        int size = tags.size();
        for (int i = 0; i < size; i++)
        {
            Tag t = (Tag) tags.get(i);
            if (!(t instanceof DefineTag))
                t.visit(this);
        }

        // terminate with end marker
        writer.writeUI16(0);

        // update frame count
        writer.writeUI16at(2, frames);

        // restore writers
        tagw = writer;
        writer = oldWriter;
        frames = oldFrames;

        if (isDebug())
        {
            debug.adjust = 0;
        }

        encodeTag(tag);
    }

    public void defineText(DefineText tag)
    {
        encodeDefineText(tag, tagw, tag.code);
        encodeTag(tag);
    }

    private void encodeDefineText(DefineText tag, SwfEncoder w, int type)
    {
        int id = dict.add(tag);
        w.writeUI16(id);
        encodeRect(tag.bounds, w);
        encodeMatrix(tag.matrix, w);
        int length = tag.records.size();

        // compute necessary bit width
        int glyphBits = 0;
        int advanceBits = 0;
        for (int i=0; i < length; i++)
        {
            TextRecord tr = tag.records.get(i);

            for (int j = 0; j < tr.entries.length; j++)
            {
                GlyphEntry entry = tr.entries[j];

                while (entry.getIndex() > (1<<glyphBits))
                    glyphBits++;
                while (Math.abs(entry.advance) > (1<<advanceBits))
                    advanceBits++;
            }
        }

        // increment to get from bit index to bit count.
        ++glyphBits;
        ++advanceBits;

        w.writeUI8(glyphBits);
        w.writeUI8(++advanceBits); // add one extra bit because advances are signed

        for (int i = 0; i < length; i++)
        {
            TextRecord record = tag.records.get(i);
            encodeTextRecord(record, w, type, glyphBits, advanceBits);
        }

        w.writeUI8(0);
    }

    private void encodeFilterList(List<Filter> filters, SwfEncoder w)
    {
        int count = filters.size();
        w.writeUI8( count );
        for (Iterator<Filter> it = filters.iterator(); it.hasNext();)
        {
            Filter f = (Filter) it.next();
            w.writeUI8(f.getID());
            // I've never quite understood why the serialization code isn't in the tags themselves..
            switch(f.getID())
            {
                case DropShadowFilter.ID: encodeDropShadowFilter( w, (DropShadowFilter) f ); break;
                case BlurFilter.ID: encodeBlurFilter( w, (BlurFilter) f ); break;
                case ConvolutionFilter.ID: encodeConvolutionFilter( w, (ConvolutionFilter) f ); break;
                case GlowFilter.ID: encodeGlowFilter( w, (GlowFilter) f ); break;
                case BevelFilter.ID: encodeBevelFilter( w, (BevelFilter) f ); break;
                case ColorMatrixFilter.ID: encodeColorMatrixFilter( w, (ColorMatrixFilter) f ); break;
                case GradientGlowFilter.ID: encodeGradientGlowFilter( w, (GradientGlowFilter) f ); break;
                case GradientBevelFilter.ID: encodeGradientBevelFilter( w, (GradientBevelFilter) f ); break;

            }

        }
    }

    private void encodeDropShadowFilter( SwfEncoder w, DropShadowFilter f )
    {
        encodeRGBA( f.color, w );
        w.write32( f.blurX );
        w.write32( f.blurY );
        w.write32( f.angle );
        w.write32( f.distance );
        w.writeUI16( f.strength );
        w.writeUI8( f.flags );
    }

    private void encodeBlurFilter( SwfEncoder w, BlurFilter f )
    {
        w.write32( f.blurX );
        w.write32( f.blurY );
        w.writeUI8( f.passes );
    }
    private void encodeColorMatrixFilter( SwfEncoder w, ColorMatrixFilter f )
    {
        for (int i = 0; i < 20; ++i)
        {
            w.writeFloat( f.values[i]);
        }
    }
    private void encodeConvolutionFilter( SwfEncoder w, ConvolutionFilter f )
    {
        w.writeUI8( f.matrixX );
        w.writeUI8( f.matrixY );
        w.writeFloat( f.divisor );
        w.writeFloat( f.bias );
        for (int i = 0; i < f.matrix.length; ++i)
            w.writeFloat( f.matrix[i] );
        w.writeUI8( f.flags );
    }
    private void encodeGlowFilter( SwfEncoder w, GlowFilter f )
    {
        encodeRGBA( f.color, w );
        w.write32( f.blurX );
        w.write32( f.blurY );
        w.writeUI16( f.strength );
        w.writeUI8( f.flags );
    }
    private void encodeBevelFilter( SwfEncoder w, BevelFilter f )
    {
        encodeRGBA(f.highlightColor, w);
        encodeRGBA(f.shadowColor, w);
        w.write32( f.blurX );
        w.write32( f.blurY );
        w.write32( f.angle );
        w.write32( f.distance );
        w.writeUI16( f.strength );
        w.writeUI8( f.flags );
    }

    private void encodeGradientGlowFilter( SwfEncoder w, GradientGlowFilter f )
    {
        w.writeUI8( f.numcolors );
        for (int i = 0; i < f.numcolors; ++i)
            encodeRGBA( f.gradientColors[i], w );
        for (int i = 0; i < f.numcolors; ++i)
            w.writeUI8( f.gradientRatio[i] );
        //w.write32( f.color );
        w.write32( f.blurX );
        w.write32( f.blurY );
        w.write32( f.angle );
        w.write32( f.distance );
        w.writeUI16( f.strength );
        w.writeUI8( f.flags );

    }
    private void encodeGradientBevelFilter( SwfEncoder w, GradientBevelFilter f )
    {
        w.writeUI8( f.numcolors );
        for (int i = 0; i < f.numcolors; ++i)
            encodeRGBA( f.gradientColors[i], w );
        for (int i = 0; i < f.numcolors; ++i)
            w.writeUI8( f.gradientRatio[i] );
        
//        w.write32( f.shadowColor );
//        w.write32( f.highlightColor );
        w.write32( f.blurX );
        w.write32( f.blurY );
        w.write32( f.angle );
        w.write32( f.distance );
        w.writeUI16( f.strength );
        w.writeUI8( f.flags );

    }

    private void encodeTextRecord(TextRecord record, SwfEncoder w, int type, int glyphBits, int advanceBits)
    {
        w.writeUI8(record.flags);

        if (record.hasFont())
        {
            w.writeUI16(dict.getId(record.font));
        }

        if (record.hasColor())
        {
            if (type == stagDefineText2)
                encodeRGBA(record.color, w);
            else
                encodeRGB(record.color, w);
        }

        if (record.hasX())
        {
            w.writeSI16(record.xOffset);
        }

        if (record.hasY())
        {
            w.writeSI16(record.yOffset);
        }

        if (record.hasHeight())
        {
            w.writeUI16(record.height);
        }

        w.writeUI8(record.entries.length);

        for (int i = 0; i < record.entries.length; i++)
        {
            w.writeUBits(record.entries[i].getIndex(), glyphBits);
            w.writeSBits(record.entries[i].advance, advanceBits);
        }
        w.flushBits();
    }

    public void defineText2(DefineText tag)
    {
        defineText(tag);
    }

    public void defineVideoStream(DefineVideoStream tag)
    {
        int id = dict.add(tag);
        tagw.writeUI16(id);
        tagw.writeUI16(tag.numFrames);
        tagw.writeUI16(tag.width);
        tagw.writeUI16(tag.height);

        tagw.writeUBits(0, 4); // reserved
        tagw.writeUBits(tag.deblocking, 3);
        tagw.writeBit(tag.smoothing);

        tagw.writeUI8(tag.codecID);
        encodeTag(tag);
    }

    public void doAction(DoAction tag)
    {
        int adjust = 0;
        if (isDebug())
        {
            adjust = writer.getPos()+6;
            debug.adjust += adjust;
        }

        new ActionEncoder(tagw,debug).encode(tag.actionList);
        tagw.writeUI8(0);
        encodeTag(tag);

        if (isDebug())
        {
            debug.adjust -= adjust;
        }
    }

    public void doInitAction(DoInitAction tag)
    {
        int adjust = 0;
        if (isDebug())
        {
            adjust = writer.getPos()+6;
            debug.adjust += adjust;
        }

        int idref = dict.getId(tag.sprite);
        tagw.writeUI16(idref);
        new ActionEncoder(tagw,debug).encode(tag.actionList);
        tagw.writeUI8(0);
        encodeTag(tag);

        if (isDebug())
        {
            debug.adjust -= adjust;
        }
    }

    public void enableDebugger(EnableDebugger tag)
    {
        tagw.writeString(tag.password);
        encodeTag(tag);
    }

    public void enableDebugger2(EnableDebugger tag)
    {
        // This corresponds to the constant used in the player,
        // core/splay.cpp, in ScriptThread::EnableDebugger().
        tagw.writeUI16(0x1975);
        tagw.writeString(tag.password);
        encodeTag(tag);
    }

    public void exportAssets(ExportAssets tag)
    {
        tagw.writeUI16(tag.exports.size());
        Iterator it = tag.exports.iterator();
        while (it.hasNext())
        {
            DefineTag ref = (DefineTag) it.next();
            int idref = dict.getId(ref);
            tagw.writeUI16(idref);
            assert (ref.name != null); // exported symbols must have names
            tagw.writeString(ref.name);
            dict.addName(ref, ref.name);
        }
        encodeTag(tag);
    }

	public void symbolClass(SymbolClass tag)
	{
		tagw.writeUI16(tag.class2tag.size() + (tag.topLevelClass != null ? 1 : 0));
		Iterator it = tag.class2tag.entrySet().iterator();
		while (it.hasNext())
		{
			Map.Entry e = (Map.Entry) it.next();
			String name = (String) e.getKey();
            DefineTag ref = (DefineTag) e.getValue();

			int idref = dict.getId(ref);
			tagw.writeUI16(idref);
			tagw.writeString(name);
		}
		if (tag.topLevelClass != null)
		{
			tagw.writeUI16(0);
			tagw.writeString(tag.topLevelClass);
		}
		encodeTag(tag);
	}

    public void frameLabel(FrameLabel tag)
    {
        tagw.writeString(tag.label);
        if (tag.anchor && getSwfVersion() >= 6)
        {
            tagw.writeUI8(1);
        }
        encodeTag(tag);
    }

    public void importAssets(ImportAssets tag)
    {
        tagw.writeString(tag.url);
        if (tag.code == stagImportAssets2)
        {
        	tagw.writeUI8(tag.downloadNow ? 1 : 0);
        	tagw.writeUI8(tag.SHA1 != null ? 1 : 0);
        	if (tag.SHA1 != null)
        	{
        		tagw.write(tag.SHA1);
        	}
        }
        tagw.writeUI16(tag.importRecords.size());
        Iterator<ImportRecord> it = tag.importRecords.iterator();
        while (it.hasNext())
        {
            ImportRecord record = (ImportRecord) it.next();
            int id = dict.add(record);
            tagw.writeUI16(id);
            tagw.writeString(record.name);
		}
        encodeTag(tag);
    }
    
    public void importAssets2(ImportAssets tag)
    {
    	importAssets(tag);
    }

    public void jpegTables(GenericTag tag)
    {
        encodeTagHeader(tag.code, tag.data.length, false);
        writer.write(tag.data);
    }

    public void placeObject(PlaceObject tag)
    {
        int idref = dict.getId(tag.ref);
        tagw.writeUI16(idref);
        tagw.writeUI16(tag.depth);
        encodeMatrix(tag.matrix,  tagw);
        if (tag.colorTransform != null)
        {
            encodeCxform(tag.colorTransform, tagw);
        }
        encodeTag(tag);
    }

    public void placeObject2(PlaceObject tag)
    {
        placeObject23(tag);
    }

    public void placeObject3(PlaceObject tag)
    {
        placeObject23(tag);
    }

    public void placeObject23(PlaceObject tag)
    {
        tagw.writeUI8(tag.flags);
        if (tag.code == stagPlaceObject3)
        {
            tagw.writeUI8(tag.flags2);
        }
        tagw.writeUI16(tag.depth);
        if (tag.hasClassName()) {
            tagw.writeString(tag.className);
        }
        if (tag.hasCharID())
        {
            int idref = dict.getId(tag.ref);
            tagw.writeUI16(idref);
        }
        if (tag.hasMatrix())
        {
            encodeMatrix(tag.matrix, tagw);
        }
        if (tag.hasCxform())
        {
            // ed 5/22/03 the SWF 6 file format spec says this should be a CXFORM, but
            // the spec is wrong.  the player expects a CXFORMA.
            encodeCxforma(((CXFormWithAlpha) tag.colorTransform), tagw);
        }
        if (tag.hasRatio())
        {
            tagw.writeUI16(tag.ratio);
        }
        if (tag.hasName())
        {
            tagw.writeString(tag.name);
        }
        if (tag.hasClipDepth())
        {
            tagw.writeUI16(tag.clipDepth);
        }
        if (tag.code == stagPlaceObject3)
        {
            if (tag.hasFilterList())
            {
                encodeFilterList( tag.filters, tagw );
            }
            if (tag.hasBlendMode())
            {
                tagw.writeUI8(tag.blendMode);
            }
        }
        if (tag.hasClipAction())
        {
            int adjust=0;
            if (isDebug())
            {
                adjust = writer.getPos()+6;
                debug.adjust += adjust;
            }
            new ActionEncoder(tagw,debug).encodeClipActions(tag.clipActions);
            if (isDebug())
            {
                debug.adjust -= adjust;
            }
        }
        encodeTag(tag);
    }

    public void protect(GenericTag tag)
    {
        if (tag.data != null)
        {
            encodeTagHeader(tag.code, tag.data.length, false);
            writer.write(tag.data);
        }
        else
        {
            encodeTagHeader(tag.code, 0, false);
        }
    }

    public void removeObject(RemoveObject tag)
    {
        encodeTagHeader(tag.code, 4, false);
        int idref = dict.getId(tag.ref);
        writer.writeUI16(idref);
        writer.writeUI16(tag.depth);
    }

    public void removeObject2(RemoveObject tag)
    {
        encodeTagHeader(tag.code, 2, false);
        writer.writeUI16(tag.depth);
    }

    public void setBackgroundColor(SetBackgroundColor tag)
    {
        encodeTagHeader(tag.code, 3, false);
        encodeRGB(tag.color, writer);
    }

    public void showFrame(ShowFrame tag)
    {
        encodeTagHeader(tag.code, 0, false);
        frames++;
    }

    public void soundStreamBlock(GenericTag tag)
    {
        encodeTagHeader(tag.code, tag.data.length, false);
        writer.write(tag.data);
    }

    public void soundStreamHead(SoundStreamHead tag)
    {
        int length = 4;
        
        // we need to add two bytes for an extra SI16 (latencySeek)
        if (tag.compression == SoundStreamHead.sndCompressMP3)
        {
            length += 2;
        }
        
        encodeTagHeader(tag.code, length, false);

        // 1 byte
        writer.writeUBits(0, 4); // reserved
        writer.writeUBits(tag.playbackRate, 2);
        writer.writeUBits(tag.playbackSize, 1);
        writer.writeUBits(tag.playbackType, 1);

        // 1 byte
        writer.writeUBits(tag.compression, 4);
        writer.writeUBits(tag.streamRate, 2);
        writer.writeUBits(tag.streamSize, 1);
        writer.writeUBits(tag.streamType, 1);

        // 2 bytes
        writer.writeUI16(tag.streamSampleCount);

		if (tag.compression == SoundStreamHead.sndCompressMP3)
		{
            // 2 bytes
			writer.writeSI16(tag.latencySeek);
		}
    }

    public void soundStreamHead2(SoundStreamHead tag)
    {
        soundStreamHead(tag);
    }

    public void startSound(StartSound tag)
    {
        int idref = dict.getId(tag.sound);
        tagw.writeUI16(idref);
        encodeSoundInfo(tag.soundInfo, tagw);
        encodeTag(tag);
    }

    public void videoFrame(VideoFrame tag)
    {
        encodeTagHeader(tag.code, 4+tag.videoData.length, false);
        int idref = dict.getId(tag.stream);
        writer.writeUI16(idref);
        writer.writeUI16(tag.frameNum);
        writer.write(tag.videoData);
    }
    
    public void defineSceneAndFrameLabelData(DefineSceneAndFrameLabelData tag)
    {
        encodeTagHeader(tag.code, tag.data.length, false);
        writer.write(tag.data);
    }

    public void doABC(DoABC tag)
	{
        if (tag.code == stagDoABC2)
        {
    		encodeTagHeader(tag.code, 4 + tag.name.length() + 1 + tag.abc.length, false);
            writer.write32( tag.flag );
            writer.writeString( tag.name );

        }
        else
        {
		    encodeTagHeader(tag.code, tag.abc.length, false);
        }

		writer.write(tag.abc);
	}

    public void unknown(GenericTag tag)
    {
        encodeTagHeader(tag.code, tag.data.length, false);
        writer.write(tag.data);
    }

    public byte[] toByteArray() throws IOException
    {
        //TODO this could be improved, tricky bit is that writeTo is not trivial
        //     and has the side effect of compressing (meaning the writer.size()
        //     may be larger than necessary)
        ByteArrayOutputStream out = new ByteArrayOutputStream(writer.size());
        writeTo(out);
        return out.toByteArray();
    }

    public void scriptLimits(ScriptLimits tag)
    {
        tagw.writeUI16(tag.scriptRecursionLimit);
        tagw.writeUI16(tag.scriptTimeLimit);
        encodeTag(tag);
    }

    public void setTabIndex(SetTabIndex tag)
    {
        tagw.writeUI16(tag.depth);
        tagw.writeUI16(tag.index);
        encodeTag(tag);
    }
}
