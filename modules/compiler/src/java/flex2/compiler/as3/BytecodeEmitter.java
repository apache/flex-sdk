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

package flex2.compiler.as3;

import flex2.compiler.Source;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.compiler.util.LineNumberMap;
import macromedia.asc.embedding.avmplus.ActionBlockEmitter;
import macromedia.asc.semantics.MetaData;
import macromedia.asc.semantics.Value;
import macromedia.asc.util.ByteList;
import macromedia.asc.util.Context;
import macromedia.asc.util.IntList;
import macromedia.asc.util.StringPrintWriter;

import java.io.File;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

/**
 * This class overrides DebugSlot(), DebugFile(), and DebugLine() to
 * add support for mapping generated as3 line numbers back to the
 * original MXML, CSS, etc line numbers.
 *
 * @author Clement Wong
 */
public final class BytecodeEmitter extends ActionBlockEmitter
{
	public BytecodeEmitter(Context cx, Source source, boolean debug, boolean codeHints)
	{
		this(cx, source, debug, codeHints, false, null);
	}

	public BytecodeEmitter(Context cx, Source source, boolean debug, boolean codeHints, boolean keepEmbed, LineNumberMap map)
	{
		super(cx, source != null ? source.getName() : null, new StringPrintWriter(),
              new StringPrintWriter(), false, false, false, debug, codeHints);
		this.map = map;
		this.source = source;
		this.cx = cx;
        this.keepEmbed = keepEmbed;

		if (debug)
		{
			lines = new HashSet<Line>();
			key = new Line();
		}
	}

	private LineNumberMap map;
	private Source source;
	private String currentFileName;
	private Context cx;

    // Do we want to strip out Embed metadata or not - if this is true,
    // we will emit the Embed metadata, but if false, then we will not emit
    // any embed metadata
    private boolean keepEmbed;

	// C: not used when debug is false...
	private Set<Line> lines;
	private Line key;

    /**
     * Overrides ActionBlockEmitter's addMetadata() to add support for
     * filtering out Embed metadata, because it can contain system
     * paths.  See SDK-25385.  In the future, we might want to go
     * further to filter out all metadata that is only necessary at
     * compile time for libraries or at runtime for Applications.  We
     * already handle non-debug applications in PostLink.
     */
    protected IntList addMetadata(ArrayList<MetaData> metadata)
    {
        // If we're keeping [Embed] metadata then we can just call the default impl
        // in the base class as we're not doing any special filtering here
        if( keepEmbed )
            return super.addMetadata(metadata);

        IntList metaDataIndices = null;

        if ((metadata != null) && (metadata.size() > 0))
        {
            metaDataIndices = new IntList(metadata.size());

            for (MetaData metaData : metadata)
            {
                String id = metaData.id;

                if (!id.equals(StandardDefs.MD_EMBED))
                {
                    Value[] values = metaData.values;
                    int metaDataIndex = addMetadataInfo(id, values);
                    metaDataIndices.add(metaDataIndex);
                }
            }
        }
        return metaDataIndices;
    }

	protected void DebugSlot(String name, int slot, int line)
	{
		if (source.isDebuggable())
		{
			int newLine = calculateLineNumber(line);

			if (newLine != -1)
			{
				super.DebugSlot(name, slot, newLine);
			}
		}
	}

	protected void DebugFile(String name)
	{
		currentFileName = name;

		if (!source.isDebuggable())
		{
			return;
		}

		if (map != null)
		{
			if (map.getNewName().equals(name))
			{
				name = map.getOldName();
			}
		}

		// C: reconstruct filenames based on the path;package;file format.
		//    apply to SourcePath files only...
		//    root is in FileSpec but we're considered it a special case. it's questionable...
		//	  Note ResourceContainer case added for inline components 
		if (source.isSourcePathOwner() ||
				source.isSourceListOwner() ||
				source.isResourceContainerOwner() ||
				source.isRoot())
		{
			String relativePath = source.getRelativePath().replace('/', File.separatorChar);
			if (relativePath.length() == 0)
			{
				int index = name.lastIndexOf(File.separatorChar);
				if (index != -1)
				{
					name = name.substring(0, index) + ";;" + name.substring(index + 1);
				}
			}
			else
			{
				// C: e.g. relativePath = mx\controls
				int separatorIndex = name.lastIndexOf(File.separatorChar);
				int index = separatorIndex > -1 ? name.lastIndexOf(relativePath, separatorIndex) : name.lastIndexOf(relativePath);
				if (index > 0)
				{
					name = name.substring(0, index - 1) + ";" + relativePath + ";" + name.substring(index + relativePath.length() + 1);
				}
			}
		}

		super.DebugFile(name);
	}

	protected void DebugLine(ByteList code, int lineNumber)
	{
		if (!source.isDebuggable())
		{
			return;
		}

		if (lines != null)
		{
			key.fileName = currentFileName;
			key.lineNumber = lineNumber;

			if (!lines.contains(key))
			{
				lines.add(new Line(currentFileName, lineNumber));
				source.lineCount = lines.size();
			}
		}

		int newLineNumber = calculateLineNumber(lineNumber);

		if (newLineNumber > 0)
		{
			super.DebugLine(code, newLineNumber);
		}
	}

	private int calculateLineNumber(int lineNumber)
	{
		if (map == null || !source.getName().equals(currentFileName))
		{
			return lineNumber;
		}
		else
		{
			int newLineNumber = map.get(lineNumber);
			if (newLineNumber > 0)
			{
				return newLineNumber;
			}
			else
			{
				// C: lines corresponding to internal code are not "debuggable".
				return -1;
			}
		}
	}

	private static class Line
	{
		Line()
		{
		}

		Line(String fileName, int lineNumber)
		{
			this.fileName = fileName;
			this.lineNumber = lineNumber;
		}

		public String fileName;
		public int lineNumber;

		public boolean equals(Object o)
		{
			if (o == this)
			{
				return true;
			}
			else if (o instanceof Line)
			{
				Line line = (Line) o;

                if ((fileName != null) && (line.fileName != null))
                {
                    return fileName.equals(line.fileName) && lineNumber == line.lineNumber;
                }
                else if (((fileName != null) && (line.fileName == null)) ||
                         ((fileName == null) && (line.fileName != null)))
                {
                    return false;
                }
                else
                {
                    return lineNumber == line.lineNumber;
                }
			}
			else
			{
				return false;
			}
		}

		public int hashCode()
		{
            int result;

            if (fileName != null)
            {
                result = fileName.hashCode() ^ lineNumber;
            }
            else
            {
                result = lineNumber;
            }

            return result;
		}
	}
}
