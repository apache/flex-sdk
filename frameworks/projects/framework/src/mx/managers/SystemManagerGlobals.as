
package mx.managers
{

[ExcludeClass]

/**
 *  @private
 */
public class SystemManagerGlobals
{
	public static var topLevelSystemManagers:Array
												  /* of SystemManager */ = [];
    public static var bootstrapLoaderInfoURL:String;

	public static var showMouseCursor:Boolean;

	public static var changingListenersInOtherSystemManagers:Boolean;

	public static var dispatchingEventToOtherSystemManagers:Boolean;

    /**
     *  @private
     *  reference to the info() object from the first systemManager
	 *  in the application..
     */
	public static var info:Object;

    /**
     *  @private
     *  reference to the loaderInfo.parameters object from the first systemManager
	 *  in the application..
     */
	public static var parameters:Object;
}

}

