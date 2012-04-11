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
package com.adobe.internal.fxg.util;

import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;

import flash.swf.Frame;
import flash.swf.Movie;
import flash.swf.MovieEncoder;
import flash.swf.SwfConstants;
import flash.swf.Tag;
import flash.swf.TagEncoder;
import flash.swf.tags.DefineSprite;
import flash.swf.tags.PlaceObject;
import flash.swf.types.Matrix;
import flash.swf.types.Rect;

/**
 * Utility class that allows writing out a DefineSprite to an Output Stream
 * 
 * @author Sujata Das
 */
public class SWFWriter
{
    private static final int DEFAULT_VERSION = 10;
    private static final int DEFAULT_FRAMERATE = 24;
    private static final int DEFAULT_WIDTH = 800;
    private static final int DEFAULT_HEIGHT = 800;
    private static final int DEFAULT_DEPTH = 1;
    
    int version = DEFAULT_VERSION;
    int framerate = DEFAULT_FRAMERATE;
    int width = DEFAULT_WIDTH;
    int height = DEFAULT_HEIGHT;
    int depth = DEFAULT_DEPTH;
    
    /**
     * Instantiates a new sWF writer.
     */
    public SWFWriter()
    {
    }

    /**
     * Instantiates a new sWF writer.
     * 
     * @param width the width
     * @param height the height
     */
    public SWFWriter(int width, int height)
    {
        this.width = width;
        this.height = height;
    }
    
    /**
     * Instantiates a new sWF writer.
     * 
     * @param width the width
     * @param height the height
     * @param version the version
     */
    public SWFWriter(int width, int height, int version)
    {
        this.width = width;
        this.height = height;
        this.version = version;
    }
    
    /**
     * Instantiates a new sWF writer.
     * 
     * @param width the width
     * @param height the height
     * @param version the version
     * @param framerate the framerate
     * @param depth the depth
     */
    public SWFWriter(int width, int height, int version, int framerate, int depth)
    {
        this.width = width;
        this.height = height;
        this.version = version;
        this.framerate = framerate;
        this.depth = depth;
    }

    /**
     * method that writes the sprite to output stream
     * 
     * @param sprite
     * @param fout
     * @throws IOException
     */
    public void writeToFile(DefineSprite sprite, OutputStream fout)
            throws IOException
    {
        Movie movie = new Movie();
        movie.version = version;
        movie.framerate = framerate;
        movie.width = width;
        movie.height = height;
        movie.size = new Rect(width * SwfConstants.TWIPS_PER_PIXEL, height * SwfConstants.TWIPS_PER_PIXEL); 

        Frame frame = new Frame();
        movie.frames = new ArrayList<Frame>();
        movie.frames.add(frame);

        PlaceObject po3 = new PlaceObject(Tag.stagPlaceObject3);
        po3.matrix = new Matrix();
        po3.setRef(sprite);
        po3.depth = depth;
        frame.controlTags.add(po3);

        TagEncoder tagEncoder = new TagEncoder();
        MovieEncoder movieEncoder = new MovieEncoder(tagEncoder);
        movieEncoder.export(movie);
        tagEncoder.writeTo(fout);

    }

}
