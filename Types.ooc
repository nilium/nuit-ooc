include math

NFloat: cover from float extends Float {
	
	/* these are here because I typically don't trust the SDK very much at all */
	min: static extern(fminf) func (This, This) -> This
	max: static extern(fmaxf) func (This, This) -> This
	abs: extern(fabsf) func -> This
	floor: extern(floorf) func -> This
	ceil: extern(ceilf) func -> This
	mod: extern(fmodf) func(y: This) -> This
	EPSILON: static const extern(FLT_EPSILON) This
	
	/**
	    Determines whether or not two NFloats are equal based on whether or
	    not their absolute difference is smaller than the float epsilon.
	    
	    This is not the same as NFloat==NFloat.
	 */
	equals: inline func(other: This) -> Bool {
		(this-other < This EPSILON)
	}
}

NSize: cover {
	width: NFloat = 0.0
	height: NFloat = 0.0
	
	init: func@ (=width, =height) {}
	
	zero: static func -> This {
	    new(0.0, 0.0)
	}
	
    min: static func (left, right: This) -> This {
		new(NFloat min(left width, right width),
		    NFloat min(left height, right height))
	}
	
	max: static func (left, right: This) -> This {
		new(NFloat max(left width, right width),
		    NFloat max(left height, right height))
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
	
	contains: func (point: NPoint) -> Bool {
	    return (0.0 <= point x && point x <= width &&
	            0.0 <= point y && point y <= height)
	}
	
	toPoint: func -> NPoint { NPoint new(width, height) }
	
	toRect: func -> NRect { NRect new(NPoint zero(), this) }
}

operator == (left, right: NSize) -> Bool {
	left width equals(right width) && left height equals(right height)
}

operator != (left, right: NSize) -> Bool {
    !(left == right)
}

NPoint: cover {
	x: NFloat = 0.0
	y: NFloat = 0.0
	
	init: func@ (=x, =y) {}
	
	zero: static func -> This {
	    new(0.0, 0.0)
	}
	
	min: static func (left, right: This) -> This {
		new(NFloat min(left x, right x),
		    NFloat min(left y, right y))
	}
	
	max: static func (left, right: This) -> This {
		new(NFloat max(left x, right x),
		    NFloat max(left y, right y))
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
	
	toSize: func -> NSize { NSize new(x, y) }
	
	toRect: func -> NRect { NRect new(this, NSize zero()) }
}

operator == (left, right: NPoint) -> Bool {
	left x equals(right x) && left y equals(right y)
}

operator != (left, right: NPoint) -> Bool {
    !(left == right)
}

/* 
 * Origins start at (0,0) at the upper-left part of the screen/view/window
 * and as they increase they move closer to the lower-right part of the screen.
 */
NRect: cover {
	origin: NPoint
	size: NSize
	
	init: func@ ~valued (x, y, w, h: NFloat) {
	    origin set(x, y)
	    size set(w, h)
	}
	
	init: func@ (=origin, =size) {}
	
	zero: static func -> This {
	    new(NPoint zero(), NSize zero())
	}
	
	intersection: func (other: NRect) -> This {
		intersection: This
		
		intersection origin = NPoint max(origin, other origin)
		intersection size width = NFloat max(NFloat min(right(), other right()) - intersection left(), 0.0)
		intersection size height = NFloat max(NFloat min(bottom(), other bottom()) - intersection top(), 0.0)
		
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
	
	setLeft: func@ (left: NFloat) {
	    size width = right() - left
	    origin x = left
	}
	
	setRight: func@ (right: NFloat) {
	    size width = right - left()
	}
	
	setTop: func@ (top: NFloat) {
	    size height = bottom() - top
	    origin y = top
	}
	
	setBottom: func@ (bottom: NFloat) {
	    size height = bottom - top()
	}
	
	contains: func (point: NPoint) -> Bool {
		return (left() <= point x() && point x() <= right() && top() <= point y() && point y() <= bottom())
	}
}

operator == (left, right: NRect) -> Bool {
	left origin == right origin && left size == right size
}

operator != (left, right: NRect) -> Bool {
    !(left == right)
}

operator % (left, right: NRect) -> NRect {
    left intersection(right)
}

NColor: cover {
    red, green, blue, alpha: NFloat
    
    black: static func (alpha: NFloat) -> This { new(0.0, 0.0, 0.0, alpha) }
    black: static func ~opaque -> This { new(0.0, 0.0, 0.0) }
    white: static func (alpha: NFloat) -> This { new(1.0, 1.0, 1.0, alpha) }
    white: static func ~opaque -> This { new(1.0, 1.0, 1.0) }
    
    init: func@ ~opaque (=red, =green, =blue) {
        alpha = 1.0
    }
    
    init: func@ (=red, =green, =blue, =alpha) {}
}
