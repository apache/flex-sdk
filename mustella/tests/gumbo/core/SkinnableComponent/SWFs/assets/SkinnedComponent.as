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
package assets
{
    
import spark.components.Button;
import spark.components.supportClasses.Skin;
import spark.components.supportClasses.SkinnableComponent;
import mx.events.FlexEvent;

public class SkinnedComponent extends SkinnableComponent 
{
    [SkinPart(required="false")]
    public var sbutt:Button = null;
    
    [Bindable]
    public var bindableString:String = "a bindable string";
    
    /**
     *  Constructor. 
     */    
    public function SkinnedComponent()
    {
        super();
    }
    
    override protected function partAdded(partName:String, instance:Object):void{
        dispatchEvent(new FlexEvent("CustomPartAddedEvent"));
    }

}

}