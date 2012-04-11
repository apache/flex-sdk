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

import flash.swf.Frame;
import flash.swf.Movie;
import flash.swf.tags.DoABC;
import flex2.compiler.mxml.lang.StandardDefs;
import flex2.linker.LinkerConfiguration;
import flex2.linker.ConsoleApplication;
import flex2.linker.FlexMovie;
import macromedia.abc.BytecodeBuffer;
import macromedia.abc.ConstantPool;
import macromedia.abc.Decoder;
import macromedia.abc.Encoder;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Implementation of flex2.linker.PostLink which merges ABC blocks and
 * runs a peephole optimizer on the byte code.
 *
 * @author Clement Wong
 */
public class PostLink implements flex2.linker.PostLink
{
	public PostLink(boolean debug, boolean optimize)
	{
		this.debug = debug;
		this.optimize = optimize;
		as3metadata = StandardDefs.DefaultAS3Metadata;
	}

	public PostLink(LinkerConfiguration linkerConfiguration)
	{
        this.linkerConfiguration = linkerConfiguration;
		debug = linkerConfiguration.debug() || linkerConfiguration.verboseStacktraces();
		optimize = linkerConfiguration.optimize();
		as3metadata = linkerConfiguration.getMetadataToKeep();
	}

    private boolean debug;
    private boolean optimize;
    private String[] as3metadata;
    LinkerConfiguration linkerConfiguration;
    
	public void run(ConsoleApplication app)
	{
        List<byte[]> abcList = new ArrayList<byte[]>(1);
		abcList.add(null);

		if (optimize)
		{
			merge(app.getABCs(), app.enableDebugger || debug, optimize);
		}
		else
		{
			for (int j = 0, codeSize = app.getABCs().size(); j < codeSize; j++)
			{
				byte[] abc = app.getABCs().get(j);

				abcList.set(0, abc);
				merge(abcList, app.enableDebugger || debug, optimize);
				app.getABCs().set(j, abcList.get(0));
			}
		}
	}
	
	public void run(Movie movie)
	{
        // See if a flex movie has metadata it needs saved. 
        if (movie instanceof FlexMovie)
        {
            Set<String> moreMetadata = ((FlexMovie)movie).getMetadata();
            if (moreMetadata.size() > 0) 
            {
                // merge metadata from the flex movie with any existing
                // metadata from the configuration.
                Set<String> mergedMetaData = null;
                if (as3metadata != null && as3metadata.length > 0)
                {
                    mergedMetaData = new HashSet<String>();
                    mergedMetaData.addAll(moreMetadata);
                    mergedMetaData.addAll(Arrays.asList(as3metadata));                
                }
                else
                {
                    mergedMetaData = moreMetadata;
                }
                as3metadata = mergedMetaData.toArray(new String[mergedMetaData.size()]);                    
            }
        }
		List<DoABC> doABCs = new ArrayList<DoABC>(1);
		doABCs.add(null);

		// abc merge... frame by frame... if merging fails on one of the frames, it will continue.
		for (int i = 0, frameSize = movie.frames.size(); i < frameSize; i++)
		{
			Frame f = movie.frames.get(i);
			if (optimize)
			{
				merge(f.doABCs, movie.enableDebugger != null || debug, optimize, "frame" + (i + 1));
			}
			else
			{
				for (int j = 0, codeSize = f.doABCs.size(); j < codeSize; j++)
				{
					DoABC abc = f.doABCs.get(j);

					doABCs.set(0, abc);
					merge(doABCs, movie.enableDebugger != null || debug, optimize, abc.name);
					f.doABCs.set(j, doABCs.get(0));
				}
			}
		}
	}

