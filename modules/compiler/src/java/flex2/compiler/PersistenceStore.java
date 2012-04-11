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

package flex2.compiler;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import macromedia.asc.util.IntegerPool;
import flash.fonts.FontManager;
import flash.localization.LocalizationManager;
import flash.swf.CompressionLevel;
import flash.swf.Frame;
import flash.swf.Movie;
import flash.swf.MovieDecoder;
import flash.swf.MovieEncoder;
import flash.swf.Tag;
import flash.swf.TagDecoder;
import flash.swf.TagEncoder;
import flash.swf.tags.DefineFont;
import flash.swf.tags.DefineTag;
import flash.swf.types.Rect;
import flex2.compiler.common.Configuration;
import flex2.compiler.common.PathResolver;
import flex2.compiler.io.DeletedFile;
import flex2.compiler.io.FileUtil;
import flex2.compiler.io.ResourceFile;
import flex2.compiler.io.VirtualFile;
import flex2.compiler.util.CompilerMessage;
import flex2.compiler.util.LocalLogger;
import flex2.compiler.util.MultiName;
import flex2.compiler.util.QName;
import flex2.compiler.util.ThreadLocalToolkit;
import flex2.compiler.util.LocalLogger.Warning;

/**
 * This class handles the reading and writing of the incremental
 * compilation cache.  The cache contains all the Source and
 * CompilationUnit objects from an incremental compilation, except
 * those from SWC's.  A SWC already contains all the information we
 * need, so we don't duplicate it in the cache.  The cache is stored
 * as a single monolithic file.  Assets for each CompilationUnit are
 * encoded as a SWF and included in the cache file.
 *
 * @author Clement Wong
 */
final class PersistenceStore
{
	// C: If you update the encoding/decoding algorithm, please increment the minor version by 1. Thanks.
	private static final int major_version = 4;
	private static final int minor_version = 7;

	PersistenceStore(Configuration configuration, RandomAccessFile file)
	{
        this(configuration, file, null);
	}

    PersistenceStore(Configuration configuration, RandomAccessFile file, FontManager fontManager)
    {
        assert file != null;

        this.file = file;
        key = new ArrayKey();

        this.fontManager = fontManager;
        this.configuration  = configuration;
    }

    private final Configuration configuration;
	private final RandomAccessFile file;
	private final ArrayKey key;
    private final FontManager fontManager;

    /**
     * An input stream that reads from another input stream, but sets a
     * limit on how much data it will read.
     * 
     * <p>Calls to close() do not close the parent InputStream.
     */
    private static class SizeLimitingInputStream extends InputStream {
		private InputStream in;
		private int max;

    	public SizeLimitingInputStream(InputStream in, int max) {
    		this.in = in;
    		this.max = max;
    	}

		@Override
		public int read() throws IOException {
			if (max == 0)
				return -1;
			--max;
			return in.read();
		}

    	@Override
		public int read(byte[] b, int off, int len) throws IOException {
    		len = Math.min(len, max);
    		max -= len;
    		return in.read(b, off, len);
		}

		@Override
		public int read(byte[] b) throws IOException {
			return read(b, 0, b.length);
		}

		@Override
		public int available() throws IOException {
			return Math.min(max, in.available());
		}

		@Override
		public void close() throws IOException {
			// ignore
		}

		@Override
		public synchronized void mark(int readLimit) {
			in.mark(readLimit);
		}

		@Override
		public boolean markSupported() {
			return false;
		}

		@Override
		public synchronized void reset() throws IOException {
			in.reset();
		}

		@Override
		public long skip(long n) throws IOException {
			n = Math.min(n, max);
			max -= n;
			return in.skip(n);
		}

		/**
		 * Skips forward to the end of the size limit that had been
		 * specified when this SizeLimitingInputStream was created.
		 */
		public void skipToEnd() throws IOException {
			skip(max);
		}
    }

    /**
     * An InputStream that reads from a RandomAccessFile.  Calls to close()
     * do not close the parent RandomAccessFile.
     */
    private static class RandomAccessFileInputStream extends InputStream {
		private RandomAccessFile raf;

    	public RandomAccessFileInputStream(RandomAccessFile raf) {
    		this.raf = raf;
    	}

		@Override
		public int read() throws IOException {
			return raf.read();
		}

    	@Override
		public int read(byte[] b, int off, int len) throws IOException {
    		return raf.read(b, off, len);
		}

		@Override
		public int read(byte[] b) throws IOException {
			return raf.read(b);
		}
    }

    /**
     * An OutputStream that writes to a RandomAccessFile.  Calls to close()
     * do not close the parent RandomAccessFile.
     */
    private static class RandomAccessFileOutputStream extends OutputStream {
		private RandomAccessFile raf;

		public RandomAccessFileOutputStream(RandomAccessFile raf) {
    		this.raf = raf;
    	}

		@Override
		public void write(int b) throws IOException {
			raf.write(b);
		}

		@Override
		public void write(byte[] b, int off, int len) throws IOException {
			raf.write(b, off, len);
		}

    	@Override
		public void write(byte[] b) throws IOException {
    		raf.write(b);
		}
    }
   
	int write(FileSpec fileSpec,
			  SourceList sourceList,
			  SourcePath sourcePath,
			  ResourceContainer resources,
	          ResourceBundlePath bundlePath,
	          List sources,
	          List units,
	          int checksum,
	          int cmd_checksum,
	          int linker_checksum,
	          int swc_checksum,
	          Map<QName, Long> swcDefSignatureChecksums,
	          Map<String, Long> swcFileChecksums,
	          Map<String, Long> archiveFileChecksums,
	          String description) throws IOException
	{
	    Map<Object, Integer> pool = new HashMap<Object, Integer>();

		BufferedOutputStream out = new BufferedOutputStream(new RandomAccessFileOutputStream(file));

		writeHeader(checksum, cmd_checksum, linker_checksum, swc_checksum, description, out);

		out.flush();
		long offsetOfPointerToConstantPool = file.getFilePointer();
		file.writeLong(0); // a dummy value for the pointer to the constant pool; will be replaced later

		writeFileSpec(fileSpec, pool, out);

		writeSourceList(sourceList, pool, out);

		writeSourcePath(sourcePath, pool, out);

		// C: There is no need to have writeResourceContainer() because it has nothing we need to persist.
		// writeResourceContainer(resources, pool);

		writeResourceBundlePath(bundlePath, pool, out);

		int count = (sources == null) ? 0 : sources.size();
		writeU32(out, count);
		if (sources != null)
		{
			writeSourceNames(sources, pool, out);
		}

		int defCount = swcDefSignatureChecksums == null ? 0 : swcDefSignatureChecksums.size();
		writeU32(out, defCount);
		if (swcDefSignatureChecksums != null)
		{
			writeSwcDefSignatureChecksums(swcDefSignatureChecksums, pool, out);
		}

		int fileCount = swcFileChecksums == null ? 0 : swcFileChecksums.size();
		writeU32(out, fileCount);
		if (swcFileChecksums != null)
		{
			writeFileChecksums(swcFileChecksums, pool, out);
		}

		int archiveFileCount = archiveFileChecksums == null ? 0 : archiveFileChecksums.size();
		writeU32(out, archiveFileCount);
		if (archiveFileChecksums != null)
		{
			writeFileChecksums(archiveFileChecksums, pool, out);
		}

		Collection<Source>  c1 = fileSpec   == null ? Collections.<Source>emptyList()        : fileSpec.sources();
		Collection<Source>  c2 = sourceList == null ? Collections.<Source>emptyList()        : sourceList.sources().values();
		Map<String, Source> c3 = sourcePath == null ? Collections.<String, Source>emptyMap() : sourcePath.sources();
		Collection<Source>  c4 = resources  == null ? Collections.<Source>emptyList()        : resources.sources().values();
		Map<String, Source> c5 = bundlePath == null ? Collections.<String, Source>emptyMap() : bundlePath.sources();

		int totalCount = c1.size() + c2.size() + c3.size() + c4.size() + c5.size();

		writeU32(out, totalCount);
		writeCompilationUnits(c1,          pool, out);
		writeCompilationUnits(c2,          pool, out);
		writeCompilationUnits(c3.values(), pool, out);
		writeCompilationUnits(c5.values(), pool, out);
		writeCompilationUnits(c4,          pool, out);

		// go back to near the beginning, and write out the location of the constant pool
		out.flush();
		long offsetOfConstantPool = file.getFilePointer();
		file.seek(offsetOfPointerToConstantPool);
		file.writeLong(offsetOfConstantPool);
		file.seek(offsetOfConstantPool);

		writeConstantPool(pool, out);

		out.flush();
		return totalCount;
	}

