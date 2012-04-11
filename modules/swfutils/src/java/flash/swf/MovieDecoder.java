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

import java.util.ArrayList;
import java.util.Iterator;

/**
 * Handles parsing events for a SWF movie.  Keep track of each frame
 * and build up a framelist.  There are a number of singleton tags in
 * swf movies, so invoke errors if those singleton events are defined
 * more than once.
 *
 * @author Edwin Smith
 */
public class MovieDecoder extends TagHandler
{
	private Movie m;
	private Frame frame;

    public MovieDecoder(Movie m)
	{
		this.m = m;
	}

	public void header(Header h)
	{
		m.version = h.version;
		m.framerate = h.rate;
		m.size = h.size;
		m.frames = new ArrayList<Frame>(h.framecount);
		frame = new Frame();
	}

	public void finish()
	{
		// C: If there is no ShowFrame at the end, don't throw away the frame.
		if (frame != null && !m.frames.contains(frame))
		{
			m.frames.add(frame);
		}
		// we are done loading the movie.  now set currentFrame == null
		frame = null;
	}

	public void debugID(DebugID tag)
	{
		if (m.uuid != null)
		{
			error("duplicate uuid" + tag.uuid);
		}

		m.uuid = tag.uuid;
	}

	public void doAction(DoAction tag)
	{
		frame.doActions.add(tag.actionList);
	}

	public void doInitAction(DoInitAction tag)
	{
		frame.controlTags.add(tag);
	}

	public void enableDebugger(EnableDebugger tag)
	{
		if (m.enableDebugger != null)
		{
			error("duplicate EnableDebugger " + tag.password);
		}

		m.enableDebugger = tag;
	}

	public void enableDebugger2(EnableDebugger tag)
	{
		enableDebugger(tag);
	}

	public void exportAssets(ExportAssets tag)
	{
		// we only care what tags were exported in this frame, because all the
		// code in this frame could depend on those definitions.
		for (Iterator i = tag.exports.iterator(); i.hasNext();)
		{
			DefineTag def = (DefineTag) i.next();
			frame.addExport(def);
		}
	}

    public void defineSceneAndFrameLabelData(DefineSceneAndFrameLabelData tag)
    {
        m.sceneAndFrameLabelData = tag;
    }

    public void doABC(DoABC tag)
    {
        frame.doABCs.add( tag );
    }

    public void symbolClass(SymbolClass tag)
    {
        frame.mergeSymbolClass( tag );
        
        // populate Movie.topLevelClass if this is the first frame and SymbolClass.topLevelClass is non-null.
        if (m.frames.size() == 0 && tag.topLevelClass != null)
        {
        	m.topLevelClass = tag.topLevelClass;
        }
    }

	public void frameLabel(FrameLabel tag)
	{
		if (frame.label != null)
		{
			error("duplicate label " + tag.label);
		}

		frame.label = tag;
	}

	public void importAssets(ImportAssets tag)
	{
		frame.imports.add(tag);
	}

	public void importAssets2(ImportAssets tag)
	{
		frame.imports.add(tag);
	}

	public void placeObject(PlaceObject tag)
	{
		placeObject2(tag);
	}

	public void placeObject2(PlaceObject tag)
	{
		frame.controlTags.add(tag);
	}
    public void placeObject3(PlaceObject tag)
    {
        frame.controlTags.add(tag);
    }

    public void protect(GenericTag tag)
	{
		if (m.protect != null)
		{
			error("duplicate Protect ");
		}

		m.protect = tag;
	}

	public void removeObject(RemoveObject tag)
	{
		removeObject2(tag);
	}

	public void removeObject2(RemoveObject tag)
	{
		frame.controlTags.add(tag);
	}

	public void scriptLimits(ScriptLimits tag)
	{
		if (m.scriptLimits != null)
		{
			// assume player ignores duplicate scriptlimits
			error("duplicate script limits");
		}

		m.scriptLimits = tag;
	}

	public void setTabIndex(SetTabIndex tag)
	{
		frame.controlTags.add(tag);
	}

	public void setBackgroundColor(SetBackgroundColor tag)
	{
		if (tag != null)
		{
			// assume player ignores duplicate bgcolors
			error("duplicate SetBackgroundColor " + tag.color);
		}

		m.bgcolor = tag;
	}

	public void showFrame(ShowFrame tag)
	{
		m.frames.add(frame);
		frame = new Frame();
	}

	public void soundStreamBlock(GenericTag tag)
	{
		frame.controlTags.add(tag);
	}

	public void soundStreamHead(SoundStreamHead tag)
	{
		frame.controlTags.add(tag);
	}

	public void soundStreamHead2(SoundStreamHead tag)
	{
		frame.controlTags.add(tag);
	}

	public void startSound(StartSound tag)
	{
		frame.controlTags.add(tag);
	}

	public void unknown(GenericTag tag)
	{
		frame.controlTags.add(tag);
	}

	public void videoFrame(VideoFrame tag)
	{
		frame.controlTags.add(tag);
	}

	public void productInfo(ProductInfo tag)
	{
		frame.controlTags.add(tag);
	}

    public void metadata(Metadata tag)
    {
        m.metadata = tag;
    }

    public void fileAttributes(FileAttributes tag)
	{
		if (m.fileAttributes != null)
		{
			error("duplicate FileAttributes");
		}
		m.fileAttributes = tag;
	}

	public void defineButtonCxform(DefineButtonCxform tag)
	{
		frame.controlTags.add(tag);
	}

	public void defineButtonSound(DefineButtonSound tag)
	{
		frame.controlTags.add(tag);
	}

	public void defineFont(DefineFont1 tag)
	{
	    frame.fonts.add(tag);
	}

	public void defineFont2(DefineFont2 tag)
	{
	    frame.fonts.add(tag);
	}

    public void defineFont3(DefineFont3 tag)
    {
        defineFont2(tag);
    }

    public void defineFontAlignZones(DefineFontAlignZones tag)
    {
        frame.controlTags.add(tag);
    }

    public void csmTextSettings(CSMTextSettings tag)
    {
        frame.controlTags.add(tag);
    }

	public void defineFontName(DefineFontName tag)
	{
		frame.controlTags.add(tag);
	}
}
