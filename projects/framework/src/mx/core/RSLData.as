////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2010 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.core
{

/**
 *  A Class that describes configuration data for an RSL.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10.2
 *  @playerversion AIR 2.5
 *  @productversion Flex 4.5
 */
public class RSLData
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
     *  @param rslURL The location of the RSL.
     *  @param policyFileURL The location of the policy file url (optional).
     *  @param digest The digest of the RSL. This is null for an RSL without 
     *  a digest.
     *  @param hashType The type of hash used to create the digest. The only 
     *  supported value is <code>SHA256.TYPE_ID</code>.
     *  @param isSigned True if the RSL has been signed by Adobe, false 
     *  otherwise.
     *  @param verifyDigest Detemines if the RSL's digest should be verified
     *  after it is loaded. 
     *  @param applicationDomainTarget The application domain where the the
     *  RSL should be loaded. For valid values see the ApplicationDomainTarget
     *  enumeration.
     *  
     *  @see mx.core.ApplicationDomainTarget
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function RSLData(rslURL:String = null, 
                            policyFileURL:String = null, 
                            digest:String = null, 
                            hashType:String = null, 
                            isSigned:Boolean = false, 
                            verifyDigest:Boolean = false,
                            applicationDomainTarget:String = "default")
    {
        super();
        
        _rslURL = rslURL
        _policyFileURL = policyFileURL;
        _digest = digest;
        _hashType = hashType;
        _isSigned = isSigned;
        _verifyDigest = verifyDigest;
        _applicationDomainTarget = applicationDomainTarget; 
        _moduleFactory = moduleFactory;
        
    }
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  applicationDomainTarget
    //----------------------------------
    
    /**
     *  @private
     */ 
    private var _applicationDomainTarget:String;
    
    /**
     *  The requested application domain to load the RSL into.
     *  For valid values see the ApplicationDomainTarget enumeration.
     * 
     *  @see mx.core.ApplicationDomainTarget
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get applicationDomainTarget():String
    {
        return _applicationDomainTarget;    
    }
    
    //----------------------------------
    //  digest
    //----------------------------------

    /**
     *  @private
     */ 
    private var _digest:String;

    /**
     *  The digest of the RSL. This is null for an RSL without a digest.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get digest():String
    {
        return _digest;
    }
    
    //----------------------------------
    //  hash type
    //----------------------------------

    /**
     *  @private
     */ 
    private var _hashType:String;
    
    /**
     *  The type of hash used to create the RSL digest. The only supported hash
     *  type is <code>SHA256.TYPE_ID</code>.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get hashType():String
    {
        return _hashType;
    }
    
    //----------------------------------
    //  isSigned
    //----------------------------------

    /**
     *  @private
     */ 
    private var _isSigned:Boolean;

    /**
     *  True if the RSL has been signed by Adobe. False otherwise.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get isSigned():Boolean
    {
        return _isSigned;
    }
    
    //----------------------------------
    //  moduleFactory
    //----------------------------------
    
    /**
     *  @private
     */ 
    private var _moduleFactory:IFlexModuleFactory;
    
    /**
     *  Non-null if this RSL should be loaded into an application
     *  domain other than the application domain associated with the
     *  module factory performing the load. If null, then load into
     *  the current application domain.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get moduleFactory():IFlexModuleFactory
    {
        return _moduleFactory;
    }
    
    /**
     *  @private
     */ 
    public function set moduleFactory(moduleFactory:IFlexModuleFactory):void
    {
        _moduleFactory = moduleFactory;
    }
    
   //----------------------------------
    //  policyFileURL
    //----------------------------------
    
    /**
     *  @private
     */ 
    private var _policyFileURL:String;

    /**
     *  An URL that specifies the location of the policy file (optional).
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get policyFileURL():String
    {
        return _policyFileURL;
    }
    
    //----------------------------------
    //  rslURL
    //----------------------------------
    
    /**
     *  @private
     */ 
    private var _rslURL:String;

    /**
     *  The location of the RSL. The URL can be absolute or relative to the 
     *  application or module. 
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get rslURL():String
    {
        return _rslURL;
    }
    
    //----------------------------------
    //  verifyDigest
    //----------------------------------
    
    /**
     *  @private
     */ 
    private var _verifyDigest:Boolean;

    /**
     *  True if the digest must be verified before loading the RSL into memory.
     *  False allows the RSL to be loaded without verification. Signed RSLs
     *  are always verified regardless of the value.
     *
     *  @langversion 3.0
     *  @playerversion Flash 10.2
     *  @playerversion AIR 2.5
     *  @productversion Flex 4.5
     */
    public function get verifyDigest():Boolean
    {
        return _verifyDigest;
    }
 
}
}