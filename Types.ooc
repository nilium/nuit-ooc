include math

/**
    Cover of an existing type.  Must be floating point, does not specify or
    require a given precision.
    
    Defaults to the 32bit Float.
*/
NFloat: cover from float extends Float {
	
	/* these are here because I typically don't trust the SDK very much at all */
	min: extern(fminf) func (This) -> This
	max: extern(fmaxf) func (This) -> This
	abs: extern(fabsf) func -> This
	floor: extern(floorf) func -> This
	ceil: extern(ceilf) func -> This
	mod: extern(fmodf) func(y: This) -> This
	EPSILON: static const extern(FLT_EPSILON) This
	
	clampedTo: func (_min, _max: This) -> This {
	    this max(_min) min(_max)
	}
	
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
	
	init: func@ ~u (u: NFloat) {
	    width = u
	    height = u
    }
	
	init: func@ (=width, =height) {}
	
	zero: static func -> This {
	    new(0.0, 0.0)
	}
	
    min: func (right: This) -> This {
		new(width min(right width),
		    height min(right height))
	}
	
	max: func (right: This) -> This {
		new(width max(right width),
		    height max(right height))
	}
	
	add: func@ (other: This) {
		this width += other width
		this height += other height
	}
	
	subtract: func@ (other: This) {
		this width -= other width
		this height -= other height
	}
	
	multiply: func@ (other: This) {
	    this width *= other width
	    this height *= other height
	}
	
	divide: func@ (other: This) {
	    this width /= other width
	    this height /= other height
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
	
	toString: func -> String {
		"%f, %f" format(width, height)
	}
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
	
	init: func@ ~u (u: NFloat) {
	    x = u
	    y = u
	}
	
	init: func@ (=x, =y) {}
	
	zero: static func -> This {
	    new(0.0, 0.0)
	}
	
	min: func (right: This) -> This {
		new(x min(right x),
		    y min(right y))
	}
	
	max: func (right: This) -> This {
		new(x max(right x),
		    y max(right y))
	}
	
	add: func@ (other: This) {
		this x += other x
		this y += other y
	}
	
	subtract: func@ (other: This) {
		this x -= other x
		this y -= other y
	}
	
	multiply: func@ (other: This) {
	    this x *= other x
	    this y *= other y
	}
	
	divide: func@ (other: This) {
	    this x /= other x
	    this y /= other y
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
	
	toString: func -> String {
		"%f, %f" format(x, y)
	}
}

operator + (left, right: NPoint) -> NPoint {
    left add(right)
    return left
}

operator - (left, right: NPoint) -> NPoint {
    left subtract(right)
    return left
}

operator * (left, right: NPoint) -> NPoint {
    left multiply(right)
    return left
}

operator / (left, right: NPoint) -> NPoint {
    left divide(right)
    return left
}

operator + (left, right: NSize) -> NSize {
    left add(right)
    return left
}

operator - (left, right: NSize) -> NSize {
    left subtract(right)
    return left
}

operator * (left, right: NSize) -> NSize {
    left multiply(right)
    return left
}

operator / (left, right: NSize) -> NSize {
    left divide(right)
    return left
}

operator + (left: NPoint, right: NSize) -> NPoint {
    left add(right toPoint())
    return left
}

operator - (left: NPoint, right: NSize) -> NPoint {
    left subtract(right toPoint())
    return left
}

operator + (left: NSize, right: NPoint) -> NSize {
    left add(right toSize())
    return left
}

operator - (left: NSize, right: NPoint) -> NSize {
    left subtract(right toSize())
    return left
}

operator * (left: NPoint, right: NSize) -> NPoint {
    left multiply(right toPoint())
    return left
}

operator / (left: NPoint, right: NSize) -> NPoint {
    left divide(right toPoint())
    return left
}

operator * (left: NSize, right: NPoint) -> NSize {
    left multiply(right toSize())
    return left
}

operator / (left: NSize, right: NPoint) -> NSize {
    left divide(right toSize())
    return left
}

operator += (_left: NPoint@, right: NPoint) {
    left: NPoint = _left
    left add(right)
    _left = left
}

operator -= (_left: NPoint@, right: NPoint) {
    left: NPoint = _left
    left subtract(right)
    _left = left
}

operator *= (_left: NPoint@, right: NPoint) {
    left: NPoint = _left
    left multiply(right)
    _left = left
}

operator /= (_left: NPoint@, right: NPoint) {
    left: NPoint = _left
    left divide(right)
    _left = left
}

operator += (_left: NSize@, right: NSize) {
    left: NSize = _left
    left add(right)
    _left = left
}

operator -= (_left: NSize@, right: NSize) {
    left: NSize = _left
    left subtract(right)
    _left = left
}

operator *= (_left: NSize@, right: NSize) {
    left: NSize = _left
    left multiply(right)
    _left = left
}

operator /= (_left: NSize@, right: NSize) {
    left: NSize = _left
    left divide(right)
    _left = left
}

operator += (_left: NPoint@, right: NSize) {
    left: NPoint = _left
    left add(right toPoint())
    _left = left
}

operator -= (_left: NPoint@, right: NSize) {
    left: NPoint = _left
    left subtract(right toPoint())
    _left = left
}

operator += (_left: NSize@, right: NPoint) {
    left: NSize = _left
    left add(right toSize())
    _left = left
}

operator -= (_left: NSize@, right: NPoint) {
    left: NSize = _left
    left subtract(right toSize())
    _left = left
}

operator *= (_left: NPoint@, right: NSize) {
    left: NPoint = _left
    left multiply(right toPoint())
    _left = left
}

operator /= (_left: NPoint@, right: NSize) {
    left: NPoint = _left
    left divide(right toPoint())
    _left = left
}

operator *= (_left: NSize@, right: NPoint) {
    left: NSize = _left
    left multiply(right toSize())
    _left = left
}

operator /= (_left: NSize@, right: NPoint) {
    left: NSize = _left
    left divide(right toSize())
    _left = left
}

operator = (left: NSize@, right: NPoint) {
    left = right toSize()
}

operator = (left: NRect@, right: NPoint) {
    left = right toRect()
}

operator = (left: NPoint@, right: NSize) {
    left = right toPoint()
}

operator = (left: NRect@, right: NSize) {
    left = right toRect()
}

operator == (left, right: NPoint) -> Bool {
	left x equals(right x) && left y equals(right y)
}

operator != (left, right: NPoint) -> Bool {
    !(left == right)
}

operator as (value: Float) -> NPoint {
    NPoint new(value)
}

operator as (value: Float) -> NSize {
    NSize new(value)
}

operator as (size: NSize) -> NPoint {
    size toPoint()
}

operator as (point: NPoint) -> NSize {
    point toSize()
}

operator as (size: NSize) -> NRect {
    size toRect()
}

operator as (point: NPoint) -> NRect {
    point toRect()
}

operator as (point: NPoint) -> String {
    point toString()
}

operator as (size: NSize) -> String {
    size toString()
}

operator as (rect: NRect) -> String {
    rect toString()
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
		
		intersection origin = origin max(other origin)
		intersection size width = (right() min(other right()) - intersection left()) max(0.0)
		intersection size height = (bottom() min(other bottom()) - intersection top()) max(0.0)
		
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
	
	alignTop: func@ (top: NFloat) {
	    origin y = top
	}
	
	alignLeft: func@ (left: NFloat) {
	    origin x = left
	}
	
	alignBottom: func@ (bottom: NFloat) {
	    origin y = bottom - height()
	}
	
	alignRight: func@ (right: NFloat) {
	    origin x = right - width()
	}
	
	contains: func (point: NPoint) -> Bool {
		return (left() <= point x() && point x() <= right() && top() <= point y() && point y() <= bottom())
	}
	
	toString: func -> String {
		"%f, %f, %f, %f" format(x(), y(), width(), height())
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
    
    init: func@ ~blackOpaque {
        red = 0.0
        green = 0.0
        blue = 0.0
        alpha = 1.0
    }
    
    init: func@ ~opaque (=red, =green, =blue) {
        alpha = 1.0
    }
    
    init: func@ (=red, =green, =blue, =alpha) {}
}
