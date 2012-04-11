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

import flex2.compiler.util.CompilerMessage;

/**
 * Exception to be used when there's a problem in a Transcoder class
 * rather than using ThreadLocalToolkit.logError().  This allows for
 * delegation of transcoders.
 *
 * Note: path was removed because not all transcoding calls contain a
 * source, and we really want to report the error in transcoding in
 * the context of the calling source code, not as if the transcoded
 * object owned itself.  (I.e. a failure to transcode a nonexistent
 * file should be reported via the AS embed line, not the missing
 * asset file.)
 *
 * Notenote: origin/line re-added, won't be fed by the transcoder, but
 * post-filled-in by the handler.  Kind of weird, but will make L10N
 * easier, I think.  --rg
 *
 * @author Brian Deitte
 */
public class TranscoderException extends CompilerMessage.CompilerError implements ILocalizableMessage
{
    private static final long serialVersionUID = -4639291193519001900L;

    public TranscoderException()
    {
    }

    public static class UnrecognizedExtension extends TranscoderException
    {
        private static final long serialVersionUID = -1402887623637672383L;
        public UnrecognizedExtension( String source )
        {
            this.source = source;
        }
        public String source;
    }

    public static class NoMatchingTranscoder extends TranscoderException
    {
        private static final long serialVersionUID = -2606401667671918751L;
        public NoMatchingTranscoder( String mimeType )
        {
            this.mimeType = mimeType;
        }
        public String mimeType;
    }

    public static class NoAssociatedClass extends TranscoderException
    {
        private static final long serialVersionUID = 6347969168361169999L;
        public NoAssociatedClass( String tag, String transcoder )
        {
            this.tag = tag;
            this.transcoder = transcoder;
        }
        public String tag;
        public String transcoder;
    }
}
