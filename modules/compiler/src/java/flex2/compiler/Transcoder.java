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

import flash.swf.tags.DefineTag;
import flex2.compiler.common.PathResolver;
import flex2.compiler.io.VirtualFile;

import java.util.List;
import java.util.Map;

/**
 * Interface for transcoding resources which are used in Embed.
 *
 * @author Clement Wong
 */
public interface Transcoder
{
	/**
	 * If this transcoder can process the specified file, return true.
	 */
	boolean isSupported(String mimeType);

	/**
	 * Read the media file and create DefineTag
	 */
    TranscodingResults transcode(PathResolver context, SymbolTable symbolTable,
                                 Map<String, Object> args, String className, boolean generateSource)
        throws TranscoderException;

    /**
     * Returns class that should be extended with given DefineTag for this transcoder
     */
    String getAssociatedClass(DefineTag tag);

    /**
     * Clears the caches associated with this transcoder after a compilation.
     */
    void clear();

    String FILE = "_file";
    String PATHSEP = "_pathsep";
    String LINE = "_line";
    String COLUMN = "_column";
    String SOURCE = "source";
    String SYMBOL = "symbol";
    String NEWNAME = "exportSymbol";
    String MIMETYPE = "mimeType";
    String RESOLVED_SOURCE = "_resolvedSource";
    String ORIGINAL = "original";
    String SKINCLASS = "skinClass";

    /**
     * Value object used to pass the results of a transcoding from the
     * transcoder back to the caller.
     */
    public class TranscodingResults
    {
        public TranscodingResults() {}
        public TranscodingResults( VirtualFile assetSource )
        {
            this.assetSource = assetSource;
            this.modified = assetSource.getLastModified();
        }
        public DefineTag defineTag;
        public String generatedCode;
        public VirtualFile assetSource;
        public String className;
        public List<TranscodingResults> additionalAssets;
        public long modified;
        public boolean requireCodegen;
    }
}
