/*
 * Written by Jeff Dyer
 * Copyright (c) 1998-2003 Mountain View Compiler Company
 * All rights reserved.
 */

package macromedia.asc.semantics;

import macromedia.asc.util.*;

/**
 * The interface for all types.
 *
 * @author Jeff Dyer
 */
public abstract class Type
{
//    virtual std::vector<Value*> values() = 0;
//    virtual std::vector<Value*> converts() = 0;
//    virtual void addSub(Type& type) = 0;
	public abstract boolean includes(Context cx, TypeValue value);
//    virtual void   setSuper(Type& type) = 0;
//    virtual Type*  getSuper() = 0;
//    virtual Value* convert(Context& cx, Value& value) = 0;
//    virtual Value* coerce(Context& cx, Value& value) = 0;
}

