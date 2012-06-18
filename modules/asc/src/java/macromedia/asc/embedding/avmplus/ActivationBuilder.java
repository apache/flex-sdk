/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package macromedia.asc.embedding.avmplus;

import macromedia.asc.util.*;
import macromedia.asc.semantics.*;

/**
 * Activation interface. An activation provides slot storage.
 *
 * @author Jeff Dyer
 */
public class ActivationBuilder extends Builder
{
	// public:

	public ActivationBuilder()
	{
	}

	public void build(Context cx, ObjectValue ob)
	{
		objectValue = ob;
		contextId = cx.getId();
	    var_offset = 0;
	    reg_offset = 1; // this
	}

    public int Method(Context cx, ObjectValue ob, final String name, Namespaces namespaces, boolean is_intrinsic)
    {
        // If building an intrinsic instance, then do nothing here
		if( this.is_intrinsic || is_intrinsic )
        {
            return -1;
        }

		return GetMethodId(cx,name,namespaces);
    }

	public int ExplicitCall( Context cx, ObjectValue ob, String name, Namespaces namespaces, TypeValue type, boolean is_final, boolean is_override, int expected_id, int method_id, int var_id )
	{
		// Do the frontend binding

		if( method_id >= 0 || var_id < 0 ) // this is secret code for: it is a real method (not intrinsic) that doesn't have an implementation yet
		{
			// allocate a new var
			var_id  = Variable(cx,ob);
		}
		// otherwise, reuse the one passed in

		TypeValue functionType = cx.useStaticSemantics() ? cx.functionType() : type;
		int slot_id = super.ExplicitVar(cx,ob,name,namespaces,functionType,expected_id,-1,var_id);

		return slot_id;
	}
}
