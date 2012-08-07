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
package myskins
{
    import mx.core.mx_internal;
    
    import spark.skins.mobile.CalloutSkin;
    use namespace mx_internal;
    
    public class CalloutSkinBasic extends CalloutSkin
    {
        public function CalloutSkinBasic()
        {
            super();
            /*          useContentMask=true; */
            dropShadowVisible=false;
            useBackgroundGradient=false;
            contentCornerRadius=5;
            
            /*		contentBackgroundClass = null;*/
            frameThickness=5;
            arrowWidth = 30;
            arrowHeight = 10;
            borderThickness = 3;
            borderColor = 0xFFFFFF;
        }
    }
}