	private void merge(List<DoABC> doABCs, boolean debug, boolean runPeephole, String name)
	{
		Encoder encoder;
		Decoder decoder;

		boolean skipFrame = false;
		int majorVersion = 0, minorVersion = 0, abcSize = doABCs.size(), flag = 1;

		if (abcSize == 0)
		{
			return;
		}
		else if (abcSize == 1)
		{
			flag = doABCs.get(0).flag;
		}
		else
		{
			flag = 1;
		}

		Decoder[] decoders = new Decoder[abcSize];
		ConstantPool[] pools = new ConstantPool[abcSize];

		// create decoders...
		for (int j = 0; j < abcSize; j++)
		{
			DoABC tag = doABCs.get(j);
			BytecodeBuffer in = new BytecodeBuffer(tag.abc);

			try
			{
				// ThreadLocalToolkit.logInfo(tag.name);
				decoders[j] = new Decoder(in);
				majorVersion = decoders[j].majorVersion;
				minorVersion = decoders[j].minorVersion;
				pools[j] = decoders[j].constantPool;
			}
			catch (Throwable ex)
			{
				StringWriter stringWriter = new StringWriter();
				ex.printStackTrace(new PrintWriter(stringWriter));
				assert false : stringWriter.toString();
				skipFrame = true;
				break;
			}
		}

		if (skipFrame)
		{
			return;
		}

		encoder = new Encoder(majorVersion, minorVersion);
		// all the constant pools are merged here...
		try
		{
			encoder.addConstantPools(pools);
			if (!debug)
			{
				encoder.disableDebugging();
			}

			// always remove metadata...
			encoder.removeMetadata();

			// keep the following metadata
			for (int m = 0; as3metadata != null && m < as3metadata.length; m++)
			{
				encoder.addMetadataToKeep(as3metadata[m]);
			}
			
			// always enable peephole optimization...
			if (runPeephole)
			{
				encoder.enablePeepHole();
			}

			encoder.configure(decoders);
		}
		catch (Throwable ex)
		{
			StringWriter stringWriter = new StringWriter();
			ex.printStackTrace(new PrintWriter(stringWriter));
			assert false : stringWriter.toString();
			return;
		}


		// decode methodInfo...
		for (int j = 0; j < abcSize; j++)
		{
			decoder = decoders[j];
			encoder.useConstantPool(j);

			Decoder.MethodInfo methodInfo = decoder.methodInfo;

			try
			{
				for (int k = 0, infoSize = methodInfo.size(); k < infoSize; k++)
				{
					methodInfo.decode(k, encoder);
				}
			}
			catch (Throwable ex)
			{
				StringWriter stringWriter = new StringWriter();
				ex.printStackTrace(new PrintWriter(stringWriter));
				assert false : stringWriter.toString();
				skipFrame = true;
				break;
			}
		}

		if (skipFrame)
		{
			return;
		}

		// decode metadataInfo...
		for (int j = 0; j < abcSize; j++)
		{
			decoder = decoders[j];
			encoder.useConstantPool(j);

			Decoder.MetaDataInfo metadataInfo = decoder.metadataInfo;

			try
			{
				for (int k = 0, infoSize = metadataInfo.size(); k < infoSize; k++)
				{
					metadataInfo.decode(k, encoder);
				}
			}
			catch (Throwable ex)
			{
				StringWriter stringWriter = new StringWriter();
				ex.printStackTrace(new PrintWriter(stringWriter));
				assert false : stringWriter.toString();
				skipFrame = true;
				break;
			}
		}

		if (skipFrame)
		{
			return;
		}

		// decode classInfo...

		for (int j = 0; j < abcSize; j++)
		{
			decoder = decoders[j];
			encoder.useConstantPool(j);

			Decoder.ClassInfo classInfo = decoder.classInfo;

			try
			{
				for (int k = 0, infoSize = classInfo.size(); k < infoSize; k++)
				{
					classInfo.decodeInstance(k, encoder);
				}
			}
			catch (Throwable ex)
			{
				StringWriter stringWriter = new StringWriter();
				ex.printStackTrace(new PrintWriter(stringWriter));
				assert false : stringWriter.toString();
				skipFrame = true;
				break;
			}
		}

		if (skipFrame)
		{
			return;
		}

		for (int j = 0; j < abcSize; j++)
		{
			decoder = decoders[j];
			encoder.useConstantPool(j);

			Decoder.ClassInfo classInfo = decoder.classInfo;

			try
			{
				for (int k = 0, infoSize = classInfo.size(); k < infoSize; k++)
				{
					classInfo.decodeClass(k, 0, encoder);
				}
			}
			catch (Throwable ex)
			{
				StringWriter stringWriter = new StringWriter();
				ex.printStackTrace(new PrintWriter(stringWriter));
				assert false : stringWriter.toString();
				skipFrame = true;
				break;
			}
		}

		if (skipFrame)
		{
			return;
		}

		// decode scripts...
		for (int j = 0; j < abcSize; j++)
		{
			decoder = decoders[j];
			encoder.useConstantPool(j);

			Decoder.ScriptInfo scriptInfo = decoder.scriptInfo;

			try
			{
				for (int k = 0, scriptSize = scriptInfo.size(); k < scriptSize; k++)
				{
					scriptInfo.decode(k, encoder);
				}
			}
			catch (Throwable ex)
			{
				StringWriter stringWriter = new StringWriter();
				ex.printStackTrace(new PrintWriter(stringWriter));
				assert false : stringWriter.toString();
				skipFrame = true;
				break;
			}
		}

		if (skipFrame)
		{
			return;
		}

		// decode method bodies...
		for (int j = 0; j < abcSize; j++)
		{
			decoder = decoders[j];
			encoder.useConstantPool(j);

			Decoder.MethodBodies methodBodies = decoder.methodBodies;

			try
			{
				for (int k = 0, bodySize = methodBodies.size(); k < bodySize; k++)
				{
					methodBodies.decode(k, 2, encoder);
				}
			}
			catch (Throwable ex)
			{
				StringWriter stringWriter = new StringWriter();
				ex.printStackTrace(new PrintWriter(stringWriter));
				assert false : stringWriter.toString();
				skipFrame = true;
				break;
			}
		}

		if (skipFrame)
		{
			return;
		}

		// 0: eager
		// 1: lazy
		DoABC doABC = new DoABC(name, flag);
		doABC.abc = encoder.toABC();

		if (doABC.abc != null)
		{
			doABCs.clear();
			doABCs.add(doABC);
		}
	}

