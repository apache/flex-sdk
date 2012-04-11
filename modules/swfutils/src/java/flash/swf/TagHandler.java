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

/**
 * Defines the API for SWF tag handlers.
 *
 * @author Clement Wong
 */
public class TagHandler
{
	public void setOffsetAndSize(int offset, int size)
	{
	}

    public void productInfo(ProductInfo tag)
    {
    }

	public void header(Header h)
	{
	}

    public void fileAttributes(FileAttributes tag)
    {
    }

    public void metadata(Metadata tag)
    {
    }

    public void showFrame(ShowFrame tag)
	{
	}

	public void defineShape(DefineShape tag)
	{
	}

	public void placeObject(PlaceObject tag)
	{
	}

	public void removeObject(RemoveObject tag)
	{
	}

    public void defineBinaryData(DefineBinaryData tag)
    {
    }

	public void defineFontName(DefineFontName tag)
	{
	}

    public void defineBits(DefineBits tag)
	{
	}

	public void defineButton(DefineButton tag)
	{
	}

	public void jpegTables(GenericTag tag)
	{
	}

	public void setBackgroundColor(SetBackgroundColor tag)
	{
	}

	public void defineFont(DefineFont1 tag)
	{
	}

    public void defineFontAlignZones(DefineFontAlignZones tag)
    {
    }

    public void csmTextSettings(CSMTextSettings tag)
    {
    }

	public void defineText(DefineText tag)
	{
	}

    public void defineSceneAndFrameLabelData(DefineSceneAndFrameLabelData tag)
    {
    }

    public void doAction(DoAction tag)
	{
	}

	public void defineFontInfo(DefineFontInfo tag)
	{
	}

	public void defineSound(DefineSound tag)
	{
	}

	public void startSound(StartSound tag)
	{
	}

	public void defineButtonSound(DefineButtonSound tag)
	{
	}

	public void soundStreamHead(SoundStreamHead tag)
	{
	}

	public void soundStreamBlock(GenericTag tag)
	{
	}

	public void defineBitsLossless(DefineBitsLossless tag)
	{
	}

	public void defineBitsJPEG2(DefineBits tag)
	{
	}

	public void defineShape2(DefineShape tag)
	{
	}

	public void defineButtonCxform(DefineButtonCxform tag)
	{
	}

	public void protect(GenericTag tag)
	{
	}

	public void placeObject2(PlaceObject tag)
	{
	}

    public void placeObject3(PlaceObject tag)
    {
    }

    public void removeObject2(RemoveObject tag)
	{
	}

	public void defineShape3(DefineShape tag)
	{
	}

    public void defineShape4(DefineShape tag)
    {
    }
	public void defineText2(DefineText tag)
	{
	}

	public void defineButton2(DefineButton tag)
	{
	}

	public void defineBitsJPEG3(DefineBitsJPEG3 tag)
	{
	}

	public void defineBitsLossless2(DefineBitsLossless tag)
	{
	}

	public void defineEditText(DefineEditText tag)
	{
	}

	public void defineSprite(DefineSprite tag)
	{
	}

    public void defineScalingGrid(DefineScalingGrid tag)
    {
    }

	public void frameLabel(FrameLabel tag)
	{
	}

	public void soundStreamHead2(SoundStreamHead tag)
	{
	}

	public void defineMorphShape(DefineMorphShape tag)
	{
	}

	public void defineMorphShape2(DefineMorphShape tag)
	{
	}

	public void defineFont2(DefineFont2 tag)
	{
	}

    public void defineFont3(DefineFont3 tag)
    {
    }

    public void defineFont4(DefineFont4 tag)
    {
    }

	public void exportAssets(ExportAssets tag)
	{
	}

	public void symbolClass(SymbolClass tag)
	{
	}

	public void importAssets(ImportAssets tag)
	{
	}

	public void importAssets2(ImportAssets tag)
	{
	}

	public void enableDebugger(EnableDebugger tag)
	{
	}

	public void doInitAction(DoInitAction tag)
	{
	}

	public void defineVideoStream(DefineVideoStream tag)
	{
	}

	public void videoFrame(VideoFrame tag)
	{
	}

	public void defineFontInfo2(DefineFontInfo tag)
	{
	}

	public void enableDebugger2(EnableDebugger tag)
	{
	}

	public void debugID(DebugID tag)
	{
	}

	public void unknown(GenericTag tag)
	{
	}

    public void any( Tag tag )
    {
    }
    /**
     * called when we are done, no more tags coming
     */
    public void finish()
    {
    }

    public void setDecoderDictionary(Dictionary dict)
    {
    }

    public void error(String s)
    {
    }

    public void scriptLimits(ScriptLimits tag)
    {
    }

    public void setTabIndex(SetTabIndex tag)
    {
    }

	public void doABC(DoABC tag)
	{
	}
}