	private void writeSwcDefSignatureChecksums(Map<QName, Long> swcDefSignatureChecksums,
											   Map<Object, Integer> pool,
											   OutputStream out) throws IOException
	{
		for (Iterator<QName> i = swcDefSignatureChecksums.keySet().iterator(); i.hasNext(); )
		{
			QName qName = i.next();
			Long ts = swcDefSignatureChecksums.get(qName);
			writeU32(out, addQName(pool, qName));
			writeLong(out, ts.longValue());
		}
	}

    private void writeFileChecksums(Map<String, Long> m, Map<Object, Integer> pool, OutputStream out) throws IOException
	{
        for (Iterator<String> i = m.keySet().iterator(); i.hasNext();)
		{
			String fileName = i.next();
            Long ts = m.get(fileName);
            writeU32(out, addString(pool, fileName));
            writeLong(out, ts.longValue());
		}
	}

	private void writeHeader(int checksum,
							 int cmd_checksum,
							 int linker_checksum,
							 int swc_checksum,
							 String description,
							 OutputStream out) throws IOException
	{
		writeU32(out, major_version); // major version
		writeU32(out, minor_version); // minor version

		writeU32(out, checksum); // checksum
		writeU32(out, cmd_checksum);
		writeU32(out, linker_checksum);
		writeU32(out, swc_checksum);

		byte[] b = description.getBytes("UTF8");
		writeU32(out, b.length);
		writeBytes(out, b);
	}

	private void writeConstantPool(Map<Object, Integer> pool, OutputStream out) throws IOException
	{
		// invert the map
		Object[] values = new Object[pool.size()];
		for (Map.Entry<Object, Integer> entry: pool.entrySet()) {
			int index = entry.getValue();
			values[index] = entry.getKey();
		}

        writeU32(out, pool.size());
        for (Object value : values)
        {
			if (value instanceof String)
			{
				writeU8(out, 1);

				byte[] b = ((String) value).getBytes("UTF8");
				writeU32(out, b.length);
				writeBytes(out, b);
			}
			else if (value instanceof ArrayKey)
			{
				writeU8(out, 2);

				String[] a = ((ArrayKey) value).a1;
				writeU32(out, a == null ? 0 : a.length);

				for (int j = 0, size = (a == null) ? 0 : a.length; j < size; j++)
				{
					writeU32(out, addString(pool, a[j]));
				}
			}
			else if (value instanceof byte[])
			{
				writeU8(out, 3);

				byte[] b = (byte[]) value;
				writeU32(out, b.length);
				if (b.length > 0)
				{
					writeBytes(out, b);
				}
			}
			else if (value instanceof QName)
			{
				writeU8(out, 4);

				QName qName = (QName) value;
				writeU32(out, addString(pool, qName.getNamespace()));
				writeU32(out, addString(pool, qName.getLocalPart()));
			}
			else if (value instanceof MultiName)
			{
				writeU8(out, 5);

				MultiName multiName = (MultiName) value;
				writeU32(out, addStrings(pool, multiName.namespaceURI));
				writeU32(out, addString(pool, multiName.localPart));
			}
			else if (value instanceof flex2.compiler.abc.MetaData)
			{
				writeU8(out, 6);

				flex2.compiler.abc.MetaData md = (flex2.compiler.abc.MetaData) value;
				writeU32(out, addString(pool, md.getID()));
				writeU32(out, md.count());
				for (int j = 0, count = md.count(); j < count; j++)
				{
					String key = md.getKey(j);
					String val = md.getValue(j);

					writeU32(out, addString(pool, key == null ? "" : key));
					writeU32(out, addString(pool, val));
				}
			}
			else
			{
				assert false;
			}
		}
	}

	private void writeSourceNames(List sources, Map<Object, Integer> pool, OutputStream out) throws IOException
	{
		for (int i = 0, size = sources.size(); i < size; i++)
		{
			Source s = (Source) sources.get(i);
			if (s != null)
			{
				writeU32(out, addString(pool, s.getName()));
				if (s.isFileSpecOwner())
				{
					writeU8(out, 0);
				}
				else if (s.isSourceListOwner())
				{
					writeU8(out, 1);
				}
				else if (s.isSourcePathOwner())
				{
					writeU8(out, 2);
				}
				else if (s.isResourceContainerOwner())
				{
					writeU8(out, 3);
				}
				else if (s.isResourceBundlePathOwner())
				{
					writeU8(out, 4);
				}
				else if (s.isSwcScriptOwner())
				{
					writeU8(out, 5);
				}
                else if (s.isCompilerSwcContextOwner())
                {
                    writeU8(out, 6);
                }
                else
                {
                    writeU8(out, 7);
                    assert false : "s = " + s + ", owner = " + s.getOwner();
                }
			}
			else
			{
				writeU32(out, addString(pool, "null"));
			}
		}
	}

	private void writeFileSpec(FileSpec fileSpec, Map<Object, Integer> pool, OutputStream out) throws IOException
	{
		writeU8(out, fileSpec != null ? 1 : 0);
		if (fileSpec == null)
			return;

		String[] mimeTypes = fileSpec.getMimeTypes();
		Collection<Source> sources = fileSpec.sources();

		writeU32(out, mimeTypes.length);

		for (int i = 0, length = mimeTypes.length; i < length; i++)
		{
			writeU32(out, addString(pool, mimeTypes[i]));
		}

		writeU32(out, sources.size());

		for (Iterator<Source> i = sources.iterator(); i.hasNext();)
		{
			Source s = i.next();
			writeU32(out, addString(pool, s.getName()));
		}
	}

	private void writeSourceList(SourceList sourceList, Map<Object, Integer> pool, OutputStream out) throws IOException
	{
		writeU8(out, sourceList != null ? 1 : 0);
		if (sourceList == null)
			return;

		String[] mimeTypes = sourceList.getMimeTypes();
		List<File> paths = sourceList.getPaths();
		Collection<Source> sources = sourceList.sources().values();

		writeU32(out, mimeTypes.length);

		for (int i = 0, length = mimeTypes.length; i < length; i++)
		{
			writeU32(out, addString(pool, mimeTypes[i]));
		}

		writeU32(out, paths.size());

		for (int i = 0, length = paths.size(); i < length; i++)
		{
			writeU32(out, addString(pool, FileUtil.getCanonicalPath(paths.get(i))));
		}

		writeU32(out, sources.size());

		for (Iterator<Source> i = sources.iterator(); i.hasNext();)
		{
			Source s = i.next();
			writeU32(out, addString(pool, s.getName()));
		}
	}

	private void writeSourcePath(SourcePath sourcePath, Map<Object, Integer> pool, OutputStream out) throws IOException
	{
		writeU8(out, sourcePath != null ? 1 : 0);
		if (sourcePath == null)
			return;

		String[] mimeTypes = sourcePath.getMimeTypes();
		List<File> paths = sourcePath.getPaths();
		Map<String, Source> sources = sourcePath.sources();

		writeU32(out, mimeTypes.length);

		for (int i = 0, length = mimeTypes.length; i < length; i++)
		{
			writeU32(out, addString(pool, mimeTypes[i]));
		}

		writeU32(out, paths.size());

		for (int i = 0, length = paths.size(); i < length; i++)
		{
			writeU32(out, addString(pool, FileUtil.getCanonicalPath(paths.get(i))));
		}

		writeU32(out, sources.size());

		for (Iterator<String> i = sources.keySet().iterator(); i.hasNext();)
		{
			String className = i.next();
			Source s = sources.get(className);

			writeU32(out, addString(pool, className));
			writeU32(out, addString(pool, s.getName()));
		}
	}

