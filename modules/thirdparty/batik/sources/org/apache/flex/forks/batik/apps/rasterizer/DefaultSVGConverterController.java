/*

   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.apache.flex.forks.batik.apps.rasterizer;

import java.io.File;
import java.util.Map;
import java.util.List;

import org.apache.flex.forks.batik.transcoder.Transcoder;

/**
 * Default controller for the
 * <tt>SVGConverter</tt> operation.
 *
 * @author <a href="mailto:vhardy@apache.org">Vincent Hardy</a>
 * @version $Id: DefaultSVGConverterController.java 489226 2006-12-21 00:05:36Z cam $
 */
public class DefaultSVGConverterController implements SVGConverterController {
    /**
     * Invoked when the rasterizer has computed the
     * exact description of what it should do. The controller
     * should return true if the transcoding process should
     * proceed or false otherwise.
     *
     * @param transcoder Transcoder which will be used for the conversion
     * @param hints set of hints that were set on the transcoder
     * @param sources list of SVG sources it will convert.
     * @param dest list of destination file it will use
     */
    public boolean proceedWithComputedTask(Transcoder transcoder,
                                           Map hints,
                                           List sources,
                                           List dest){
        return true;
    }

    /**
     * Invoked when the rasterizer is about to start transcoding
     * of a given source.
     * The controller should return true if the source should be
     * transcoded and false otherwise.
     */
    public boolean proceedWithSourceTranscoding(SVGConverterSource source,
                                                File dest) {
        System.out.println("About to transcoder source of type: " + source.getClass().getName());
        return true;
    }

    /**
     * Invoked when the rasterizer got an error while
     * transcoding the input source.
     * The controller should return true if the transcoding process
     * should continue on other sources and it should return false
     * if it should not.
     *
     * @param errorCode see the {@link SVGConverter} error code descriptions.
     */
    public boolean proceedOnSourceTranscodingFailure(SVGConverterSource source,
                                                     File dest,
                                                     String errorCode){
        return true;
    }

    /**
     * Invoked when the rasterizer successfully transcoded
     * the input source.
     */
    public void onSourceTranscodingSuccess(SVGConverterSource source,
                                           File dest){
    }
}