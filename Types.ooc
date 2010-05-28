include math

NFloat: cover from float extends Float {
	
	/* these are here because I typically don't trust the SDK very much at all */
	min: static extern(fminf) func (This, This) -> This
	max: static extern(fmaxf) func (This, This) -> This
	abs: extern(fabsf) func -> This
	floor: extern(floorf) func -> This
	ceil: extern(ceilf) func -> This
	EPSILON: static const extern(FLT_EPSILON) This
	
	/* determines whether or not two NFloats are equal based
	 * on whether or not their absolute difference is smaller
	 * than the float epsilon
	 */
	equals: inline func(other: This) -> Bool {
		(this-other < This EPSILON)
	}
}

NSize: cover {
	width, height: NFloat
	
	zero: static func -> This {
	    z: This
	    z set(0.0, 0.0)
	    return z
	}
	
    min: static func (left, right: This) -> This {
		r: This
		r width = NFloat min(left width, right width)
		r height = NFloat min(left height, right height)
		return r
	}
	
	max: static func (left, right: This) -> This {
		r: This
		r width = NFloat max(left width, right width)
		r height = NFloat max(left height, right height)
		return r
	}
	
	add: func@ (other: This) {
		this width += other width
		this height += other height
	}
	
	subtract: func@ (other: This) {
		this width -= other width
		this height -= other height
	}
	
	set: func@ (=width, =height) {}
	get: func (width, height: NFloat@) {
		width = this width
		height = this height
	}
	
	width: inline func -> NFloat {
		width
	}
	
	height: inline func -> NFloat {
		height
	}
}

operator == (left, right: NSize) -> Bool {
	left width equals(right width) && left height equals(right height)
}

operator += (left: NSize@, right: NSize) -> NSize@ {
	r: NSize = left
	r add(right)
	left = r
	return left&
}

operator -= (left: NSize@, right: NSize) -> NSize@ {
	r: NSize = left
	r subtract(right)
	left = r
	return left&
}

NPoint: cover {
	x, y: NFloat
	
	zero: static func -> This {
	    z: This
	    z set(0.0, 0.0)
	    return z
	}
	
	min: static func (left, right: This) -> This {
		r: This
		r x = NFloat min(left x, right x)
		r y = NFloat min(left y, right y)
		return r
	}
	
	max: static func (left, right: This) -> This {
		r: This
		r x = NFloat max(left x, right x)
		r y = NFloat max(left y, right y)
		return r
	}
	
	add: func@ (other: This) {
		this x += other x
		this y += other y
	}
	
	subtract: func@ (other: This) {
		this x -= other x
		this y -= other y
	}
	
	set: func@ (=x, =y) {}
	get: func (x, y: NFloat@) {
		x = this x
		y = this y
	}
	
	x: inline func -> NFloat {
		x
	}
	
	y: inline func -> NFloat {
		y
	}
}

operator == (left, right: NPoint) -> Bool {
	left x equals(right x) && left y equals(right y)
}

operator += (left: NPoint@, right: NPoint) -> NSize@ {
	r: NPoint = left
	r add(right)
	left = r
	return left&
}

operator -= (left: NPoint@, right: NPoint) -> NSize@ {
	r: NPoint = left
	r subtract(right)
	left = r
	return left&
}

/* 
 * Origins start at (0,0) at the upper-left part of the screen/view/window
 * and as they increase they move closer to the lower-right part of the screen.
 */
NRect: cover {
	origin: NPoint
	size: NSize
	
	zero: static func -> This {
	    z: This
	    z set(0.0, 0.0, 0.0, 0.0)
	    return z
	}
	
	intersection: func (other: NRect) -> This {
		intersection: This
		
		intersection origin = NPoint max(origin, other origin)
		intersection size width = NFloat min(right(), other right()) - intersection left()
		intersection size height = NFloat min(bottom(), other bottom()) - intersection top()
		
		return intersection
	}
	
	intersects: func (other: NRect) -> Bool {
		return !( other x() + other width() < x()	\
			|| other y() + other height() < y()		\
			|| x() + width() < other x()			\
			|| y() + height() < other y() )
	}
	
	set: func@ (x, y, w, h: NFloat) {
	    origin set(x, y)
	    size set(w, h)
	}
	
	x: inline func -> NFloat {
		origin x
	}
	
	y: inline func -> NFloat {
		origin y
	}
	
	width: inline func -> NFloat {
		size width
	}
	
	height: inline func -> NFloat {
		size height
	}
	
	left: inline func -> NFloat {
		x()
	}
	
	right: inline func -> NFloat {
		left() + width()
	}
	
	top: inline func -> NFloat {
		y()
	}
	
	bottom: inline func -> NFloat {
		top() + height()
	}
	
	contains: func (point: NPoint) -> Bool {
		return (left() <= point x() && point x() <= right() && top() <= point y() && point y() <= bottom())
	}
}

operator == (left, right: NRect) -> Bool {
	left origin == right origin && left size == right size
}
