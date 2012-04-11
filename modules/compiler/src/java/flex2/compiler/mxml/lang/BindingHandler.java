/*
 *
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

package flex2.compiler.mxml.lang;

import flex2.compiler.mxml.rep.BindingExpression;
import flex2.compiler.mxml.rep.Model;

/**
 * This interface defines the API used by the binding handlers of
 * flex2.compiler.mxml.builder.* based builders, which need to pass a
 * local handler into subbuilders.  For example, ArrayBuilder and
 * VectorBuilder, use a BindingHandler implemenation, so that
 * subbuilders like ComponentBuilder and PrimitiveBuilder can allow
 * the parent builder to associate the Array/Vector with the
 * BindingExpression and set information like the index of the
 * subbuilder.
 */
public interface BindingHandler
{
	BindingExpression invoke(BindingExpression bindingExpression, Model dest);
}
