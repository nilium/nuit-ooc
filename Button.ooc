import Types, GUI, View, Renderer, Drawable

NButtonPressedEvent := const "ButtonPressedEvent"

NButton: class extends NView {
    _caption := ""
    _pressed := false
    _over := false
    
    init: super func
    
    setCaption: func (._caption) {
        if (_caption != null)
            this _caption = _caption clone()
        else
            this _caption = _caption
    }
    
    caption: func -> String {
        _caption
    }
    
    mousePressed: func (button: Int, position: NPoint) {
        if (button == 1) {
            _pressed = true
            _over = true
        }
    }
    
    mouseMoved: func (pos: NPoint, delta: NPoint) {
        _over = bounds() contains(pos)
    }
    
    mouseReleased: func (button: Int, pos: NPoint) {
        if (button == 1 && _pressed) {
            _pressed = false
            if (_over) {
                __onPress()
            }
        }
    }
    
    mouseEntered: func {
        _over = true
    }
    
    mouseLeft: func {
        _over = false
    }
    
    draw: func (renderer: NRenderer) {
        drw := drawable()
        if (drw) {
            drw drawInRect(renderer, size() toRect(), 3*(disabled?(true) as Int))
            if (_over||_pressed)
                drw drawInRect(renderer, size() toRect(), _over as Int + _pressed)
        }
        
        font := font()
        if (font && _caption) {
            sz := font sizeOfText(_caption)
            pos := size() toPoint()
            pos subtract(sz toPoint())
            pos x *= 0.5
            pos y *= 0.5
            pos y += font ascender()
            // something to note: when drawing text, floor the position
            pos x = pos x floor()
            pos y = pos y floor()
            
            renderer drawText(_caption, font, pos)
        }
    }
    
    // override for different event names in button subclasses
    _firePressEvent: func {
        _fireEvent(NButtonPressedEvent, null)
    }
    
    __onPress: func {
        _firePressEvent()
        onPress()
    }
    
    // for others to override
    onPress: func {}
}
