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

package org.apache.flex.collections
{

import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

import mx.core.mx_internal;
import mx.collections.ICollectionView;
import mx.collections.ListCollectionView;

use namespace mx_internal;

[DefaultProperty("source")]

/**
 *  The VectorCollection class is a wrapper class that exposes a Vector as a collection 
 *  that can be accessed and manipulated using the methods and properties of the 
 *  ICollectionView or IList interfaces. Operations on a ArrayCollection instance modify 
 *  the data source; for example, if you use the removeItemAt() method on  
 *  VectorCollection, you remove the item from the underlying Vector.
 */
public class VectorCollection extends ListCollectionView implements ICollectionView
{

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  <p>Creates a new VectorCollection using the specified source vector.
     *  If no Vector is specified an empty vector of type&lt;&#42;&gt; will be used.
     *  </p>
	 *
	 *  <p>Due to the way the compiler (not the runtime) checks Vectors, we need to 
	 *  leave the source as an &lt;&#42;&gt; until a compiler change can be implemented.
	 *  </p>
     */
    public function VectorCollection(source:* = null)
    {		
        super();

        this.source = source;
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  source
    //----------------------------------

    [Inspectable(category="General", arrayType="Object")]
    [Bindable("listChanged")] //superclass will fire this

    /**
     *  The source of data in the VectorCollection.
     *  The VectorCollection object does not represent any changes that you make
     *  directly to the source Vector. Always use
     *  the ICollectionView or IList methods to modify the collection.
     */
    public function get source():*
    {
        if (list && (list is VectorList))
        {
            return VectorList(list).source;
        }

        return null;
    }

    /**
     *  @private
     */
    public function set source(s:*):void
    {		
		//Provides a default VectorList
		list = new VectorList( s );
    }
}

}
