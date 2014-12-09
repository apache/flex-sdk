package org.apache.flex.promises.enums
{

public class PromiseState
{
    
    //--------------------------------------------------------------------------
    //
    //    Class constants
    //
    //--------------------------------------------------------------------------
    
	public static const BLOCKED:PromiseState = new PromiseState("blocked");
	public static const FULFILLED:PromiseState = new PromiseState("fulfilled");
	public static const PENDING:PromiseState = new PromiseState("pending");
	public static const REJECTED:PromiseState = new PromiseState("rejected");
	
    //--------------------------------------------------------------------------
    //
    //    Constructor
    //
    //--------------------------------------------------------------------------
    
    public function PromiseState(stringValue:String) {
        this.stringValue = stringValue;
    }
    
    //--------------------------------------------------------------------------
    //
    //    Variables
    //
    //--------------------------------------------------------------------------
    
    private var stringValue:String;
    
    //--------------------------------------------------------------------------
    //
    //    Methods
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //    toString
    //----------------------------------
    
    public function toString():String
    {
        return stringValue;
    }
    
}
}