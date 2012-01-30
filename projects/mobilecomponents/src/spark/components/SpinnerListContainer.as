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
package spark.components
{
/**
 *  Container for one or more SpinnerList controls. The SpinnerLists are laid out horizontally.
 *  The SpinnerListContainerSkin displays a frame, shadow gradients and a selection indicator.   
 *       
 * @see spark.components.SpinnerList
 * @see spark.skins.mobile.SpinnerListContainerSkin
 * 
 *  @includeExample examples/SpinnerListExample.mxml -noswf
 *  @includeExample examples/SpinnerListContainerExample.mxml -noswf
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */ 
    
[Exclude(name="backgroundAlpha", kind="style")]
[Exclude(name="backgroundColor", kind="style")]    
    
public class SpinnerListContainer extends SkinnableContainer
{
    /**
     *  Constructor.
     *        
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */     
    public function SpinnerListContainer()
    {
        super();
    }
}
}