	private void writeResourceBundlePath(ResourceBundlePath bundlePath, Map<Object, Integer> pool, OutputStream out) throws IOException
	{
		writeU8(out, bundlePath != null ? 1 : 0);
		if (bundlePath == null)
			return;

		String[] mimeTypes = bundlePath.getMimeTypes();
		String[] locales = bundlePath.getLocales();
		Map<String, List<File>> rbDirectories = bundlePath.getResourceBundlePaths();
		Map<String, Source> sources = bundlePath.sources();

		writeU32(out, mimeTypes.length);

		for (int i = 0, length = mimeTypes.length; i < length; i++)
		{
			writeU32(out, addString(pool, mimeTypes[i]));
		}

		writeU32(out, locales == null ? 0 : locales.length);

		for (int i = 0, length = locales == null ? 0 : locales.length; i < length; i++)
		{
			writeU32(out, addString(pool, locales[i]));
			
			List<File> paths = rbDirectories.get(locales[i]);

			writeU32(out, paths == null ? 0 : paths.size());

			for (int j = 0, size = paths.size(); j < size; j++)
			{
				writeU32(out, addString(pool, FileUtil.getCanonicalPath(paths.get(j))));
			}
		}

		writeU32(out, sources.size());

		for (Iterator<String> i = sources.keySet().iterator(); i.hasNext();)
		{
			String bundleName = i.next();
			Source s = sources.get(bundleName);

			writeU32(out, addString(pool, bundleName));
			writeU32(out, addString(pool, s.getName()));
			
			ResourceFile rf = (ResourceFile) s.getBackingFile();
			VirtualFile[] rFiles = rf.getResourceFiles();
			VirtualFile[] rRoots = rf.getResourcePathRoots();

			writeU32(out, rFiles.length);			
			for (int j = 0, size = rFiles.length; j < size; j++)
			{
				writeU32(out, addString(pool, rFiles[j] != null ? rFiles[j].getName() : "null"));
				writeU32(out, addString(pool, rRoots[j] != null ? rRoots[j].getName() : "null"));
			}
		}
	}

	private void writeCompilationUnits(Collection<Source> sources, Map<Object, Integer> pool, OutputStream out) throws IOException
	{
		for (Source s : sources)
        {
			writeSource(s, pool, out);

			CompilationUnit u = s.getCompilationUnit();
			if (u != null)
			{
				writeCompilationUnit(u, pool, out);
			}
		}
	}

	private void writeSource(Source s, Map<Object, Integer> pool, OutputStream out) throws IOException
	{
	    final CompilationUnit unit = s.getCompilationUnit();
	    final boolean hasUnit = (unit != null);

        writeU32(out, addString(pool, s.getName()));
		writeU32(out, addString(pool, s.getRelativePath()));
		writeU32(out, addString(pool, s.getShortName()));
		if (s.isFileSpecOwner())
		{
			writeU8(out, 0);
		}
		else if (s.isSourceListOwner())
		{
			writeU8(out, 1);
			writeU32(out, addString(pool, s.getPathRoot().getName()));
		}
		else if (s.isSourcePathOwner())
		{
			writeU8(out, 2);
			writeU32(out, addString(pool, s.getPathRoot().getName()));
		}
		else if (s.isResourceContainerOwner())
		{
			writeU8(out, 3);
		}
		else if (s.isResourceBundlePathOwner())
		{
			writeU8(out, 4);
			writeU32(out, addString(pool, s.getPathRoot().getName()));
		}
        else if (s.isCompilerSwcContextOwner())
        {
            writeU8(out, 5);
        }
        else
        {
            writeU8(out, 6);
            assert false : "owner = " + s.getOwner();
        }

		writeU8(out, s.isInternal() ? 1 : 0);
		writeU8(out, s.isRoot() ? 1 : 0);
		writeU8(out, s.isDebuggable() ? 1 : 0);
        writeU8(out, hasUnit ? 1 : 0);
		writeLong(out, s.getFileTime());

        // signatures
        {
    		final boolean hasSignatureChecksum = hasUnit && unit.hasSignatureChecksum();
            writeU8(out, (hasSignatureChecksum ? 1 : 0));
            if (hasSignatureChecksum)
            {
                final Long signatureChecksum = unit.getSignatureChecksum();
                writeLong(out, signatureChecksum.longValue());
            }
        }

		writeU32(out, s.getFileIncludeSize());
		for (Iterator<VirtualFile> j = s.getFileIncludes(); j.hasNext();)
		{
			VirtualFile f = j.next();

			writeU32(out, addString(pool, f.getName()));
			writeLong(out, s.getFileIncludeTime(f));
		}

		List<Warning> warnings = null;
		if (s.getLogger() != null && (warnings = s.getLogger().getWarnings()) != null)
		{
			writeU32(out, warnings.size());
		}
		else
		{
			writeU32(out, 0);
		}

		for (int i = 0, size = warnings == null ? 0 : warnings.size(); i < size; i++)
		{
			LocalLogger.Warning w = warnings.get(i);
			writeU32(out, addString(pool, w.path == null ? "" : w.path));
			writeU32(out, addString(pool, w.warning == null ? "" : w.warning));
			writeU32(out, addString(pool, w.source == null ? "" : w.source));
			writeU32(out, w.line == null ? -1 : w.line.intValue());
			writeU32(out, w.col == null ? -1 : w.col.intValue());
			writeU32(out, w.errorCode == null ? -1 : w.errorCode.intValue());
		}
	}
	
	private void writeMap(OutputStream out, Map<Object, Integer> pool, Map<String, Object> map)  throws IOException
	{
		writeU32(out, map.size());

		for (Iterator<Map.Entry<String, Object>> i = map.entrySet().iterator(); i.hasNext();)
		{
			Map.Entry<String, Object> e = i.next();
			String key = e.getKey();
			String value = (String) e.getValue();

			if (value != null)
			{
				writeU32(out, addString(pool, key));
				writeU32(out, addString(pool, value));
			}
			else
			{
				assert false : key + " can't be null.";
			}
		}
	}

	private void writeCompilationUnit(CompilationUnit u, Map<Object, Integer> pool, OutputStream out) throws IOException
	{
		writeU32(out, addBytes(pool, u.bytes.toByteArray()));
		writeU32(out, u.getWorkflow());
		writeU32(out, u.getState());

		writeU32(out, u.topLevelDefinitions.size());

		for (Iterator<QName> i = u.topLevelDefinitions.iterator(); i.hasNext();)
		{
			writeU32(out, addQName(pool, i.next()));
		}

		writeU32(out, u.inheritanceHistory.size());

		for (MultiName multiName : u.inheritanceHistory.keySet())
		{
			QName qName = u.inheritanceHistory.get(multiName);

			writeU32(out, addMultiName(pool, multiName));
			writeU32(out, addQName(pool, qName));
		}

		writeU32(out, u.typeHistory.size());

		for (MultiName multiName : u.typeHistory.keySet())
		{
			QName qName = u.typeHistory.get(multiName);

			writeU32(out, addMultiName(pool, multiName));
			writeU32(out, addQName(pool, qName));
		}

		writeU32(out, u.namespaceHistory.size());

		for (MultiName multiName : u.namespaceHistory.keySet())
		{
			QName qName = u.namespaceHistory.get(multiName);

			writeU32(out, addMultiName(pool, multiName));
			writeU32(out, addQName(pool, qName));
		}

		writeU32(out, u.expressionHistory.size());

		for (MultiName multiName : u.expressionHistory.keySet())
		{
			QName qName = u.expressionHistory.get(multiName);

			writeU32(out, addMultiName(pool, multiName));
			writeU32(out, addQName(pool, qName));
		}

		if (u.auxGenerateInfo != null && u.auxGenerateInfo.size() > 0)
		{
			writeU8(out, 1);

			String baseLoaderClass = (String) u.auxGenerateInfo.get( "baseLoaderClass");
			writeU32(out, addString(pool, baseLoaderClass == null ? "" : baseLoaderClass));

			String generateLoaderClass = (String) u.auxGenerateInfo.get( "generateLoaderClass");
			writeU32(out, addString(pool, generateLoaderClass == null ? "" : generateLoaderClass));

			String className = (String) u.auxGenerateInfo.get( "windowClass");
			writeU32(out, addString(pool, className == null ? "" : className));

			String preLoader = (String) u.auxGenerateInfo.get( "preloaderClass");
			writeU32(out, addString(pool, preLoader == null ? "" : preLoader));

			Boolean usePreloader = (Boolean) u.auxGenerateInfo.get( "usePreloader");
			writeU8(out, usePreloader.booleanValue() ? 1 : 0);

			Map<String, Object> rootAttributeMap = (Map<String, Object>) u.auxGenerateInfo.get( "rootAttributes");
			writeMap(out, pool, rootAttributeMap);

			Map<String, Object> rootAttributeEmbedVars = (Map<String, Object>) u.auxGenerateInfo.get( "rootAttributeEmbedVars");
			writeMap(out, pool, rootAttributeEmbedVars);

			Map<String, Object> rootAttributeEmbedNames = (Map<String, Object>) u.auxGenerateInfo.get( "rootAttributeEmbedNames");
			writeMap(out, pool, rootAttributeEmbedNames);
		}
		else
		{
			writeU8(out, 0);
		}

        if (u.iconFile != null)
        {
            writeU8(out, 1);
            writeU32(out, addString(pool, u.icon));
            writeU32(out, addString(pool, u.iconFile.getName()));
        }
        else
        {
            writeU8(out, 0);
        }

		writeAssets(u, pool, out);
	}

