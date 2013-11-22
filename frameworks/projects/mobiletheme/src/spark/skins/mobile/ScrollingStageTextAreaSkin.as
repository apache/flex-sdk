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

package spark.skins.mobile
{
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;

import spark.components.supportClasses.IStyleableEditableText;
import spark.components.supportClasses.ScrollableStageText;

/**
 *  ActionScript-based skin for TextArea controls in mobile applications that uses a
 *  ScrollableStageText class for the text display.
 *  <p> and can be used in scrollable forms while allowing precise control of keyboard input.</p>
 *
 *  @see spark.components.TextArea
 *  @see spark.components.supportClasses.ScrollableStageText
 *
 *  @langversion 3.0
 *  @playerversion AIR 3.0
 *  @productversion Flex 4.12
 */
public class ScrollingStageTextAreaSkin extends StageTextAreaSkin
{
    public function ScrollingStageTextAreaSkin()
    {
        super();
        addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
    }

    override protected function createTextDisplay():IStyleableEditableText
    {
        return new ScrollableStageText(multiline);

    }

    /** @private
     *  We have to force focus to the text display when user user in the padding area of the TextInput.
    we do this hack  in the skin instead of the hostComponent TextInput to not impact the behavior of other skins
      */
    override public function set owner(value: DisplayObjectContainer): void
    {
        super.owner = value;
        if (owner){
            owner.mouseEnabled = false;
        }
    }

    private function mouseDownHandler(event: MouseEvent): void
    {
        textDisplay.setFocus();
    }
}
}
