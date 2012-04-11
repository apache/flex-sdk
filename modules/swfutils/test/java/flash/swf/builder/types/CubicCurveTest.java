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

package flash.swf.builder.types;

import junit.framework.TestCase;
import flash.swf.Frame;
import flash.swf.Movie;
import flash.swf.MovieEncoder;
import flash.swf.SwfUtils;
import flash.swf.Tag;
import flash.swf.TagEncoder;
import flash.swf.tags.DefineShape;
import flash.swf.tags.PlaceObject;
import flash.swf.tags.SetBackgroundColor;
import flash.swf.types.FillStyle;
import flash.swf.types.Matrix;
import flash.swf.types.Rect;
import flash.swf.types.Shape;
import flash.swf.types.ShapeWithStyle;

import java.awt.geom.Ellipse2D;
import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;

/**
 * A simple test for Cubic to Quadratic conversion of beziers that is required for
 * non-True Type Fonts. This sample uses a simple circle from Java AWT's Ellipse2D.
 *
 * @author Peter Farland
 */
public class CubicCurveTest extends TestCase
{
    public CubicCurveTest(String test)
    {
        super(test);
    }

    protected void setUp() throws Exception
    {
    }

    protected void tearDown() throws Exception
    {
    }

    public void testCubic() throws Exception
    {
        //Run the test.
        File file = File.createTempFile("cubiccurvetest", "swf", null);
        file.deleteOnExit();
        FileOutputStream fos = new FileOutputStream(file);

        try
        {
            //Build a new circle to test curves
            ShapeBuilder builder = new ShapeBuilder();
            builder.setCurrentFillStyle0(1);

            long start = System.currentTimeMillis();
            Ellipse2D ellipse = new Ellipse2D.Double(0, 0, 5000, 5000);
            builder.processShape(new PathIteratorWrapper(ellipse.getPathIterator(null)));
            //System.out.println("Created shape in: " + (System.currentTimeMillis() - start) + " ms.");

            Shape shape = builder.build();
            assertTrue("Incorrect no. of Shape Records: " + shape.shapeRecords.size(), shape.shapeRecords.size() == 17); //16 quadratic curves + 1 style change record

            //Build valid SWF DefineShape tag
            ShapeWithStyle sws = new ShapeWithStyle();
            sws.shapeRecords = shape.shapeRecords;
            sws.linestyles = new ArrayList();
            sws.fillstyles = new ArrayList();
            sws.fillstyles.add(new FillStyle(SwfUtils.colorToInt(0, 0, 200, 255)));
            DefineShape tag = new DefineShape(Tag.stagDefineShape3);
            tag.bounds = new Rect(250 * 20, 250 * 20);
            tag.shapeWithStyle = sws;

            //Create a SWF Movie shell
            Movie m = getMovie(1);
            Frame frame1 = (Frame)m.frames.get(0);
            Matrix mt = new Matrix(0, 0);
            frame1.controlTags.add(new PlaceObject(mt, tag, 1, null));

            //Compile SWF
            TagEncoder tagEncoder = new TagEncoder();
            MovieEncoder movieEncoder = new MovieEncoder(tagEncoder);
            movieEncoder.export(m);

            //Write to file
            tagEncoder.writeTo(fos);
        }
        finally
        {
            fos.close();
        }
    }

    protected void runTest() throws Throwable
    {
        setUp();

        testCubic();

        tearDown();
    }

    public static void main(String[] args) throws Exception
    {
        CubicCurveTest test = new CubicCurveTest("Cubic Curve Test");
        try
        {
            test.runTest();
        }
        catch (Throwable t)
        {
            t.printStackTrace();
        }
    }

    private static Movie getMovie(int frameCount)
    {
        Movie m = new Movie();
        m.version = 7;
        m.bgcolor = new SetBackgroundColor(SwfUtils.colorToInt(255, 255, 255));
        m.framerate = 12;
        m.frames = new ArrayList(frameCount);
        m.frames.add(new Frame());
        m.size = new Rect(11000, 8000);
        return m;
    }
}

