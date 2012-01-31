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

package mx.controls.buttonBarClasses
{

import mx.controls.Button;
import mx.core.UITextFormat;
import mx.core.mx_internal;

use namespace mx_internal;

[ExcludeClass]

/**
 *  @private
 *  The ButtonBarButton class is for internal use.
 */
public class ButtonBarButton extends Button
{
	include "../../core/Version.as";

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
    public function ButtonBarButton()
    {
        super();
    }

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     */
    private var inLayoutContents:Boolean = false;

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: UIComponent
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function determineTextFormatFromStyles():UITextFormat
    {
        if (inLayoutContents && selected)
            return textField.getUITextFormat();
        else
            return super.determineTextFormatFromStyles();
    }

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Button
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     */
    override mx_internal function layoutContents(unscaledWidth:Number,
												 unscaledHeight:Number,
												 offset:Boolean):void
    {
        // Fix for bug 122684:
        // layoutContents() internally calls measureText(), which calls
        // determineTextFormatFromStyles() to get the UITextFormat object.
        // For a selected button, the textField's text styles can differ from
        // the button's text styles. So we need to return the right
        // UITextFormat in determineTextFormatFromStyles()
        inLayoutContents = true;
        super.layoutContents(unscaledWidth, unscaledHeight, offset);
        inLayoutContents = false;
    }
}

}
