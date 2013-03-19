package spark.supportClasses
{
	import mx.core.IDeferredContentOwner;
	import mx.core.ISelectableList;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	
	import spark.components.supportClasses.GroupBase;
	
	import spark.layouts.supportClasses.INavigatorLayout;
	
	public interface INavigator extends ISelectableList, IVisualElement
	{
		
		function get layout():INavigatorLayout;
		function set layout( value:INavigatorLayout ):void
	}
}