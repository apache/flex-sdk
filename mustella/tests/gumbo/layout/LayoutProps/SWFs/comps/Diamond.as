////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package comps
{
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Rectangle;

import spark.primitives.Rect;
import flash.geom.Point;

public class Diamond extends Rect
{
    public function Diamond()
    {
        super();
        invalidateSize();
    }
    
    override protected function measure():void
    {
        super.measure();
        
        measuredX = - naturalWidth / 2;
        measuredY = - naturalHeight / 2;
        measuredWidth = naturalWidth;
        measuredHeight = naturalHeight; 
    }
    
    private var _naturalWidth:Number = 100;
    public function set naturalWidth(value:Number):void
    {
        _naturalWidth = Math.max(1, value);
    invalidateSize();
    }
    public function get naturalWidth():Number
    {
        return _naturalWidth;
    }

    private var _naturalHeight:Number = 100;
    public function set naturalHeight(value:Number):void
    {
        _naturalHeight = Math.max(1, value);
        invalidateSize();
    }
    public function get naturalHeight():Number
    {
        return _naturalHeight;
    }
    
    private var _drawCircle:Boolean = false;
    
    public function get drawCircle():Boolean
    {
            return _drawCircle;
    }
    
    public function setDrawCircle(draw:Boolean, invalidate:Boolean):void
    {
        _drawCircle = draw;
        
        if(invalidate)
        {
            invalidateDisplayList();
        }
    }
    
    override protected function canSkipMeasurement():Boolean
    {
        return false;
    }
    
    override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
        //trace("StrokedElement.updateDisplayList w",unscaledWidth,"h",unscaledHeight,"drawnDisplayObject",drawnDisplayObject,"this",this);                                                     
        if (!drawnDisplayObject || !(drawnDisplayObject is Sprite))
            return;
            
        var g:Graphics = (drawnDisplayObject as Sprite).graphics;

        // We only clear if we have a displayObject. This handles the case of having our own displayObject and the 
        // case when we have a mask and have created a _drawnDisplayObject. We don't want to clear if we are 
        // sharing a display object. 
        if (displayObject)
            g.clear();

        // Don't call super.beginDraw() since it will also set up an 
        // invisible fill.
        
        var bounds:Rectangle = new Rectangle(drawX, drawY, width, height);
        if (stroke)
            stroke.apply(g, bounds, new Point(bounds.x, bounds.y));
        else
            g.lineStyle();
        
        if (fill)
            fill.begin(g, bounds, new Point(bounds.x, bounds.y));
            
        
        var left:Number = drawX + measuredX;    
        var top:Number = drawY + measuredY;
        var right:Number = left + unscaledWidth;
        var bottom:Number = top + unscaledHeight;
            
        g.moveTo(left, (top + bottom) / 2 );
        g.lineTo((left + right) / 2 , top);
        g.lineTo(right, (top + bottom) / 2);
        g.lineTo((left + right) / 2 , bottom);
        g.lineTo(left, (top + bottom) / 2 );

        if (fill)
            fill.end(g);
            
        if (drawCircle)
        {
            g.drawCircle((left + right)/2, (top + bottom)/2, Math.min((left+right)/2, (top+bottom)/2));
        }
    }
}
    
}
