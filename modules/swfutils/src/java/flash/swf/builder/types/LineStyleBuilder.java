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

import flash.swf.types.LineStyle;
import flash.swf.SwfConstants;
import flash.swf.SwfUtils;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Paint;
import java.awt.Stroke;

/**
 * This class is used to construct a LineStyle from a Paint and Stroke
 * object.
 *
 * @author Peter Farland
 */
public final class LineStyleBuilder
{
    private LineStyleBuilder()
    {
    }

    public static LineStyle build(Paint paint, Stroke thickness)
    {
        LineStyle ls = new LineStyle();

        if (paint != null && paint instanceof Color)
            ls.color = SwfUtils.colorToInt((Color)paint);

        if (thickness != null && thickness instanceof BasicStroke)
            ls.width = (int)(Math.rint(((BasicStroke)thickness).getLineWidth() * SwfConstants.TWIPS_PER_PIXEL));

        return ls;
    }
}