	private void writeAssets(CompilationUnit u, Map<Object, Integer> pool, OutputStream out) throws IOException
	{
        if (u.hasAssets())
        {
            writeU32(out, u.getAssets().count());

			Movie movie = new Movie();
			movie.version = configuration.getTargetPlayerMajorVersion();
			assert movie.version >= 9;
			movie.size = new Rect(100 * 20, 100 * 20);
			movie.framerate = 12;

			Frame frame = new Frame();
			movie.frames = new ArrayList<Frame>();
			movie.frames.add(frame);

			for (Iterator<Entry<String, AssetInfo>> i = u.getAssets().iterator(); i.hasNext();)
			{
				Entry<String, AssetInfo> entry = i.next();
				String className = entry.getKey();
				AssetInfo assetInfo = entry.getValue();

				writeU32(out, addString(pool, className));
				if (assetInfo.getPath() != null)
				{
					writeU32(out, addString(pool, assetInfo.getPath().getName()));
				}
				else
				{
					writeU32(out, addString(pool, ""));
				}
				writeLong(out, assetInfo.getCreationTime());

				DefineTag asset = assetInfo.getDefineTag();
				frame.addSymbolClass(className, asset);

				if (asset.name != null)
				{
					frame.addExport(asset);
				}
			}

			TagEncoder handler = new TagEncoder();
			MovieEncoder encoder = new MovieEncoder(handler);
			encoder.export(movie, true); // use compression

			// Hack: Nasty hard-coded knowledge that 'out' refers to the same file as 'file'
			writeU32(out, 0);
			out.flush();
			long before = file.getFilePointer();
			handler.writeTo(out);
			out.flush();
			long after = file.getFilePointer();
			file.seek(before - 4);
			file.writeInt((int)(after - before));
			file.seek(after);
		}
        else
        {
            writeU32(out, 0);
        }
	}

	//FIXME all codepaths to here are List<Source>; this code expects List<String>, which is consumed by
    //      readCompilationUnits() which expects strings too, then converts them back to List<Source>.
    //      this is abusive; we should create a temporary list for this purpose.
	int read(FileSpec fileSpec,
			 SourceList sourceList,
			 SourcePath sourcePath,
			 ResourceContainer resources,
	         ResourceBundlePath bundlePath,
	         List sources,
	         List<CompilationUnit> units,
	         int[] checksums,
	         Map<QName, Long> swcDefSignatureChecksums,
	         Map<String, Long> swcFileChecksums,
	         Map<String, Long> archiveFileChecksums) throws IOException
	{
		if (!readVersion())
		{
			LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
			throw new IOException(l10n.getLocalizedTextString(new ObsoleteCacheFileFormat()));
		}

		if (!readChecksum(checksums))
		{
			return -1;
		}

		Object[] pool = readConstantPool();

		if (!readFileSpec(pool, fileSpec))
		{
			return -2;
		}

		if (!readSourceList(pool, sourceList))
		{
			return -3;
		}

		if (!readSourcePath(pool, sourcePath))
		{
			return -4;
		}

		if (!readResourceBundlePath(pool, bundlePath))
		{
			return -5;
		}
		
		Map<String, Object> owners = new HashMap<String, Object>();
		if (!readSourceNames(pool, sources, units, owners))
		{
			return -6;
		}
		
		if (!readSwcDefSignatureChecksums(pool, swcDefSignatureChecksums))
		{
			return -7;
		}

		if (!readFileChecksums(pool, swcFileChecksums))
		{
			return -8;
		}

        if (!readFileChecksums(pool, archiveFileChecksums))
        {
            return -9;
        }

		int count = readCompilationUnits(pool, fileSpec, sourceList, sourcePath, resources, bundlePath,
										 sources, units, owners);
		resources.refresh();

		return count;
	}

	private boolean readVersion() throws IOException
	{
		int major = readU32(); // major version
		int minor = readU32(); // minor version

		return (major == major_version) && (minor == minor_version);
	}

	private boolean readChecksum(int[] checksums) throws IOException
	{
		int targetChecksum = readU32(); // checksum
		int targetCmdChecksum = readU32();
		int targetLinkerChecksum = readU32();
		int targetSwcChecksum = readU32();
		/* String description = */ new String(readBytes(readU32()));

		boolean result = checksums[1] == targetCmdChecksum;
		
		checksums[0] = targetChecksum;
		checksums[1] = targetCmdChecksum;
		checksums[2] = targetLinkerChecksum;
		checksums[3] = targetSwcChecksum;
		
		return result;
	}

	private Object[] readConstantPool() throws IOException
	{
		// Read the offset of the constant pool and seek there
		long constantPoolOffset = file.readLong();
		long startingOffset = file.getFilePointer();
		file.seek(constantPoolOffset);

		Object[] pool = new Object[readU32()];

		for (int i = 0; i < pool.length; i++)
		{
			switch (readU8())
			{
			case 1: // String
				pool[i] = new String(readBytes(readU32()), "UTF8");
				break;
			case 2: // String[]
				String[] strings = new String[readU32()];
				for (int j = 0; j < strings.length; j++)
				{
					strings[j] = (String) pool[readU32()];
				}
				pool[i] = strings;
				break;
			case 3: // byte[]
				pool[i] = readBytes(readU32());
				break;
			case 4: // QName
				pool[i] = new QName((String) pool[readU32()], (String) pool[readU32()]);
				break;
			case 5: // MultiName
				pool[i] = new MultiName((String[]) pool[readU32()], (String) pool[readU32()]);
				break;
			case 6: // MetaData
				MetaData md = new MetaData((String) pool[readU32()], readU32());
				for (int j = 0; j < md.count(); j++)
				{
					String key = (String) pool[readU32()];
					if (key.length() > 0)
					{
						md.setKeyValue(j, key, (String) pool[readU32()]);
					}
					else
					{
						md.setValue(j, (String) pool[readU32()]);
					}
				}
				pool[i] = md;
				break;
			default:
				assert false;
			}
		}

		// Now that we've read the constant pool from near the end of the file,
		// seek back to where everything else is
		file.seek(startingOffset);

		return pool;
	}

	private boolean readSourceNames(Object[] pool, List<Object> sources, List<CompilationUnit> units, Map<String, Object> owners) throws IOException
	{
		int size = readU32();

		if (sources != null) sources.clear();
		if (units != null) units.clear();
		
		for (int i = 0; i < size; i++)
		{
			String name = (String) pool[readU32()];
			if (!"null".equals(name))
			{
				owners.put(name, new Integer(readU8()));
				if (sources != null) sources.add(name);
			}
			else
			{
				if (sources != null) sources.add(null);
			}
			if (units != null) units.add(null);
		}
		
		return true;
	}
	
