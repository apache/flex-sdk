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
import mx.controls.SWFLoader;

[IconFile("flash_component_icon_small.png")]
public class FlashComponentPlaceholder extends FlashContainerPlaceholder
{
    public function FlashComponentPlaceholder()
    {
        super();
    }
    
    override protected function createImage():SWFLoader
    {
        image1 = new SWFLoader();
        image1.source = _embed_mxml_flash_component_icon_png;
        image1.scaleContent = false;
        image1.setStyle('horizontalAlign' , 'center');
        image1.setStyle('verticalAlign' , 'middle');
        return image1;            
    }

    [Embed(source='flash_component_icon.png')]
    private var _embed_mxml_flash_component_icon_png:Class;
}
}