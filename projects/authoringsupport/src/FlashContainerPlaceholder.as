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

package
{
import flash.display.Shape;

import mx.controls.SWFLoader;
import mx.core.UIComponent;
import mx.flash.ContainerMovieClip;
import mx.flash.FlexContentHolder;

[IconFile("flash_container_icon_small.png")]
public class FlashContainerPlaceholder extends ContainerMovieClip
{
    protected var image1:SWFLoader;
    
    public function FlashContainerPlaceholder()
    {
        super();
        
        // 151, 151 is the size of the flex content holder image, 
        // so I'm going to make it that size by default.
        var shape:Shape = new Shape();
        shape.graphics.beginFill(0, 0);
        shape.graphics.drawRect(0, 0, 151, 151);
        shape.graphics.endFill();
        addChild(shape);

        var fch:FlexContentHolder = new MyFlexContentHolder();
        
        var imageHolder:UIComponent = new SimpleUIComponentContainer();
		imageHolder.percentHeight = 100;
		imageHolder.percentWidth = 100;
		imageHolder.addChild(createImage());

        this.addChild(fch);
        
        this.content = imageHolder;
    }
    
    protected function createImage():SWFLoader
    {
        image1 = new SWFLoader();
        image1.source = _embed_mxml_flash_container_icon_png;
        image1.scaleContent = false;
        image1.setStyle('horizontalAlign' , 'center');
        image1.setStyle('verticalAlign' , 'middle');
        return image1;            
    }
    
    override public function setActualSize(newWidth:Number, newHeight:Number):void
    {
        if (image1 != null) {
            if (newWidth < 128 || newHeight < 128)
                image1.scaleContent = true;
            else
                image1.scaleContent = false;
        }

        super.setActualSize(newWidth, newHeight);
    }

    [Embed(source='flash_container_icon.png')]
    private var _embed_mxml_flash_container_icon_png:Class;
}

}
import mx.core.UIComponent;

class SimpleUIComponentContainer extends UIComponent
{
	override protected function measure():void
	{
		super.measure();
		
		// we know we always have one child and it should take up the whole width/height
		var child:UIComponent = UIComponent(getChildAt(0));
		
		measuredWidth = child.getPreferredBoundsWidth();
		measuredHeight = child.getPreferredBoundsHeight();
	}
	
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		graphics.clear();
		
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		// draw border
		graphics.lineStyle(1, 0xCCCCCC);
		graphics.beginFill(0x000000, 0); // transparent fill for hit testing
		graphics.drawRect(0.5, 0.5, unscaledWidth - 1, unscaledHeight - 1); // adjust for stroke
		graphics.endFill();
		
		// position the one child.  we know we always have
		// only one child, and it's a SWFLoader.  To center it, 
		// we just need to set the width/height to take up the whole 
		// thing...the centering will happen inside of SWFLoader
		var child:UIComponent = UIComponent(getChildAt(0));

		child.setLayoutBoundsSize(unscaledWidth, unscaledHeight);
		child.setLayoutBoundsPosition(0, 0);
	}
}