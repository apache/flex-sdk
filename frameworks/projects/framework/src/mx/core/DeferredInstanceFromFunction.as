////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2005-2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{

/**
 *  A deferred instance factory that uses a generator function
 *  to create an instance of the required object.
 *  An application uses the <code>getInstance()</code> method to
 *  create an instance of an object when it is first needed and get
 *  a reference to the object thereafter.
 *
 *  @see DeferredInstanceFromClass
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class DeferredInstanceFromFunction implements ITransientDeferredInstance
{
    include "../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param generator A function that creates and returns an instance
     *  of the required object.
     *
     *  @param destructor An optional function used to cleanup outstanding
     *  references when <code>reset()</code> is called.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function DeferredInstanceFromFunction(generator:Function,
        destructor:Function = null )
    {
        super();

        this.generator = generator;
        this.destructor = destructor;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  The generator function.
     */
    private var generator:Function;

    /**
     *  @private
     *  The generated value.
     */
    private var instance:Object = null;

    /**
     *  @private
     *  An optional function used to cleanup outstanding
     *  references when reset() is invoked
     */
    private var destructor:Function;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Returns a reference to an instance of the desired object.
     *  If no instance of the required object exists, calls the function
     *  specified in this class' <code>generator</code> constructor parameter.
     * 
     *  @return An instance of the object.
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    public function getInstance():Object
    {
        if (!instance)
            instance = generator();

        return instance;
    }
    
    /**
     *  Resets the state of our factory to the initial, uninitialized state.
     *  The reference to our cached instance is cleared.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 4
     */
    public function reset():void
    {
        instance = null;
        
        if (destructor != null)
            destructor();
    }

}

}