	// C: This is for console applications. don't refactor this method and the other merge()
	//    before we ship.
	private void merge(List<byte[]> abcList, boolean debug, boolean runPeephole)
	{
		Encoder encoder;
		Decoder decoder;

		boolean skipFrame = false;
		int majorVersion = 0, minorVersion = 0, abcSize = abcList.size();

		if (abcSize == 0)
		{
			return;
		}

		Decoder[] decoders = new Decoder[abcSize];
		ConstantPool[] pools = new ConstantPool[abcSize];

		// create decoders...
		for (int j = 0; j < abcSize; j++)
		{
			byte[] abc = abcList.get(j);
			BytecodeBuffer in = new BytecodeBuffer(abc);

			try
			{
				decoders[j] = new Decoder(in);
				majorVersion = decoders[j].majorVersion;
				minorVersion = decoders[j].minorVersion;
				pools[j] = decoders[j].constantPool;
			}
			catch (Throwable ex)
			{
				StringWriter stringWriter = new StringWriter();
				ex.printStackTrace(new PrintWriter(stringWriter));
				assert false : stringWriter.toString();
				skipFrame = true;
				break;
			}
		}

		if (skipFrame)
		{
			return;
		}

		encoder = new Encoder(majorVersion, minorVersion);
		// all the constant pools are merged here...
		try
		{
			encoder.addConstantPools(pools);
			if (!debug)
			{
				encoder.disableDebugging();
			}

			// always remove metadata...
			encoder.removeMetadata();

			// keep the following metadata
			/*
			encoder.addMetadataToKeep(StandardDefs.MD_BINDABLE);
			encoder.addMetadataToKeep(StandardDefs.MD_MANAGED);
			encoder.addMetadataToKeep(StandardDefs.MD_CHANGEEVENT);
			encoder.addMetadataToKeep(StandardDefs.MD_NONCOMMITTINGCHANGEEVENT);
			encoder.addMetadataToKeep(StandardDefs.MD_TRANSIENT);
			*/

			// always enable peephole optimization...
			if (runPeephole)
			{
				encoder.enablePeepHole();
			}

			encoder.configure(decoders);
		}
		catch (Throwable ex)
		{
			StringWriter stringWriter = new StringWriter();
			ex.printStackTrace(new PrintWriter(stringWriter));
			assert false : stringWriter.toString();
			return;
		}


		// decode methodInfo...
		for (int j = 0; j < abcSize; j++)
		{
			decoder = decoders[j];
			encoder.useConstantPool(j);

			Decoder.MethodInfo methodInfo = decoder.methodInfo;

			try
			{
				for (int k = 0, infoSize = methodInfo.size(); k < infoSize; k++)
				{
					methodInfo.decode(k, encoder);
				}
			}
			catch (Throwable ex)
			{
				StringWriter stringWriter = new StringWriter();
				ex.printStackTrace(new PrintWriter(stringWriter));
				assert false : stringWriter.toString();
				skipFrame = true;
				break;
			}
		}

		if (skipFrame)
		{
			return;
		}

		// decode metadataInfo...
		for (int j = 0; j < abcSize; j++)
		{
			decoder = decoders[j];
			encoder.useConstantPool(j);

			Decoder.MetaDataInfo metadataInfo = decoder.metadataInfo;

			try
			{
				for (int k = 0, infoSize = metadataInfo.size(); k < infoSize; k++)
				{
					metadataInfo.decode(k, encoder);
				}
			}
			catch (Throwable ex)
			{
				StringWriter stringWriter = new StringWriter();
				ex.printStackTrace(new PrintWriter(stringWriter));
				assert false : stringWriter.toString();
				skipFrame = true;
				break;
			}
		}

		if (skipFrame)
		{
			return;
		}

		// decode classInfo...

		for (int j = 0; j < abcSize; j++)
		{
			decoder = decoders[j];
			encoder.useConstantPool(j);

			Decoder.ClassInfo classInfo = decoder.classInfo;

			try
			{
				for (int k = 0, infoSize = classInfo.size(); k < infoSize; k++)
				{
					classInfo.decodeInstance(k, encoder);
				}
			}
			catch (Throwable ex)
			{
				StringWriter stringWriter = new StringWriter();
				ex.printStackTrace(new PrintWriter(stringWriter));
				assert false : stringWriter.toString();
				skipFrame = true;
				break;
			}
		}

		if (skipFrame)
		{
			return;
		}

		for (int j = 0; j < abcSize; j++)
		{
			decoder = decoders[j];
			encoder.useConstantPool(j);

			Decoder.ClassInfo classInfo = decoder.classInfo;

			try
			{
				for (int k = 0, infoSize = classInfo.size(); k < infoSize; k++)
				{
					classInfo.decodeClass(k, 0, encoder);
				}
			}
			catch (Throwable ex)
			{
				StringWriter stringWriter = new StringWriter();
				ex.printStackTrace(new PrintWriter(stringWriter));
				assert false : stringWriter.toString();
				skipFrame = true;
				break;
			}
		}

		if (skipFrame)
		{
			return;
		}

		// decode scripts...
		for (int j = 0; j < abcSize; j++)
		{
			decoder = decoders[j];
			encoder.useConstantPool(j);

			Decoder.ScriptInfo scriptInfo = decoder.scriptInfo;

			try
			{
				for (int k = 0, scriptSize = scriptInfo.size(); k < scriptSize; k++)
				{
					scriptInfo.decode(k, encoder);
				}
			}
			catch (Throwable ex)
			{
				StringWriter stringWriter = new StringWriter();
				ex.printStackTrace(new PrintWriter(stringWriter));
				assert false : stringWriter.toString();
				skipFrame = true;
				break;
			}
		}

		if (skipFrame)
		{
			return;
		}

		// decode method bodies...
		for (int j = 0; j < abcSize; j++)
		{
			decoder = decoders[j];
			encoder.useConstantPool(j);

			Decoder.MethodBodies methodBodies = decoder.methodBodies;

			try
			{
				for (int k = 0, bodySize = methodBodies.size(); k < bodySize; k++)
				{
					methodBodies.decode(k, 2, encoder);
				}
			}
			catch (Throwable ex)
			{
				StringWriter stringWriter = new StringWriter();
				ex.printStackTrace(new PrintWriter(stringWriter));
				assert false : stringWriter.toString();
				skipFrame = true;
				break;
			}
		}

		if (skipFrame)
		{
			return;
		}

		byte[] abc = encoder.toABC();

		if (abc != null)
		{
			abcList.clear();
			abcList.add(abc);
		}
	}
}
