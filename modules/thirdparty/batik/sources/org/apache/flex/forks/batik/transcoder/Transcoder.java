/*

   Copyright 2000-2001  The Apache Software Foundation 

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.transcoder;

import java.util.Map;

/**
 * This class defines an API for transcoding.
 *
 * @author <a href="mailto:Thierry.Kormann@sophia.inria.fr">Thierry Kormann</a>
 * @version $Id: Transcoder.java,v 1.6 2004/08/18 07:15:41 vhardy Exp $
 */
public interface Transcoder {

    /**
     * Transcodes the specified input in the specified output.
     * @param input the input to transcode
     * @param output the ouput where to transcode
     * @exception TranscoderException if an error occured while transcoding
     */
    void transcode(TranscoderInput input, TranscoderOutput output)
            throws TranscoderException;

    /**
     * Returns the transcoding hints of this transcoder.
     */
    TranscodingHints getTranscodingHints();

    /**
     * Sets the value of a single preference for the transcoding process.
     * @param key the key of the hint to be set
     * @param value the value indicating preferences for the specified
     * hint category.
     */
    void addTranscodingHint(TranscodingHints.Key key, Object value);

    /**
     * Removes the value of a single preference for the transcoding process.
     * @param key the key of the hint to remove
     */
    void removeTranscodingHint(TranscodingHints.Key key);

    /**
     * Replaces the values of all preferences for the transcoding algorithms
     * with the specified hints.
     * @param hints the rendering hints to be set
     */
    void setTranscodingHints(Map hints);

    /**
     * Sets the values of all preferences for the transcoding algorithms
     * with the specified hints.
     * @param hints the rendering hints to be set
     */
    void setTranscodingHints(TranscodingHints hints);

    /**
     * Sets the error handler this transcoder may use to report
     * warnings and errors.
     * @param handler to ErrorHandler to use
     */
    void setErrorHandler(ErrorHandler handler);

    /**
     * Returns the error handler this transcoder uses to report
     * warnings and errors, or null if any.
     */
    ErrorHandler getErrorHandler();
}
