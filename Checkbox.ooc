import Types, GUI, View, Button, Renderer, Drawable

NCheckbox: class extends NButton {
	_checked := false
	
	init: super func
	
	_buttonAction: func {
		setChecked(!checked())
	}
	
	_loadDefaultDrawables: func {
        setDrawable(_gui skin() drawableForName("Checkbox"))
    }
	
	setChecked: func (=_checked) {}
	checked: func -> Bool { _checked }
	
	_buttonSize: func -> NSize {
		sz := size()
		return sz width < sz height ? NSize new(sz width, sz width) : NSize new(sz height, sz height)
	}
	
	draw: func (renderer: NRenderer) {
		frm := _buttonSize() toRect()
		drawButton(renderer, frm)
		drw := drawable()
		if (_checked && drw) {
		    frm origin y += _pressFade value()
			drw drawInRect(renderer, frm, 4)
		}
		renderer saveState()
		drawCaption(renderer)
		renderer restoreState()
	}
	
	drawCaption: func (renderer: NRenderer) {
		fnt := font()
		if (fnt) {
			sz := _buttonSize()
			pos := NPoint new(sz width+2, (sz height - fnt sizeOfText(caption()) height)*0.5  + fnt ascender() + fnt descender())
			renderer applyFillColor(NColor white())
			renderer drawText(caption(), fnt, pos)
		}
	}
}
