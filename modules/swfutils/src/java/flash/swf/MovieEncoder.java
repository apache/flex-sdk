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
import flash.swf.types.ActionList;
import flash.swf.types.ImportRecord;

import java.util.HashSet;
import java.util.Iterator;

/**
 * Encode movies by traversing them and calling the taghandler with
 * each tag of interest.  This class encapsulates knowlege about how
 * the flash player executes.  In particular, the order of execution
 * of initActions and frame actions.
 *
 * @author Edwin Smith
 */
public class MovieEncoder
{
	private final TagHandler handler;
	private HashSet<Tag> done;
	private boolean compress;

	public MovieEncoder(TagHandler handler)
	{
		this.handler = handler;
		done = new HashSet<Tag>();
	}

	/**
	 * Export SWF model to bytes.
	 * @param m SWF object
	 */
	public void export(Movie m)
	{
	    export(m, Header.useCompression(m.version));
	}

	/**
     * Export SWF model to bytes.
     * @param m SWF object
     * @param compress use compression if true
     */
	public void export(Movie m, boolean compress)
	{
		// define the header
		Header h = new Header();
		h.version = m.version;
		h.compressed = compress;
		h.size = m.size;
		h.rate = m.framerate;

		handler.header(h);

		// movie-wide tags
		if (m.fileAttributes != null)
		{
            if (m.metadata != null)
                m.fileAttributes.hasMetadata = true;

            m.fileAttributes.visit(handler); // FileAttributes MUST be first tag after header!
		}
        if (m.metadata != null)
        {
            m.metadata.visit(handler);
        }
        if (m.enableDebugger != null)
		{
			m.enableDebugger.visit(handler);
		}
		if (m.uuid != null)
		{
			new DebugID(m.uuid).visit(handler);
		}
		if (m.protect != null)
		{
			m.protect.visit(handler);
		}
		if (m.scriptLimits != null)
		{
			m.scriptLimits.visit(handler);
		}
		if (m.bgcolor != null)
		{
			m.bgcolor.visit(handler);
		}
		if (m.productInfo != null)
		{
			m.productInfo.visit(handler);
		}
        if (m.sceneAndFrameLabelData != null)
        {
            m.sceneAndFrameLabelData.visit(handler);
        }

        // finally, output the frames
        boolean associateRootClass = (m.topLevelClass != null);
		for (Iterator i = m.frames.iterator(); i.hasNext();)
		{
			Frame frame = (Frame) i.next();

			if (frame.label != null)
			{
				frame.label.visit(handler);
			}

			if (!frame.imports.isEmpty())
			{
				for (Iterator j = frame.imports.iterator(); j.hasNext();)
				{
					ImportAssets importAssets = (ImportAssets) j.next();
					importAssets.visit(handler);
				}
			}

			// definitions needed in this frame
			for (Iterator j = frame.getReferences(); j.hasNext();)
			{
				DefineTag ref = (DefineTag) j.next();
				define(ref);
			}

			// exports
			if (frame.hasExports())
			{
				ExportAssets exportAssets = new ExportAssets();
				for (Iterator j = frame.exportIterator(); j.hasNext();)
				{
					DefineTag tag = (DefineTag) j.next();
					exportAssets.exports.add(tag);
				}
				exportAssets.visit(handler);
			}

			// TODO: Review this... temporarily special casing fonts here as they should not be
			// included in ExportAssets as they are not required to be exported by name!

			// fonts
			if (frame.hasFonts())
			{
				for (Iterator k = frame.fontsIterator(); k.hasNext();)
				{
					DefineFont tag = (DefineFont) k.next();

                    // We may have already visited this font because of symbolClasses.
                    if (!done.contains( tag ))
                    {
					    tag.visit(handler);
                        done.add( tag );
                    }
				}
			}

			// abc tags
			for (Iterator j = frame.doABCs.iterator(); j.hasNext();)
			{
				Tag tag = (Tag) j.next();
				tag.visit(handler);
			}

            SymbolClass classes = new SymbolClass();

			if (frame.hasSymbolClasses())
			{
                classes.class2tag.putAll( frame.symbolClass.class2tag );
			}
            if (associateRootClass)
            {
                // only works on frame 1
    			classes.topLevelClass = m.topLevelClass;    // Why do we do this on every frame's symclass?
            }
            if (associateRootClass || frame.hasSymbolClasses())
            {
    			classes.visit(handler);
            }
            associateRootClass = false;

			// control tags
			for (Iterator j = frame.controlTags.iterator(); j.hasNext();)
			{
				Tag tag = (Tag) j.next();
				tag.visit(handler);
			}

			// then frame actions
			for (Iterator<ActionList> j = frame.doActions.iterator(); j.hasNext();)
			{
				ActionList list = j.next();
				new DoAction(list).visit(handler);
			}

			// oh yeah, then showFrame!
			new ShowFrame().visit(handler);
		}

		handler.finish();
	}

	// changed from private to public to support Flash Authoring - jkamerer 2007.07.30
	public void define(Tag tag)
	{
		if (!done.contains(tag))
		{
			for (Iterator i = tag.getReferences(); i.hasNext();)
			{
				Tag ref = (Tag) i.next();
				define(ref);
			}
			// ImportRecords are pre-visited via their parent ImportAssets tag.
			if (!(tag instanceof ImportRecord))
			{
				tag.visit(handler);

                // FIXME: we really need a general handler for references that should be handled after the
                // parent tag is visited.  Or maybe all references can be changed so that they are handled
                // after the main tag is visited?

                Tag visitAfter = null;
                if (tag instanceof DefineSprite)
                {
                    visitAfter = ((DefineSprite) tag).scalingGrid;
                }
                else if (tag instanceof DefineButton)
                {
                    visitAfter = ((DefineButton) tag).scalingGrid;
                }
                else if (tag instanceof DefineShape)
                {
                    visitAfter = ((DefineShape) tag).scalingGrid;
                }
                else if (tag instanceof DefineFont3)
                {
                    visitAfter = ((DefineFont3) tag).zones;
                }
                else if (tag instanceof DefineEditText)
                {
                    visitAfter = ((DefineEditText) tag).csmTextSettings;
                }
                else if (tag instanceof DefineText)
                {
                    visitAfter = ((DefineText) tag).csmTextSettings;
                }

				visitAfter(visitAfter);

				visitAfter = null;
				if (tag instanceof DefineFont)
				{
					visitAfter = ((DefineFont)tag).license;
				}

				visitAfter(visitAfter);
			}
			done.add(tag);
		}
	}

	private void visitAfter(Tag visitAfter)
	{
		if (visitAfter != null)
		{
		    assert !done.contains(visitAfter);
		    visitAfter.visit(handler);
		    done.add(visitAfter);
		}
	}
}
