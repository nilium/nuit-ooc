import Types, GUI, View, Button, Renderer, Drawable

NCheckbox: class extends NButton {
    _checked := false
    
    init: super func
    
    _buttonAction: func {
        setChecked(!checked())
    }
    
    setChecked: func (=_checked) {}
    checked: func -> Bool { _checked }
    
    _buttonSize: func -> NSize {
        sz := size()
        return sz width < sz height ? NSize new(sz width, sz width) : NSize new(sz height, sz height)
    }
    
    draw: func (renderer: NRenderer) {
        renderer saveState()
        frm := _buttonSize() toRect()
        drawButton(renderer, frm)
        drw := drawable()
        renderer restoreState()
        if (_checked && drw) {
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
            pos := NPoint new(sz width+2, (sz height + fnt ascender())*0.5)
            renderer setFillColor(NColor white())
            renderer drawText(caption(), fnt, pos)
        }
    }
}