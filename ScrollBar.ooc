import structs/HashMap
import Types, GUI, View, Renderer, Drawable

NScrollBarScrollEvent := "SBScrollEvent"

// Event data
NScrollBarPreviousValue := "SBPreviousValue" // previous value of the scrollbar => Cell<NFloat>

NScrollBar: abstract class extends NView {
	_min = 0.0: NFloat
	_max = 100.0: NFloat
	_value = 0.0: NFloat
	_step = 20.0: NFloat
	
	_scrubberDrawable: NDrawable = null
	
	_dragging := false
	_dragOff = 0.0: NFloat
	
	_barPadding: NFloat = 0.0
	
	jumpsToCursor := false
	
	init: super func
	
	value: func -> NFloat { _value }
	
	setValue: func (value: NFloat) {
		_value = value max(_min) min(_max)
	}
	
	percentage: func -> NFloat { (_value - _min) / (_max - _min) }
	
	setPercentage: func (perc: NFloat) {
		setValue(((_max - _min) * perc) + _min)
	}
	
	min: func -> NFloat { _min }
	max: func -> NFloat { _max }
	
	setMin: func (=_min) -> NFloat {
		setValue(_value)
		setScrollSize(_step)
	}
	
	setMax: func (=_max) -> NFloat {
		setValue(_value)
		setScrollSize(_step)
	}
	
	setScrollSize: func (._step) {
		this _step = _step abs() min((_max - _min) abs())
	}
	
	scrollSize: func -> NFloat { _step }
	
	_scrollLength: abstract func -> NFloat
	
	_barSize: func -> NFloat {
		((_step / (_max - _min)) * (_scrollLength() - _barPadding * 2)) floor() max(20.0)
	}
	
	_barPos: func -> NFloat {
		(percentage() * (_scrollLength() - _barSize() - _barPadding*2.0)) floor()
	}
	
	_setValueForOffset: func (off: NFloat) {
		sz := _barSize()
		prev := _value
		setValue( (((off - _dragOff) - (sz * 0.5)) / (_scrollLength() - sz - _barPadding * 2)) * (_max - _min) + _min)
		_scrollAction(prev)
		data := HashMap<String, Object> new(2)
		data put(NScrollBarPreviousValue, Cell<NFloat> new(prev))
		_fireEvent(NScrollBarScrollEvent, data)
		onScroll(prev)
	}
	
	_scrollAction: func (previousValue: NFloat) {}
	
	onScroll: func (previousValue: NFloat) {}
	
	setScrubberDrawable: func(=_scrubberDrawable) {}
	
	scrubberDrawable: func -> NDrawable { _scrubberDrawable }
}

NVScrollBar: class extends NScrollBar {
	init: super func
	
	_loadDefaultDrawables: func {
        setDrawable(_gui skin() drawableForName("VerticalScrollBar"))
        setScrubberDrawable(_gui skin() drawableForName("VerticalScrollBarScrubber"))
    }
	
	mousePressed: func (button: Int, position: NPoint) -> NView {
		if (button != 1)
			return forwardMousePressedEvent(button, position)
		
		sz := _barSize()
		pos := _barPos()
		
		position y -= _barPadding
		
		clickRect := NRect new(0.0, pos, size() width, sz)
		if (!clickRect contains(position)) {
			if (jumpsToCursor) {
    			_dragOff = 0.0
    			_setValueForOffset(position y)
    		} else {
    		    prev := _value
    		    if (position y < clickRect top()) {
    		        setValue(_value - _step)
    		    } else {
    		        setValue(_value + _step)
    		    }
    		    _scrollAction(prev)
		        data := HashMap<String, Object> new(2)
        		data put(NScrollBarPreviousValue, Cell<NFloat> new(prev))
        		_fireEvent(NScrollBarScrollEvent, data)
        		onScroll(prev)
        		return this
    		}
		} else {
			_dragOff = position y - (pos + sz * 0.5)
		}
		
		_dragging = true
		
		return this
	}
	
	mouseMoved: func (pos, delta: NPoint) {
		if (_dragging)
			_setValueForOffset(pos y - _barPadding)
	}
	
	mouseReleased: func (button: Int, pos: NPoint) {
		if (button == 1) {
			_dragging = false
		}
	}
	
	draw: func (renderer: NRenderer) {
		drw := drawable()
		frame := disabled?(true) as Int
		if (drw)
			drw drawInRect(renderer, size() toRect(), frame)
	    drw = scrubberDrawable()
		if (drw)
			drw drawInRect(renderer, NRect new(0.0, _barPos()+_barPadding, size() width, _barSize()), frame)
	}
	
	_scrollLength: func -> NFloat {
		size() height
	}
}

NHScrollBar: class extends NScrollBar {
	init: super func
	
	_loadDefaultDrawables: func {
        setDrawable(_gui skin() drawableForName("HorizontalScrollBar"))
        setScrubberDrawable(_gui skin() drawableForName("HorizontalScrollBarScrubber"))
    }
	
	mousePressed: func (button: Int, position: NPoint) -> NView {
		if (button != 1)
			return forwardMousePressedEvent(button, position)
		
		sz := _barSize()
		pos := _barPos()
		
		position x -= _barPadding
		
		clickRect := NRect new(pos, 0.0, sz, size() height)
		if (!clickRect contains(position)) {
		    if (jumpsToCursor) {
    			_dragOff = 0.0
    			_setValueForOffset(position x)
    		} else {
    		    prev := _value
    		    if (position x < clickRect left()) {
    		        setValue(_value - _step)
    		    } else {
    		        setValue(_value + _step)
    		    }
    		    _scrollAction(prev)
		        data := HashMap<String, Object> new(2)
        		data put(NScrollBarPreviousValue, Cell<NFloat> new(prev))
        		_fireEvent(NScrollBarScrollEvent, data)
        		onScroll(prev)
        		return this
    		}
		} else {
			_dragOff = position x - (pos + sz * 0.5)
		}
		
		_dragging = true
		
		return this
	}
	
	mouseMoved: func (pos, delta: NPoint) {
		if (_dragging)
			_setValueForOffset(pos x - _barPadding)
	}
	
	mouseReleased: func (button: Int, pos: NPoint) {
		if (button == 1) {
			_dragging = false
		}
	}
	
	draw: func (renderer: NRenderer) {
		drw := drawable()
		frame := disabled?(true) as Int
		if (drw)
			drw drawInRect(renderer, size() toRect(), frame)
		drw = scrubberDrawable()
		if (drw)
		    drw drawInRect(renderer, NRect new(_barPos()+_barPadding, 0.0, _barSize(), size() height), frame)
	}
	
	_scrollLength: func -> NFloat {
		size() width
	}
}