	private boolean readSwcDefSignatureChecksums(Object[] pool, Map<QName, Long> swcDefSignatureChecksums) throws IOException
	{
		int size = readU32();
		
		for (int i = 0; i < size; i++)
		{
			QName qName = (QName) pool[readU32()];
			long ts = readLong();
			if (swcDefSignatureChecksums != null) swcDefSignatureChecksums.put(qName, new Long(ts));
		}

		return true;
	}

	private boolean readFileChecksums(Object[] pool, Map<String, Long> m) throws IOException
	{
		int size = readU32();

		for (int i = 0; i < size; i++)
		{
			String fileName = (String) pool[readU32()];
			long ts = readLong();
            if (m != null) m.put(fileName, new Long(ts));
		}

		return true;
	}

	private boolean readFileSpec(Object[] pool, FileSpec fileSpec) throws IOException
	{
		boolean fileSpecDataExists = readU8()==1 ? true : false;
		if (fileSpecDataExists && fileSpec == null)
		{
			LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
			throw new IOException(l10n.getLocalizedTextString(new NoFileSpec()));
		}
		else if (!fileSpecDataExists)
		{
			return true;
		}

		int length = readU32();
		String[] mimeTypes = new String[length];

		for (int i = 0; i < length; i++)
		{
			mimeTypes[i] = (String) pool[readU32()];
		}

		length = readU32();
		String[] sources = new String[length];

		for (int i = 0; i < length; i++)
		{
			sources[i] = (String) pool[readU32()];
		}

		// check FileSpec

		String[] targetMimeTypes = fileSpec.getMimeTypes();

		if ((length = targetMimeTypes.length) == mimeTypes.length)
		{
			for (int i = 0; i < length; i++)
			{
				if (!mimeTypes[i].equals(targetMimeTypes[i]))
				{
					return false;
				}
			}
		}
		else
		{
			return false;
		}

		Collection<Source> c = fileSpec.sources();

		if (c.size() == sources.length)
		{
			Iterator<Source> it = c.iterator();
			for (int i = 0; it.hasNext() && i < sources.length; i++)
			{
				Source s = it.next();
				if (!s.getName().equals(sources[i]))
				{
					return false;
				}
			}
		}
		else
		{
			return false;
		}

		return true;
	}

	private boolean readSourceList(Object[] pool, SourceList sourceList) throws IOException
	{
		boolean sourceListDataExists = readU8()==1 ? true : false;
		if (sourceListDataExists && sourceList == null)
		{
			LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
			throw new IOException(l10n.getLocalizedTextString(new NoSourceList()));
		}
		else if (!sourceListDataExists)
		{
			return true;
		}

		int length = readU32();
		String[] mimeTypes = new String[length];

		for (int i = 0; i < length; i++)
		{
			mimeTypes[i] = (String) pool[readU32()];
		}

		length = readU32();
		String[] paths = new String[length];

		// classpath
		for (int i = 0; i < length; i++)
		{
			paths[i] = (String) pool[readU32()];
		}

		length = readU32();
		String[] sources = new String[length];

		for (int i = 0; i < length; i++)
		{
			sources[i] = (String) pool[readU32()];
		}

		// check SourceList

		String[] targetMimeTypes = sourceList.getMimeTypes();

		if ((length = targetMimeTypes.length) == mimeTypes.length)
		{
			for (int i = 0; i < length; i++)
			{
				if (!mimeTypes[i].equals(targetMimeTypes[i]))
				{
					return false;
				}
			}
		}
		else
		{
			return false;
		}

		Collection<Source> c = sourceList.sources().values();

		if (c.size() == sources.length)
		{
			Iterator<Source> it = c.iterator();
			for (int i = 0; it.hasNext() && i < sources.length; i++)
			{
				Source s = it.next();
				if (!s.getName().equals(sources[i]))
				{
					return false;
				}
			}
		}
		else
		{
			return false;
		}

		return true;
	}

	private boolean readSourcePath(Object[] pool, SourcePath sourcePath) throws IOException
	{
		boolean sourcePathDataExists = readU8()==1 ? true : false;
		if (sourcePathDataExists && sourcePath == null)
		{
			LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
			throw new IOException(l10n.getLocalizedTextString(new NoSourcePath()));
		}
		else if (!sourcePathDataExists)
		{
			return true;
		}

		int length = readU32();
		String[] mimeTypes = new String[length];

		for (int i = 0; i < length; i++)
		{
			mimeTypes[i] = (String) pool[readU32()];
		}

		length = readU32();
		String[] paths = new String[length];

		// classpath
		for (int i = 0; i < length; i++)
		{
			paths[i] = (String) pool[readU32()];
		}

		length = readU32();
		String[] sources = new String[length];
		String[] classNames = new String[length];

		// filename
		for (int i = 0; i < length; i++)
		{
			classNames[i] = (String) pool[readU32()];
			sources[i] = (String) pool[readU32()];
		}

		// check SourcePath

		String[] targetMimeTypes = sourcePath.getMimeTypes();

		if ((length = targetMimeTypes.length) == mimeTypes.length)
		{
			for (int i = 0; i < length; i++)
			{
				if (!mimeTypes[i].equals(targetMimeTypes[i]))
				{
					return false;
				}
			}
		}
		else
		{
			return false;
		}

		List<File> targetPaths = sourcePath.getPaths();

		if ((length = targetPaths.size()) == paths.length)
		{
			for (int i = 0; i < length; i++)
			{
				if (!paths[i].equals(FileUtil.getCanonicalPath(targetPaths.get(i))))
				{
					return false;
				}
			}
		}
		else
		{
			return false;
		}

        //FIXME we're abusing this list by adding Strings into it temporarily and turning them to sources later
        //      I'm not going to ruin the type parameters on sources() (<String, Object>) just to make this work,
        //      instead I'll keep the abuse and the warnings
		Map c = sourcePath.sources(); // <String, {Source, String}>

		for (int i = 0; i < classNames.length; i++)
		{
		    // TODO Fix this...
			// C: the value should be a Source, not a String... It's sort of okay because readCompilationUnit()
			//    will replace the String...
			c.put(classNames[i], sources[i]);
		}

		return true;
	}

    private boolean readResourceBundlePath(Object[] pool, ResourceBundlePath bundlePath) throws IOException
	{
    	boolean resourceBundlePathDataExists = readU8()==1 ? true : false;
		if (resourceBundlePathDataExists && bundlePath == null)
		{
			LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
			throw new IOException(l10n.getLocalizedTextString(new NoSourcePath()));
		}
		else if (!resourceBundlePathDataExists)
		{
			return true;
		}

		int size;
		int length = readU32();
		String[] mimeTypes = new String[length];

		for (int i = 0; i < length; i++)
		{
			mimeTypes[i] = (String) pool[readU32()];
		}

		length = readU32();
		String[] locales = new String[length];
		Map<String, String[]> rbDirectories = new HashMap<String, String[]>();
		
		for (int i = 0; i < length; i++)
		{
			locales[i] = (String) pool[readU32()];

			size = readU32();
			String[] paths = new String[size];

			// classpath
			for (int j = 0; j < size; j++)
			{
				paths[j] = (String) pool[readU32()];
			}
			
			rbDirectories.put(locales[i], paths);
		}

		length = readU32();
		String[] bundleNames = new String[length];
		String[] sources = new String[length], list = null, list2 = null;
		Object[] rFiles = new Object[length], rRoots = new Object[length];

		// filename
		for (int i = 0; i < length; i++)
		{
			bundleNames[i] = (String) pool[readU32()];
			sources[i] = (String) pool[readU32()];

			size = readU32();

			rFiles[i] = list = new String[size];
			rRoots[i] = list2 = new String[size];
			
			for (int j = 0; j < size; j++)
			{
				list[j] = (String) pool[readU32()];
				if ("null".equals(list[j]))
				{
					list[j] = null;
				}
				
				list2[j] = (String) pool[readU32()];
				if ("null".equals(list2[j]))
				{
					list2[j] = null;
				}
			}
		}

		// check ResourceBundlePath

		String[] targetMimeTypes = bundlePath.getMimeTypes();

		if ((length = targetMimeTypes.length) == mimeTypes.length)
		{
			for (int i = 0; i < length; i++)
			{
				if (!mimeTypes[i].equals(targetMimeTypes[i]))
				{
					return false;
				}
			}
		}
		else
		{
			return false;
		}

		String[] targetLocales = bundlePath.getLocales();

		if ((length = targetLocales.length) == locales.length)
		{
			for (int i = 0; i < length; i++)
			{
				if (!locales[i].equals(targetLocales[i]))
				{
					return false;
				}
			}
		}
		else
		{
			return false;
		}

		Map<String, List<File>> targetRBDirectories = bundlePath.getResourceBundlePaths();
		
		if ((size = targetRBDirectories.size()) == rbDirectories.size())
		{
			for (int i = 0; i < size; i++)
			{
				List<File> targetPaths = targetRBDirectories.get(targetLocales[i]);
				String[] paths = rbDirectories.get(locales[i]);
				
				if ((length = targetPaths.size()) == paths.length)
				{
					for (int j = 0; j < length; j++)
					{
						if (!paths[j].equals(FileUtil.getCanonicalPath(targetPaths.get(j))))
						{
							return false;
						}
					}
				}
				else
				{
					return false;
				}
			}
		}
		else
		{
			return false;
		}

		Map c = bundlePath.sources(); // <String, {Source, Object[]}>

		assert c.size() == 0;

		for (int i = 0; i < bundleNames.length; i++)
		{
            //FIXME
			// C: the value should be a Source, not an Object[]... It's sort of okay because readCompilationUnit()
			//    will replace the Object[]...
		    // we cannot do anything about the warning this generates
			c.put(bundleNames[i], new Object[] { sources[i], rFiles[i], rRoots[i] });
		}

		return true;
	}

