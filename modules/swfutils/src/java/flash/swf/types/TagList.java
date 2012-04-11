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

package flash.swf.types;

import flash.swf.Tag;
import flash.swf.TagHandler;
import flash.swf.tags.*;

import java.util.ArrayList;
import java.util.List;

/**
 * This is a simple container for a list of tags.  It's the physical
 * representation of a timeline too, although strictly speaking, only
 * the control tags are interesting on the timeline (placeobject,
 * removeobject, startsound, showframe, etc).
 *
 * @author Clement Wong
 */
public class TagList extends TagHandler
{
	public TagList()
	{
		this.tags = new ArrayList<Tag>();
	}

	public List<Tag> tags;

    public boolean equals(Object object)
    {
        boolean isEqual = false;

        if (object instanceof TagList)
        {
            TagList tagList = (TagList) object;

            if ( ( (tagList.tags == null) && (this.tags == null) ) ||
                 ( (tagList.tags != null) && (this.tags != null) &&
                   ArrayLists.equals( tagList.tags, this.tags ) ) )
            {
                isEqual = true;
            }
        }

        return isEqual;
    }    

    public String toString()
    {
        StringBuilder stringBuffer = new StringBuilder();

        stringBuffer.append("TagList:\n");

        for (int i = 0; i < tags.size(); i++)
        {
            stringBuffer.append( "\t" + i + " = " +tags.get(i) + "\n");
        }

        return stringBuffer.toString();
    }

	public void visitTags(TagHandler handler)
	{
		int size = tags.size();
		for (int i = 0; i < size; i++)
		{
			Tag t = tags.get(i);
			t.visit(handler);
		}
	}

    public void debugID(DebugID tag)
    {
        tags.add(tag);
    }

    public void setTabIndex(SetTabIndex tag)
    {
        tags.add(tag);
    }

    public void scriptLimits(ScriptLimits tag)
    {
        tags.add(tag);
    }

	public void showFrame(ShowFrame tag)
	{
		tags.add(tag);
	}

	public void defineShape(DefineShape tag)
	{
		tags.add(tag);
	}

	public void placeObject(PlaceObject tag)
	{
		tags.add(tag);
	}

	public void removeObject(RemoveObject tag)
	{
		tags.add(tag);
	}

	public void defineBits(DefineBits tag)
	{
		tags.add(tag);
	}

	public void defineButton(DefineButton tag)
	{
		tags.add(tag);
	}

	public void jpegTables(GenericTag tag)
	{
		tags.add(tag);
	}

	public void setBackgroundColor(SetBackgroundColor tag)
	{
		tags.add(tag);
	}

	public void defineFont(DefineFont tag)
	{
		tags.add(tag);
	}

	public void defineText(DefineText tag)
	{
		tags.add(tag);
	}

	public void doAction(DoAction tag)
	{
		tags.add(tag);
	}

	public void defineFontInfo(DefineFontInfo tag)
	{
		tags.add(tag);
	}

	public void defineSound(DefineSound tag)
	{
		tags.add(tag);
	}

	public void startSound(StartSound tag)
	{
		tags.add(tag);
	}

	public void defineButtonSound(DefineButtonSound tag)
	{
		tags.add(tag);
	}

	public void soundStreamHead(SoundStreamHead tag)
	{
		tags.add(tag);
	}

	public void soundStreamBlock(GenericTag tag)
	{
		tags.add(tag);
	}

	public void defineBitsLossless(DefineBitsLossless tag)
	{
		tags.add(tag);
	}

	public void defineBitsJPEG2(DefineBits tag)
	{
		tags.add(tag);
	}

	public void defineShape2(DefineShape tag)
	{
		tags.add(tag);
	}

	public void defineButtonCxform(DefineButtonCxform tag)
	{
		tags.add(tag);
	}

	public void protect(GenericTag tag)
	{
		tags.add(tag);
	}

	public void placeObject2(PlaceObject tag)
	{
		tags.add(tag);
	}

    public void placeObject3(PlaceObject tag)
    {
        tags.add(tag);
    }

    public void removeObject2(RemoveObject tag)
	{
		tags.add(tag);
	}

	public void defineShape3(DefineShape tag)
	{
		tags.add(tag);
	}

    public void defineShape4(DefineShape tag)
    {
        tags.add(tag);
    }

	public void defineText2(DefineText tag)
	{
		tags.add(tag);
	}

	public void defineButton2(DefineButton tag)
	{
		tags.add(tag);
	}

	public void defineBitsJPEG3(DefineBitsJPEG3 tag)
	{
		tags.add(tag);
	}

	public void defineBitsLossless2(DefineBitsLossless tag)
	{
		tags.add(tag);
	}

	public void defineEditText(DefineEditText tag)
	{
		tags.add(tag);
	}

	public void defineSprite(DefineSprite tag)
	{
		tags.add(tag);
	}

	public void frameLabel(FrameLabel tag)
	{
		tags.add(tag);
	}

	public void soundStreamHead2(SoundStreamHead tag)
	{
		tags.add(tag);
	}

	public void defineMorphShape(DefineMorphShape tag)
	{
		tags.add(tag);
	}

	public void defineMorphShape2(DefineMorphShape tag)
	{
		tags.add(tag);
	}

	public void defineFont2(DefineFont tag)
	{
		tags.add(tag);
	}

    public void defineFont3(DefineFont tag)
    {
        tags.add(tag);
    }

    public void defineFontAlignZones(DefineFontAlignZones tag)
    {
        tags.add(tag);
    }
    
    public void csmTextSettings(CSMTextSettings tag)
    {
        tags.add(tag);
    }

	public void defineFontName(DefineFontName tag)
	{
		tags.add(tag);
	}

	public void exportAssets(ExportAssets tag)
	{
		tags.add(tag);
	}

	public void importAssets(ImportAssets tag)
	{
		tags.add(tag);
	}

	public void importAssets2(ImportAssets tag)
	{
		tags.add(tag);
	}

	public void enableDebugger(EnableDebugger tag)
	{
		tags.add(tag);
	}

	public void doInitAction(DoInitAction tag)
	{
		tags.add(tag);
	}

    public void defineScalingGrid(DefineScalingGrid tag)
    {
        tags.add(tag);
    }

	public void defineVideoStream(DefineVideoStream tag)
	{
		tags.add(tag);
	}

	public void videoFrame(VideoFrame tag)
	{
		tags.add(tag);
	}

	public void defineFontInfo2(DefineFontInfo tag)
	{
		tags.add(tag);
	}

	public void enableDebugger2(EnableDebugger tag)
	{
		tags.add(tag);
	}

	public void unknown(GenericTag tag)
	{
		tags.add(tag);
	}

    public void productInfo(ProductInfo tag)
    {
        tags.add(tag);
    }

    public void fileAttributes(FileAttributes tag)
    {
        tags.add(tag);
    }
}
