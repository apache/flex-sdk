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
package renderers
{
	import spark.components.LabelItemRenderer;
	import flash.events.Event;
	
	/**
	 * An extremely simple subclass of LabelItemRenderer designed so Mustella tests
	 * can key off of specific events.
	 * 
	 * Caution: If you are going to use this with virtual layout be sure you understand
	 * the consequences of item renderer recycling.
	 * 
	 * @see also renderers.InstrumentedIconItemRenderer
	 */
	public class InstrumentedLabelItemRenderer extends LabelItemRenderer
	{
		/**
		 * Fires an event when the data setter is called.
		 *  
		 * This is useful when setting the itemRenderer property on the List and then
		 * needing to wait for the renderers to be created.
		 * 
		 * For example: 
		 * 
		 * <SetProperty target="navigator.activeView.target" propertyName="itemRenderer" 
		 *     valueExpression="value=new ClassFactory(spark.components.LabelItemRenderer)" 
		 *     waitEvent="itemRenderer1SetData" />
		 * 
		 * Be wary of using this in a virtual layout. You may receive more set data calls
		 * than you might be expecting.  To use this properly you will likely need to 
		 * understand some of the subtleties of item renderer recycling.  In a Mustella 
		 * context this is usually only useful for the first set data call that happens
		 * during the execution of the test step.
		 * 
		 * Note: Be careful when dealing with the first item/renderer in a List.  Sometimes
		 * that data item might also be a typicalItem and you will see the renderer fire things
		 * twice as often.
		 */
		override public function set data(value:Object):void
		{
            super.data = value;
            // Only fire the notification event if the data isn't null because 
            // when the data is null we are in the old renderer.  
            // See http://bugs.adobe.com/jira/browse/SDK-29034
            if (data != null){
                var setDataEventString:String = "itemRenderer" + itemIndex + "SetData"; 
                owner.dispatchEvent(new Event(setDataEventString));
                trace(setDataEventString);
            }
		}
	}
}