    //FIXME Sources is a List<String> when it enters the function, and a List<Source> when it leaves...
	private int readCompilationUnits(Object[] pool, FileSpec fileSpec, SourceList sourceList, SourcePath sourcePath,
	                                 ResourceContainer resources, ResourceBundlePath bundlePath,
	                                 List<Object> sources, List<CompilationUnit> units, Map<String, Object> owners) throws IOException
	{
		int src_count = readU32();

		RandomAccessFileInputStream in = new RandomAccessFileInputStream(file);

		Map m = sourcePath.sources();
        Map<String, String> mappings = new HashMap<String, String>();
        Map<String, Object> rbMappings = new HashMap<String, Object>();

		for (Iterator i = m.keySet().iterator(); i.hasNext();)
		{
			String className = (String) i.next();
			String fileName = (String) m.get(className);

			mappings.put(fileName, className);
		}

		m.clear();

		m = bundlePath.sources();
		for (Iterator i = m.keySet().iterator(); i.hasNext();)
		{
			String className = (String) i.next();
			Object[] value = (Object[]) m.get(className);
			String fileName = (String) value[0];
			String[] rFiles = (String[]) value[1];
			String[] rRoots = (String[]) value[2];

			rbMappings.put(fileName, new Object[] { className, rFiles, rRoots });
		}

		m.clear();

		for (int i = 0; i < src_count; i++)
		{
			readCompilationUnit(pool, mappings, rbMappings, in, fileSpec, sourceList, sourcePath, resources, bundlePath, owners);
		}

		for (int i = 0, len = sources == null ? 0 : sources.size(); i < len; i++)
		{
			String n = (String) sources.get(i);
			Object obj = owners.get(n);
			if (obj instanceof Source)
			{
				Source s = (Source) obj;
				sources.set(i, s);
				units.set(i, s.getCompilationUnit());
			}
		}

		return src_count;
	}

	private void readMap(InputStream in, Object[] pool, Map<String, Object> map) throws IOException
	{
		int size = readU32(in);
		for (int i = 0; i < size; i++)
		{
			String key = (String) pool[readU32(in)];
			String value = (String) pool[readU32(in)];

			map.put(key, value);
		}
	}

