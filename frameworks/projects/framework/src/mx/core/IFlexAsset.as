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
 *  IFlexAsset is a marker interface with the following meaning:
 *  if a class declares that it implements IFlexAsset,
 *  then that class represents an asset -- such as a bitmap, a font,
 *  or a sound -- that has been embedded in a Flex application.
 *  This interface does not define any properties or methods that the
 *  class must actually implement.
 *
 *  <p>The player uses ActionScript classes to represent
 *  embedded assets as well as executable ActionScript code.
 *  When you embed an asset in a Flex application, the MXML compiler
 *  autogenerates a class to represent it, and all such classes
 *  declare that they implement IFlexAsset so that they can be
 *  distinguished from the code classes.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public interface IFlexAsset
{
}

}
