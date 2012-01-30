////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2006 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package mx.validators
{

/**
 *  The CreditCardValidatorCardType class defines value constants
 *  for specifying the type of credit card to validate.
 *  These values are used in the <code>CreditCardValidator.cardType</code>
 *  property.
 *
 *  @see mx.validators.CreditCardValidator
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public final class CreditCardValidatorCardType
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class constants 
	//
	//--------------------------------------------------------------------------
		
	/**
	 *  Specifies the card type as MasterCard.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const MASTER_CARD:String = "MasterCard"
	
	/**
	 *  Specifies the card type as Visa.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const VISA:String = "Visa";
	
	/**
	 *  Specifies the card type as American Express.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const AMERICAN_EXPRESS:String = "American Express";
	
	/**
	 *  Specifies the card type as Discover.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const DISCOVER:String = "Discover";
	
	/**
	 *  Specifies the card type as Diners Club.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const DINERS_CLUB:String = "Diners Club";
}

}