	private void readCompilationUnit(Object[] pool, Map<String, String> mappings, Map<String, Object> rbMappings, InputStream in,
                                     FileSpec fileSpec, SourceList sourceList, SourcePath sourcePath,
                                     ResourceContainer resources, ResourceBundlePath bundlePath, Map<String, Object> owners)
	    throws IOException
	{
		PathResolver resolver = ThreadLocalToolkit.getPathResolver();

		String name = (String) pool[readU32(in)];
		String relativePath = (String) pool[readU32(in)];
		String shortName = (String) pool[readU32(in)];
		int owner = readU8(in);

		VirtualFile pathRoot = null;
		// 1 == SourceList
		// 2 == SourcePath
		// 4 == ResourceBundlePath
		if ((owner == 1 ) || (owner == 2) || (owner == 4))
		{
			// C: Unfortunately, PathResolver itself is not a complete solution. For each type
			//    of VirtualFile, there must be a mechanism to recognize the name format and
			//    construct an appropriate VirtualFile instance.
			pathRoot = resolver.resolve((String) pool[readU32(in)]);
		}

		boolean isInternal = (readU8(in) == 1);
		boolean isRoot = (readU8(in) == 1);
		boolean isDebuggable = (readU8(in) == 1);
		boolean hasUnit = (readU8(in) == 1);
		long fileTime = readLong(in);
        
        final boolean hasSignatureChecksum = (readU8(in) == 1);
        Long signatureChecksum = null;
        if (hasSignatureChecksum)
        {
            assert hasUnit;
            signatureChecksum = new Long(readLong(in));
            // SignatureExtension.debug("READ      CRC32: " + signatureChecksum + "\t--> " + name);
        }

		int size = readU32(in);
        Set<VirtualFile> includes = new HashSet<VirtualFile>(size);
		Map<VirtualFile, Long> includeTimes = new HashMap<VirtualFile, Long>(size);

		for (int i = 0; i < size; i++)
		{
			String fileName = (String) pool[readU32(in)];
			VirtualFile f = resolver.resolve(fileName);
			long ts = readLong(in);

			if (f == null)
			{
				// C: create an instance of DeletedFile...
				f = new DeletedFile(fileName);
			}

			includes.add(f);
			includeTimes.put(f, new Long(ts));
		}

		size = readU32(in);
		LocalLogger logger = size == 0 ? null : new LocalLogger(null);

		for (int i = 0; i < size; i++)
		{
			String path = (String) pool[readU32(in)];
			if (path.length() == 0)
			{
				path = null;
			}
			String warning = (String) pool[readU32(in)];
			if (warning.length() == 0)
			{
				warning = null;
			}
			String source = (String) pool[readU32(in)];
			if (source.length() == 0)
			{
				source = null;
			}
			int line = readU32(in);
			int col = readU32(in);
			int errorCode = readU32(in);

			logger.recordWarning(path,
			                     line == -1 ? null : IntegerPool.getNumber(line),
			                     col == -1 ? null : IntegerPool.getNumber(col),
			                     warning,
			                     source,
			                     errorCode == -1 ? null : IntegerPool.getNumber(errorCode));
		}


		byte[] abc = (hasUnit) ? (byte[]) pool[readU32(in)] : null;
		Source s = null;

		if (owner == 0) // FileSpec
		{
			Collection<Source> c = fileSpec.sources();
			for (Iterator<Source> i = c.iterator(); i.hasNext();)
			{
				s = i.next();
				if (s.getName().equals(name))
				{
					Source.populateSource(s, fileTime, pathRoot, relativePath, shortName, fileSpec, isInternal, isRoot, isDebuggable,
					                      includes, includeTimes, logger);
					break;
				}
			}
		}
		else if (owner == 1) // SourceList
		{
			Collection<Source> c = sourceList.sources().values();
			for (Iterator<Source> i = c.iterator(); i.hasNext();)
			{
				s = i.next();
				if (s.getName().equals(name))
				{
					Source.populateSource(s, fileTime, pathRoot, relativePath, shortName, sourceList, isInternal, isRoot, isDebuggable,
					                      includes, includeTimes, logger);
					break;
				}
			}
		}
		else if (owner == 2) // SourcePath
		{
			Map<String, Source> c = sourcePath.sources();
			String className = mappings.get(name);

			if ((className != null) && !c.containsKey(className))
			{
				VirtualFile f = resolver.resolve(name);

				if (f == null)
				{
					f = new DeletedFile(name);
				}

				s = Source.newSource(f, fileTime, pathRoot, relativePath, shortName, sourcePath, isInternal, isRoot, isDebuggable,
				                     includes, includeTimes, logger);
				c.put(className, s);
			}
			else
			{
				assert false : name;
			}
		}
		else if (owner == 3) // ResourceContainer
		{
			if (resources == null)
			{
				LocalizationManager l10n = ThreadLocalToolkit.getLocalizationManager();
				throw new IOException(l10n.getLocalizedTextString(new NoResourceContainer()));
			}

			s = Source.newSource(abc, name, fileTime, pathRoot, relativePath, shortName, resources, isInternal, isRoot, isDebuggable,
			                     includes, includeTimes, logger);
			s = resources.addResource(s);
		}
		else if (owner == 4) // ResourceBundlePath
		{
			Map<String, Source> c = bundlePath.sources();
			Object[] value = (Object[]) rbMappings.get(name);
			String bundleName = (String) value[0];
			String[] rNames = (String[]) value[1];
			String[] rRoots = (String[]) value[2];

			if (bundleName != null)
			{
				VirtualFile[] rFiles = new VirtualFile[rNames.length];

				for (int i = 0; i < rFiles.length; i++)
				{
					if (rNames[i] != null)
					{
						rFiles[i] = resolver.resolve(rNames[i]);
						if (rFiles[i] == null)
						{
							rFiles[i] = new DeletedFile(rNames[i]);
						}
					}
				}

				VirtualFile[] rRootFiles = new VirtualFile[rRoots.length];

				for (int i = 0; i < rRootFiles.length; i++)
				{
					if (rRoots[i] != null)
					{
						rRootFiles[i] = resolver.resolve(rRoots[i]);
						if (rRootFiles[i] == null)
						{
							rRootFiles[i] = new DeletedFile(rRoots[i]);
						}
					}
				}

				VirtualFile f = new ResourceFile(name, bundlePath.getLocales(), rFiles, rRootFiles);
				s = Source.newSource(f, fileTime, pathRoot, relativePath, shortName, bundlePath, isInternal, isRoot, isDebuggable,
				                     includes, includeTimes, logger);
				c.put(bundleName, s);
			}
			else
			{
				assert false : name;
			}
		}
        else
        {
            assert false : "owner = " + owner;
        }

		if (logger != null)
		{
			logger.setSource(s);
		}

		if (hasUnit)
		{
			CompilationUnit u = s.newCompilationUnit(null, new CompilerContext());
            
            u.setSignatureChecksum(signatureChecksum);

			u.bytes.addAll(abc);
			u.setWorkflow(readU32(in));
			u.setState(readU32(in));

			size = readU32(in);
			for (int i = 0; i < size; i++)
			{
				u.topLevelDefinitions.add((QName) pool[readU32(in)]);
			}

			size = readU32(in);
			for (int i = 0; i < size; i++)
			{
				MultiName mName = (MultiName) pool[readU32(in)];
				QName qName = (QName) pool[readU32(in)];
				u.inheritanceHistory.put(mName, qName);
				u.inheritance.add(qName);
			}

			size = readU32(in);
			for (int i = 0; i < size; i++)
			{
				MultiName mName = (MultiName) pool[readU32(in)];
				QName qName = (QName) pool[readU32(in)];
				u.typeHistory.put(mName, qName);
				u.types.add(qName);
			}

			size = readU32(in);
			for (int i = 0; i < size; i++)
			{
				MultiName mName = (MultiName) pool[readU32(in)];
				QName qName = (QName) pool[readU32(in)];
				u.namespaceHistory.put(mName, qName);
				u.namespaces.add(qName);
			}

			size = readU32(in);
			for (int i = 0; i < size; i++)
			{
				MultiName mName = (MultiName) pool[readU32(in)];
				QName qName = (QName) pool[readU32(in)];
				u.expressionHistory.put(mName, qName);
				u.expressions.add(qName);
			}

			boolean hasAuxGenerateInfo = readU8(in) == 1;

			if (hasAuxGenerateInfo)
			{
				u.auxGenerateInfo = new HashMap<String, Object>();

				String baseLoaderClass = (String) pool[readU32(in)];
				u.auxGenerateInfo.put("baseLoaderClass", baseLoaderClass.length() > 0 ? baseLoaderClass : null);

				String generateLoaderClass = (String) pool[readU32(in)];
				u.auxGenerateInfo.put("generateLoaderClass", generateLoaderClass.length() > 0 ? generateLoaderClass : null);

				String className = (String) pool[readU32(in)];
				u.auxGenerateInfo.put("windowClass", className.length() > 0 ? className : null);

				String preLoader = (String) pool[readU32(in)];
				u.auxGenerateInfo.put("preloaderClass", preLoader.length() > 0 ? preLoader : null);

				u.auxGenerateInfo.put("usePreloader", new Boolean(readU8(in) == 1));

				Map<String, Object> rootAttributeMap = new HashMap<String, Object>();
				u.auxGenerateInfo.put("rootAttributes", rootAttributeMap);
				readMap(in, pool, rootAttributeMap);

				Map<String, Object> rootAttributeEmbedVars = new HashMap<String, Object>();
				u.auxGenerateInfo.put("rootAttributeEmbedVars", rootAttributeEmbedVars);
				readMap(in, pool, rootAttributeEmbedVars);

				Map<String, Object> rootAttributeEmbedNames = new HashMap<String, Object>();
				u.auxGenerateInfo.put("rootAttributeEmbedNames", rootAttributeEmbedNames);
				readMap(in, pool, rootAttributeEmbedNames);
			}

            if (readU8(in) == 1)
            {
                u.icon = (String) pool[readU32(in)];
                u.iconFile = resolver.resolve((String) pool[readU32(in)]);
            }

			readAssets(pool, u, in);
		}
		
		if (s != null)
		{
			name = s.getName();
			Object obj = owners.get(name);
			if (obj == null || obj instanceof Source)
			{
				return;
			}
			
			int value = ((Integer) obj).intValue();
			if ((s.isFileSpecOwner() && value == 0) ||
				(s.isSourceListOwner() && value == 1) ||
				(s.isSourcePathOwner() && value == 2) ||
				(s.isResourceContainerOwner() && value == 3) ||
				(s.isResourceBundlePathOwner() && value == 4))
			{
				owners.put(name, s);
			}
		}
	}

	private void readAssets(final Object[] pool, final CompilationUnit u, final InputStream in) throws IOException
	{
		int size = readU32(in);
		if (size > 0)
		{
			final Map<String, AssetInfo> assets = new HashMap<String, AssetInfo>();

			PathResolver resolver = ThreadLocalToolkit.getPathResolver();

			for (int i = 0; i < size; i++)
			{
				String className = (String) pool[readU32(in)];
				String pathName = (String) pool[readU32(in)];

				VirtualFile f = null;
				if (pathName.length() == 0)
				{
					f = null;
				}
				else
				{
					f = resolver.resolve(pathName);
					if (f == null)
					{
						f = new DeletedFile(pathName);
					}
				}

				assets.put(className, new AssetInfo(null, f, readLong(in), null));
			}

			int swfSize = readU32(in);
			SizeLimitingInputStream in2 = new SizeLimitingInputStream(in, swfSize);

			Movie movie = new Movie();
			MovieDecoder movieDecoder = new MovieDecoder(movie);
			TagDecoder tagDecoder = new TagDecoder(in2);
			tagDecoder.parse(movieDecoder);

			// For some reason, sometimes the process of decoding the movie does not read
			// all that bytes that had been written previously.  So, skip to the end.
			in2.skipToEnd();

			for (Frame frame : movie.frames)
            {
			    for (Entry<String, Tag> e : frame.symbolClass.class2tag.entrySet())
                {
					String className = e.getKey();
					DefineTag tag = (DefineTag) e.getValue();
					AssetInfo assetInfo = assets.get(className);
					assetInfo.setDefineTag(tag);

					u.getAssets().add(className, assetInfo);

                    // We special case DefineFont tags so that the FontManager 
					// can cache them and avoid re-creating them on subsequent
                    // compiles.
                    if (fontManager != null && tag instanceof DefineFont)
                    {
                        VirtualFile f = assetInfo.getPath();
                        String path = null;
                        if (f != null)
                        {
                            path = f.getURL();
                        }

                        fontManager.loadDefineFont((DefineFont)tag, path);
                    }
				}
			}
		}
	}

