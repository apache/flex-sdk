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

package flex2.tools.oem.internal;

import flex2.compiler.TranscoderException;
import flex2.compiler.media.SkinTranscoder;
import flex2.tools.oem.Logger;

/**
 * Utility class related to embedded asset processing.  FB uses this
 * class.  The methods used by FB in flex2.compiler.as3.EmbedUtil
 * should have wrappers added here and FB should switch to using them.
 *
 * @version 3.0
 * @author Paul Reilly
 */
public class EmbedUtil
{
    /**
     * Generates the source code for an embedded skin.
     *
     * @param fullClassName The fully qualified class name in dot format.
     * @param baseClassName The base class for the embedded skin.
     * @param needsIBorder Whether IBorder needs to be implemented.
     * @param needsBorderMetrics Whether the borderMetrics property needs to be implemented.
     * @param needsIFlexDisplayObject Whether IFlexDisplayObject needs to be implemented.
     * @param needsMeasuredHeight Whether the measuredHeight property needs to be implemented.
     * @param needsMeasuredWidth Whether the measuredWidth property needs to be implemented.
     * @param needsMove Whether the move() function needs to be implemented.
     * @param needsSetActualSize Whether the setActualSize() function needs to be implemented.
     * @param flexMovieClipOrSprite Whether the base class is a MovieClip or Sprite.
     * @param logger The logger used to report transcoding exceptions.
     * @return The generated skin class.
     */
    public String generateSkinSource(String fullClassName,
                                     String baseClassName,
                                     boolean needsIBorder,
                                     boolean needsBorderMetrics,
                                     boolean needsIFlexDisplayObject,
                                     boolean needsMeasuredHeight,
                                     boolean needsMeasuredWidth,
                                     boolean needsMove,
                                     boolean needsSetActualSize,
                                     boolean flexMovieClipOrSprite,
                                     Logger logger)
    {
        String result = null;

        try
        {
            result = SkinTranscoder.generateSource(fullClassName, baseClassName, needsIBorder,
                                                   needsBorderMetrics, needsIFlexDisplayObject,
                                                   needsMeasuredHeight, needsMeasuredWidth,
                                                   needsMove, needsSetActualSize,
                                                   flexMovieClipOrSprite);
        }
        catch (TranscoderException transcoderException)
        {
            logger.log(transcoderException, -1, null);
        }

        return result;
    }
}