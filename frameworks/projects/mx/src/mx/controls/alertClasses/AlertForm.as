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

package mx.controls.alertClasses
{

import flash.display.DisplayObject;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextLineMetrics;
import flash.ui.Keyboard;
import mx.controls.Alert;
import mx.controls.Button;
import mx.core.IFlexModuleFactory;
import mx.core.IFontContextComponent;
import mx.core.mx_internal;
import mx.core.IUITextField;
import mx.core.UIComponent;
import mx.core.UITextField;
import mx.events.CloseEvent;
import mx.managers.IActiveWindowManager;
import mx.managers.IFocusManagerContainer;
import mx.managers.ISystemManager;
import mx.managers.PopUpManager;

use namespace mx_internal;

include "../../styles/metadata/LeadingStyle.as"
include "../../styles/metadata/TextStyles.as"

[ExcludeClass]

/**
 *  @private
 *  The AlertForm control exists within the Alert control, and contains
 *  messages, buttons, and, optionally, an icon. It is not intended for
 *  direct use by application developers.
 *
 *  @see mx.controls.TextArea
 *  @see mx.controls.Alert
 *  @see mx.controls.Button
 */
public class AlertForm extends UIComponent implements IFontContextComponent
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
	public function AlertForm()
	{
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  The UITextField that displays the text of the Alert control.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	mx_internal var textField:IUITextField;

	/**
	 *  @private
	 *  Width of the text object.
	 */
	private var textWidth:Number;

	/**
	 *  @private
	 *  Height of the text object.
	 */
	private var textHeight:Number;

	/**
	 *  The DisplayObject that displays the icon.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	private var icon:DisplayObject;

    /**
     *  An Array that contains any Buttons appearing in the Alert control.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
	mx_internal var buttons:Array = [];

	/**
	 *  @private
	 */
	mx_internal var defaultButton:Button;

	/**
	 *  @private
	 */
	private var defaultButtonChanged:Boolean = false;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  fontContext
    //----------------------------------
    
    /**
     *  @private
     */
    public function get fontContext():IFlexModuleFactory
    {
        return moduleFactory;
    }

    /**
     *  @private
     */
    public function set fontContext(moduleFactory:IFlexModuleFactory):void
    {
        this.moduleFactory = moduleFactory;
    }
    
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------

	/**
 	 *  @private
	 */
	override protected function createChildren():void
	{
		super.createChildren();

		// Create the UITextField to display the message.
		createTextField(-1);

		// Create the icon object, if any.
		var iconClass:Class = Alert(parent).iconClass;
		if (iconClass && !icon)
		{
			icon = new iconClass();
			addChild(icon);
		}

		// Create the button objects

		var alert:Alert = Alert(parent);
		
		var buttonFlags:uint = alert.buttonFlags;
		var defaultButtonFlag:uint = alert.defaultButtonFlag;

		var label:String;
		var button:Button;

		if (buttonFlags & Alert.OK)
		{
			label = String(Alert.okLabel);
			button = createButton(label, "OK");
			if (defaultButtonFlag == Alert.OK)
				defaultButton = button;
		}

		if (buttonFlags & Alert.YES)
		{
			label = String(Alert.yesLabel);
			button = createButton(label, "YES");
			if (defaultButtonFlag == Alert.YES)
				defaultButton = button;
		}

		if (buttonFlags & Alert.NO)
		{
			label = String(Alert.noLabel);
			button = createButton(label, "NO");
			if (defaultButtonFlag == Alert.NO)
				defaultButton = button;
		}

		if (buttonFlags & Alert.CANCEL)
		{
			label = String(Alert.cancelLabel);
			button = createButton(label, "CANCEL");
			if (defaultButtonFlag == Alert.CANCEL)
				defaultButton = button;
		}

		if (!defaultButton && buttons.length)
			defaultButton = buttons[0];

		// Set the default button to have focus.
		if (defaultButton)
		{
			defaultButtonChanged = true;
			invalidateProperties();
		}
	}

	/**
	 *  @private
	 */
	override protected function commitProperties():void
	{
		super.commitProperties();

        // if the font changed and we already created the label, we will need to 
        // destory it so it can be re-created, possibly in a different swf context.
        if (hasFontContextChanged() && textField != null)
        {
        	var index:int = getChildIndex(DisplayObject(textField));
			removeTextField();
			createTextField(index);
        }
 
		if (defaultButtonChanged && defaultButton)
		{
			defaultButtonChanged = false;

			Alert(parent).defaultButton = defaultButton;

			if (parent is IFocusManagerContainer)
			{
				var sm:ISystemManager = Alert(parent).systemManager;
				var awm:IActiveWindowManager = 
					IActiveWindowManager(sm.getImplementation("mx.managers::IActiveWindowManager"));
				if (awm)
           			awm.activate(IFocusManagerContainer(parent));
			}
			defaultButton.setFocus();
		}
	}

	/**
	 *  @private
	 */
	override protected function measure():void
	{
		super.measure();

		// Get the width of the title text
		var title:String = Alert(parent).title;
		var lineMetrics:TextLineMetrics =
			Alert(parent).getTitleTextField().
			getUITextFormat().measureText(title);

		// Calculate the width based solely on the title and the buttons
		var numButtons:int = Math.max(buttons.length, 2);
		var buttonWidth:Number = numButtons * buttons[0].width +
								 (numButtons - 1) * 8;
		var buttonAndTitleWidth:Number = Math.max(buttonWidth,
												  lineMetrics.width);
		// Set the textField to word-wrap if the text is more
		// than twice as wide as the buttons and title
		textField.width = 2 * buttonAndTitleWidth;
		textWidth = textField.textWidth + UITextField.TEXT_WIDTH_PADDING;

		// Window is wider of buttons or text, but not more than twice as
		// wide as buttons.
		var prefWidth:Number = Math.max(buttonAndTitleWidth, textWidth);
		prefWidth = Math.min(prefWidth, 2 * buttonAndTitleWidth);

		// Need this because TextField likes to use multiple lines
		// even for single words.
		if (textWidth < prefWidth && textField.multiline == true)
		{
			textField.multiline = false;
			textField.wordWrap = false;
		}
		else if (textField.multiline == false)
		{
			textField.wordWrap = true;
			textField.multiline = true;
		}

		// Add space for 8-pixel padding along the left/right.
		prefWidth += 16;
		// Add space for icon, if any.
		if (icon)
			prefWidth += icon.width + 8;

		// Make height tall enough for text and icon.
		textHeight = textField.textHeight + UITextField.TEXT_HEIGHT_PADDING;
		var prefHeight:Number = textHeight;

		if (icon)
			prefHeight = Math.max(prefHeight, icon.height);

		// Limit the height if it exceeds the height of the Stage.
		prefHeight = Math.min(prefHeight, screen.height * 0.75);
		
		// Add space for buttons, spacing between buttons and text,
		// and top/bottom margins
		prefHeight += buttons[0].height + (3 * 8);

		measuredWidth = prefWidth;
		measuredHeight = prefHeight;
	}

	/**
	 *  @private
	 */
	override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		var newX:Number;
		var newY:Number;
		var newWidth:Number;

		// Layout buttons first.
		newY = unscaledHeight - buttons[0].height;
		newWidth = buttons.length * (buttons[0].width + 8) - 8;

		// Center the buttons.
		newX = Math.round((unscaledWidth - newWidth) / 2);
		for (var i:int = 0; i < buttons.length; i++)
		{
			buttons[i].move(newX, newY);
			buttons[i].tabIndex = i + 1;
			newX += buttons[i].width + 8;
		}

		// Get the width of the text and icon together.
		newWidth = textWidth;
		if (icon)
			newWidth += icon.width + 8;

		// Center the text and icon horizontally and vertically.
		newX = Math.round((unscaledWidth - newWidth) / 2);
		if (icon)
		{
			icon.x = newX;
			icon.y = (newY - icon.height) / 2;
			newX += icon.width + 8;
		}

		var newHeight:Number = textField.getExplicitOrMeasuredHeight();
		var paddingTop:Number = textField.getStyle("paddingTop");
		var paddingBottom:Number = textField.getStyle("paddingBottom");
		var maxHeight:Number = unscaledHeight - buttons[0].height
			- paddingTop - paddingBottom;
		
		if (newHeight > maxHeight)
			newHeight = maxHeight;
		
		// try and make at least one line of text show even if it overlapps buttons
		// this may occur if the height of alert box is set to be too small
		var lineMetrics:TextLineMetrics = textField.getUITextFormat().measureText(textField.text);
		if (newHeight < lineMetrics.height)
			newHeight = lineMetrics.height;
		
		textField.move(newX, Math.round((newY - newHeight) / 2));
		textField.setActualSize(textWidth+5, newHeight);
	}

    /**
     *  @private
     */
	override public function styleChanged(styleProp:String):void
	{
		super.styleChanged(styleProp);

		if (!styleProp ||
			styleProp == "styleName" ||
			styleProp == "buttonStyleName")
		{
			if (buttons)
			{
				var buttonStyleName:String = getStyle("buttonStyleName");

				var n:int = buttons.length;
				for (var i:int = 0; i < n; i++)
				{
					buttons[i].styleName = buttonStyleName;
				}
			}
		}
	}

	/**
	 *  @private
	 *  Updates the button labels.
	 */
	override protected function resourcesChanged():void
	{
		super.resourcesChanged();

		var b:Button;
		
		b = Button(getChildByName("OK"));
		if (b)
			b.label = String(Alert.okLabel);
		
		b = Button(getChildByName("CANCEL"));
		if (b)
			b.label = String(Alert.cancelLabel);
		
		b = Button(getChildByName("YES"));
		if (b)
			b.label = String(Alert.yesLabel);
		
		b = Button(getChildByName("NO"));
		if (b)
			b.label = String(Alert.noLabel);
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     *  Creates the title text field child
	 *  and adds it as a child of this component.
     * 
     *  @param childIndex The index of where to add the child.
	 *  If -1, the text field isappended to the end of the list.
     */
    mx_internal function createTextField(childIndex:int):void
    {
        if (!textField)
        {
			textField = IUITextField(createInFontContext(UITextField));

			textField.styleName = this;
			textField.text = Alert(parent).text;
			textField.multiline = true;
			textField.wordWrap = true;
			textField.selectable = true;

            if (childIndex == -1)
                addChild(DisplayObject(textField));
            else 
                addChildAt(DisplayObject(textField), childIndex);
        }
    }

    /**
     *  @private
     *  Removes the title text field from this component.
     */
    mx_internal function removeTextField():void
    {
        if (textField)
        {
            removeChild(DisplayObject(textField));
            textField = null;
        }
    }

    /**
     *  @private
     */
	private function createButton(label:String, name:String):Button
	{
		var button:Button = new Button();

		button.label = label;

		// The name is "YES", "NO", "OK", or "CANCEL".
		button.name = name;

		var buttonStyleName:String = getStyle("buttonStyleName");
		if (buttonStyleName)
			button.styleName = buttonStyleName;

		button.addEventListener(MouseEvent.CLICK, clickHandler);
		button.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
        button.owner = parent;
		addChild(button);

		button.setActualSize(Alert.buttonWidth, Alert.buttonHeight);

		buttons.push(button);

		return button;
	}

    /**
     *  @private
     *  Remove the popup and dispatch Click event corresponding to the Button Pressed.
     */
	private function removeAlert(buttonPressed:String):void
	{
		var alert:Alert = Alert(parent);

		alert.visible = false;

		var closeEvent:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
		if (buttonPressed == "YES")
			closeEvent.detail = Alert.YES;
		else if (buttonPressed == "NO")
			closeEvent.detail = Alert.NO;
		else if (buttonPressed == "OK")
			closeEvent.detail = Alert.OK;
		else if (buttonPressed == "CANCEL")
			closeEvent.detail = Alert.CANCEL;
		alert.dispatchEvent(closeEvent);

		mx.managers.PopUpManager.removePopUp(alert);

	}

	//--------------------------------------------------------------------------
	//
	//  Overridden event handlers: UIComponent
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function keyDownHandler(event:KeyboardEvent):void
	{
		var buttonFlags:uint = Alert(parent).buttonFlags;

		if (event.keyCode == Keyboard.ESCAPE)
		{
			if ((buttonFlags & Alert.CANCEL) || !(buttonFlags & Alert.NO))
				removeAlert("CANCEL");
			else if (buttonFlags & Alert.NO)
				removeAlert("NO");
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

    /**
     *  @private
     *  On a button click, dismiss the popup and send notification.
     */
	private function clickHandler(event:MouseEvent):void
	{
		var name:String = Button(event.currentTarget).name;
		removeAlert(name);
	}
}

}
