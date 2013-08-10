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

package spark.utils
{
import mx.core.DPIClassification;
    
/**
 *  This class provides a list of bitmaps for various runtime densities.  It is supplied
 *  as the source to BitmapImage or Image and as the icon of a Button.  The components
 *  will use the Application.runtimeDPI to choose which image to display.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @playerversion AIR 2.6
 *  @productversion Flex 4.5
 */
public class MultiDPIBitmapSource
{
    include "../core/Version.as";

	/**
	 *  The source to use if the <code>Application.runtimeDPI</code> 
	 *  is <code>DPIClassification.DPI_120</code>.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @playerversion AIR 2.6
	 *  @productversion ApacheFlex 4.11
	 */
	public var source120dpi:Object;
	
    /**
     *  The source to use if the <code>Application.runtimeDPI</code> 
     *  is <code>DPIClassification.DPI_160</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.6
     *  @productversion Flex 4.5
     */
    public var source160dpi:Object;

    /**
     *  The source to use if the <code>Application.runtimeDPI</code> 
     *  is <code>DPIClassification.DPI_240</code>.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.6
     *  @productversion Flex 4.5
     */
    public var source240dpi:Object;
    
	/**
	 *  The source to use if the <code>Application.runtimeDPI</code> 
	 *  is <code>DPIClassification.DPI_320</code>.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @playerversion AIR 2.6
	 *  @productversion Flex 4.5
	 */
	public var source320dpi:Object;
	
	/**
	 *  The source to use if the <code>Application.runtimeDPI</code> 
	 *  is <code>DPIClassification.DPI_480</code>.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @playerversion AIR 2.6
	 *  @productversion ApacheFlex 4.10
	 */
	public var source480dpi:Object;
	
	/**
	 *  The source to use if the <code>Application.runtimeDPI</code> 
	 *  is <code>DPIClassification.DPI_640</code>.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @playerversion AIR 2.6
	 *  @productversion ApacheFlex 4.11
	 */
	public var source640dpi:Object;
    
    /**
     *  Select one of the sourceXXXdpi properties based on the given DPI.  This
     *  function handles the fallback to different sourceXXXdpi properties
     *  if the given one is null.  
     *  The strategy is to try to choose the next highest
     *  property if it is not null, then return a lower property if not null, then 
     *  just return null.
     *
     *  @param The desired DPI.
     *
     *  @return One of the sourceXXXdpi properties based on the desired DPI.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.6
     *  @productversion Flex 4.5
     */
    public function getSource(desiredDPI:Number):Object
    {
        var source:Object = source160dpi;
        switch (desiredDPI)
        {
			case DPIClassification.DPI_640:
				source = source640dpi;
				if (!source || source == "")
					source = source480dpi;
				if (!source || source == "")
					source = source320dpi;
				if (!source || source == "")
					source = source240dpi;
				if (!source || source == "")
					source = source160dpi;
				if (!source || source == "")
					source = source120dpi;
				break;
			case DPIClassification.DPI_480:
				source = source480dpi;
				if (!source || source == "")
					source = source640dpi;
				if (!source || source == "")
					source = source320dpi;
				if (!source || source == "")
					source = source240dpi;
				if (!source || source == "")
					source = source160dpi;
				if (!source || source == "")
					source = source120dpi;
				break;
            case DPIClassification.DPI_320:
                source = source320dpi;
				if (!source || source == "")
					source = source480dpi;
				if (!source || source == "")
					source = source640dpi;
                if (!source || source == "")
                    source = source240dpi;
                if (!source || source == "")
                    source = source160dpi;
				if (!source || source == "")
					source = source120dpi;
                break;
			case DPIClassification.DPI_240:
				source = source240dpi;
				if (!source || source == "")
					source = source320dpi;
				if (!source || source == "")
					source = source480dpi;
				if (!source || source == "")
					source = source640dpi;
				if (!source || source == "")
					source = source160dpi;
				if (!source || source == "")
					source = source120dpi;
				break;
			case DPIClassification.DPI_160:
				source = source160dpi;
				if (!source || source == "")
					source = source240dpi;
				if (!source || source == "")
					source = source320dpi;
				if (!source || source == "")
					source = source480dpi;
				if (!source || source == "")
					source = source640dpi;
				if (!source || source == "")
					source = source120dpi;
				break;
			case DPIClassification.DPI_120:
				source = source120dpi;
				if (!source || source == "")
					source = source160dpi;
				if (!source || source == "")
					source = source240dpi;
				if (!source || source == "")
					source = source320dpi;
				if (!source || source == "")
					source = source480dpi;
				if (!source || source == "")
					source = source640dpi;
				break;
        }
        return source;
        
    }
    
}
}