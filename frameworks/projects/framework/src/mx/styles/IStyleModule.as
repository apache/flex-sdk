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

package mx.styles
{

/**
 * Simple interface to manipulate style modules.
 * You can cast an object to an IStyleModule type so that there is no dependency on the StyleModule
 * type in the loading application.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IStyleModule
{
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Creates and sets style declarations from the styles modules into the given
     *  style manager. This should be called after the style modules is created.
     *  
     *  @param styleManager The style manager where the style declarations will be 
     *  loaded into. The style declarations will be created relative to the this 
     *  style manager. The unload() function will unload styles from this style 
     *  manager. If null is passed the top-level style manager is used.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    function setStyleDeclarations(styleManager:IStyleManager2):void;
    
    /**
     *  Unloads the style module.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function unload():void;
}

}
