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

package mx.core
{

/**
 *  TextFieldAsset is a subclass of the flash.text.TextField class
 *  which represents TextField symbols that you embed in a Flex
 *  application from a SWF file produced by Flash.
 *  It implements the IFlexDisplayObject interface, which makes it
 *  possible for a TextFieldAsset to be displayed in an Image control,
 *  or to be used as a container background or a component skin.
 *
 *  <p>This class is included in Flex for completeness, so that any kind
 *  of symbol in a SWF file produced by Flash can be embedded
 *  in a Flex application.
 *  However, Flex applications do not typically use embedded TextFields.
 *  Refer to more commonly-used asset classes such as BitmapAsset
 *  for more information about how embedded assets work in Flex.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class TextFieldAsset extends FlexTextField
                            implements IFlexAsset, IFlexDisplayObject
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function TextFieldAsset()
    {
        super();

        // Remember initial size as our measured size.
        _measuredWidth = width;
        _measuredHeight = height;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  measuredHeight
    //----------------------------------

    /**
     *  @private
     *  Storage for the measuredHeight property.
     */
    private var _measuredHeight:Number;

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get measuredHeight():Number
    {
        return _measuredHeight;
    }

    //----------------------------------
    //  measuredWidth
    //----------------------------------

    /**
     *  @private
     *  Storage for the measuredWidth property.
     */
    private var _measuredWidth:Number;

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function get measuredWidth():Number
    {
        return _measuredWidth;
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function move(x:Number, y:Number):void
    {
        this.x = x;
        this.y = y;
    }

    /**
     *  @inheritDoc
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function setActualSize(newWidth:Number, newHeight:Number):void
    {
        width = newWidth;
        height = newHeight;
    }
}

}
