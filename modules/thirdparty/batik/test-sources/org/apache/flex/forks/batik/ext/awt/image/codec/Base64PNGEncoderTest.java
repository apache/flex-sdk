/*

   Copyright 2001,2003  The Apache Software Foundation 

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
package org.apache.flex.forks.batik.ext.awt.image.codec;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;

import org.apache.flex.forks.batik.util.Base64DecodeStream;
import org.apache.flex.forks.batik.util.Base64EncoderStream;


/**
 * This test validates the PNGEncoder operation when combined with
 * Base64 encoding.
 *
 * @author <a href="mailto:vhardy@eng.sun.com">Vincent Hardy</a>
 * @version $Id: Base64PNGEncoderTest.java,v 1.4 2004/08/18 07:16:42 vhardy Exp $
 */
public class Base64PNGEncoderTest extends PNGEncoderTest {
    /**
     * Template method for building the PNG output stream
     */
    public OutputStream buildOutputStream(ByteArrayOutputStream bos){
        return new Base64EncoderStream(bos);
    }

    /**
     * Template method for building the PNG input stream
     */
    public InputStream buildInputStream(ByteArrayOutputStream bos){
        ByteArrayInputStream bis 
            = new ByteArrayInputStream(bos.toByteArray());

        return new Base64DecodeStream(bis);
    }
}
