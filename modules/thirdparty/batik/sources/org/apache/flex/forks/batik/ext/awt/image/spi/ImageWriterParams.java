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
package org.apache.flex.forks.batik.ext.awt.image.spi;

/**
 * Parameters for the encoder which is accessed through the
 * ImageWriter interface.
 *
 * @version $Id: ImageWriterParams.java 582434 2007-10-06 02:11:51Z cam $
 */
public class ImageWriterParams {
    
    private Integer resolution;
    private Float jpegQuality;
    private Boolean jpegForceBaseline;
    private String compressionMethod;
    
    /**
     * Default constructor.
     */
    public ImageWriterParams() {
        //nop
    }

    /**
     * @return the image resolution in dpi, or null if undefined
     */
    public Integer getResolution() {
        return this.resolution;
    }
    
    /**
     * @return the quality value for encoding a JPEG image 
     *          (0.0-1.0), or null if undefined
     */
    public Float getJPEGQuality() {
        return this.jpegQuality;
    }
    
    /**
     * @return true if the baseline quantization table is forced, 
     *          or null if undefined.
     */
    public Boolean getJPEGForceBaseline() {
        return this.jpegForceBaseline;
    }
    
    /** @return the compression method for encoding the image */
    public String getCompressionMethod() {
        return this.compressionMethod;
    }
    
    /**
     * Sets the target resolution of the bitmap image to be written.
     * @param dpi the resolution in dpi
     */
    public void setResolution(int dpi) {
        this.resolution = new Integer(dpi);
    }
    
    /**
     * Sets the quality setting for encoding JPEG images.
     * @param quality the quality setting (0.0-1.0)
     * @param forceBaseline force baseline quantization table
     */
    public void setJPEGQuality(float quality, boolean forceBaseline) {
        this.jpegQuality = new Float(quality);
        this.jpegForceBaseline = forceBaseline?Boolean.TRUE:Boolean.FALSE;
    }
    
    /**
     * Set the compression method that shall be used to encode the image.
     * @param method the compression method
     */
    public void setCompressionMethod(String method) {
        this.compressionMethod = method;
    }
}
