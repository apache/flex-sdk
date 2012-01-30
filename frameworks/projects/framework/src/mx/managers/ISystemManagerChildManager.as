
package mx.managers
{

import flash.display.DisplayObject;  

[ExcludeClass];

/**
 */
public interface ISystemManagerChildManager
{
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

   
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	function addingChild(child:DisplayObject):void;
	function childAdded(child:DisplayObject):void;

	function childRemoved(child:DisplayObject):void;
	function removingChild(child:DisplayObject):void;

	function initializeTopLevelWindow(width:Number, height:Number):void;
}

}