	// Methods for adding constant pool entries

	private int addObject(Map<Object, Integer> pool, Object obj)
	{
		assert obj != null;

		Integer index = pool.get(obj);

		if (index == null)
		{
			index = IntegerPool.getNumber(pool.size());
			pool.put(obj, index);
		}

		return index.intValue();
	}

	private int addBytes(Map<Object, Integer> pool, byte[] b)
	{
		return addObject(pool, b);
	}

	private int addString(Map<Object, Integer> pool, String s)
	{
		return addObject(pool, s);
	}

	private int addStrings(Map<Object, Integer> pool, String[] array)
	{
		assert array != null;

		key.a1 = array;
		Integer index = pool.get(key);

		if (index == null)
		{
			for (int i = 0, size = array.length; i < size; i++)
			{
				addString(pool, array[i]);
			}

			index = IntegerPool.getNumber(pool.size());
			pool.put(new ArrayKey(array), index);
		}

		return index.intValue();
	}

	private int addQName(Map<Object, Integer> pool, QName qName)
	{
		assert qName != null;

		Integer index = pool.get(qName);

		if (index == null)
		{
			addString(pool, qName.getNamespace());
			addString(pool, qName.getLocalPart());

			index = IntegerPool.getNumber(pool.size());
			pool.put(qName, index);
		}

		return index.intValue();
	}

	private int addMultiName(Map<Object, Integer> pool, MultiName multiName)
	{
		assert multiName != null;

		Integer index = pool.get(multiName);

		if (index == null)
		{
			addStrings(pool, multiName.namespaceURI);
			addString(pool, multiName.localPart);

			index = IntegerPool.getNumber(pool.size());
			pool.put(multiName, index);
		}

		return index.intValue();
	}

	/*
    private int addMetaData(Map pool, flex2.compiler.abc.MetaData md)
	{
		assert md != null;

		Integer index = (Integer) pool.get(md);

		if (index == null)
		{
			addString(pool, md.getID());
			for (int j = 0, count = md.count(); j < count; j++)
			{
				String key = md.getKey(j);
				String val = md.getValue(j);

				addString(pool, key == null ? "" : key);
				addString(pool, val);
			}

			index = IntegerPool.getNumber(pool.size());
			pool.put(md, index);
		}

		return index.intValue();
	}
    */

	// Low-level encoding methods

	private void writeBytes(OutputStream out, byte[] b) throws IOException
	{
		out.write(b);
	}

	private void writeLong(OutputStream out, long num) throws IOException
	{
		out.write((int) (num >>> 56) & 0xFF);
		out.write((int) (num >>> 48) & 0xFF);
		out.write((int) (num >>> 40) & 0xFF);
		out.write((int) (num >>> 32) & 0xFF);
		out.write((int) (num >>> 24) & 0xFF);
		out.write((int) (num >>> 16) & 0xFF);
		out.write((int) (num >>>  8) & 0xFF);
		out.write((int)  num         & 0xFF);
	}

	private void writeU32(OutputStream out, int num) throws IOException
	{
		out.write((num >>> 24) & 0xFF);
		out.write((num >>> 16) & 0xFF);
		out.write((num >>>  8) & 0xFF);
		out.write( num         & 0xFF);
	}

	private void writeU8(OutputStream out, int num) throws IOException
	{
		out.write(num & 0xFF);
	}

	private byte[] readBytes(int length) throws IOException
	{
		byte[] b = new byte[length];
		file.readFully(b);
		return b;
	}

	private int readU32() throws IOException
	{
		return file.readInt();
	}

	private int readU8() throws IOException
	{
		return file.read();
	}

	private byte[] readBytes(InputStream in, int length) throws IOException
	{
		byte[] b = new byte[length];

		for (int size = 0, start = 0, len = length - size; (size = in.read(b, start, len)) != -1 && start + size < length;)
		{
			start += size;
			len -= size;
		}

		return b;
	}

	private long readLong() throws IOException
	{
		return ((long) (readU32()) << 32) + (readU32() & 0xFFFFFFFFL);
	}
	
	private long readLong(InputStream in) throws IOException
	{
		return ((long) (readU32(in)) << 32) + (readU32(in) & 0xFFFFFFFFL);
	}

	private int readU32(InputStream in) throws IOException
	{
		return ((in.read() << 24) + (in.read() << 16) + (in.read() << 8) + in.read());
	}

	private int readU8(InputStream in) throws IOException
	{
		return in.read();
	}

	// Helper classes

	private class ArrayKey
	{
		ArrayKey()
		{
		}

		ArrayKey(String[] array)
		{
			a1 = array;
		}

		private String[] a1;

		@Override
		public boolean equals(Object obj)
		{
			if (obj == this)
			{
				return true;
			}
			else if (obj instanceof ArrayKey)
			{
				String[] a2 = ((ArrayKey) obj).a1;

				if (a1 == a2)
				{
					return true;
				}

				if (a1.length != a2.length)
				{
					return false;
				}

				for (int i = 0, size = a1.length; i < size; i++)
				{
					if (!a1[i].equals(a2[i]))
					{
						return false;
					}
				}

				return true;
			}
			else
			{
				return false;
			}
		}

		@Override
		public int hashCode()
		{
			int c = 0;
			for (int i = 0, size = a1.length; i < size; i++)
			{
				c = (i == 0) ? a1[i].hashCode() : c ^ a1[i].hashCode();
			}
			return c;
		}
	}

	public final class MetaData implements flex2.compiler.abc.MetaData
	{
		public MetaData(String id, int count)
		{
			this.id = id;
			this.keys = new String[count];
			this.values = new String[count];
		}

		private String id;
		private String[] keys;
		private String[] values;

		public String getID()
		{
			return id;
		}

		public void setValue(int index, String value)
		{
			values[index] = value;
		}

		public void setKeyValue(int index, String key, String value)
		{
			keys[index] = key;
			values[index] = value;
		}

		public String getKey(int index)
		{
			if (index < 0 || index >= count())
			{
				throw new ArrayIndexOutOfBoundsException();
			}
			else
			{
				return keys[index];
			}
		}

		public String getValue(String key)
		{
			for (int i = 0, length = count(); i < length; i++)
			{
				if (key.equals(keys[i]))
				{
					return values[i];
				}
			}
			return null;
		}

		public String getValue(int index)
		{
			if (index < 0 || index >= count())
			{
				throw new ArrayIndexOutOfBoundsException();
			}
			else
			{
				return values[index];
			}
		}

        public Map<String, String> getValueMap()
        {
            Map<String, String> result = new HashMap<String, String>();

			for (int i = 0, length = count(); i < length; i++)
			{
                result.put(keys[i], values[i]);
			}

			return result;
        }

		public int count()
		{
			return values != null ? values.length : 0;
		}
	}

	// error messages

	public static class ObsoleteCacheFileFormat extends CompilerMessage.CompilerInfo
	{
        private static final long serialVersionUID = -8594915455219662842L;

        public ObsoleteCacheFileFormat()
		{
			super();
		}
	}

	public static class NoFileSpec extends CompilerMessage.CompilerInfo
	{
        private static final long serialVersionUID = -5780228997078423591L;

        public NoFileSpec()
		{
			super();
		}
	}

	public static class NoSourceList extends CompilerMessage.CompilerInfo
	{
        private static final long serialVersionUID = 1489613684797688310L;

        public NoSourceList()
		{
			super();
		}
	}

	public static class NoSourcePath extends CompilerMessage.CompilerInfo
	{
        private static final long serialVersionUID = -4989314191998065597L;

        public NoSourcePath()
		{
			super();
		}
	}

	public static class NoResourceContainer extends CompilerMessage.CompilerInfo
	{
        private static final long serialVersionUID = -384784734412773490L;

        public NoResourceContainer()
		{
			super();
		}
	}
}
