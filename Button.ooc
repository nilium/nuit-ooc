import Types, GUI, View, Renderer, Drawable, AnimatedValue

NButtonPressedEvent := const "ButtonPressedEvent"

NButton: class extends NView {
    _caption := ""
    
    _pressed := false
    _over := false
    
    _pressFade := NAnimatedValue new(0.0, 0.0, 80, true)
    _hiliteFade := NAnimatedValue new(0.0, 0.0, 80, true)
    
    init: super func
    
    _loadDefaultDrawables: func {
        setDrawable(_gui skin() drawableForName("Button"))
    }
    
    setCaption: func (._caption) {
        if (_caption != null)
            this _caption = _caption clone()
        else
            this _caption = _caption
    }
    
    caption: func -> String {
        _caption
    }
    
    mousePressed: func (button: Int, position: NPoint) -> NView {
        if (button == 1) {
            _pressed = true
            _pressFade setInitial(_pressFade value()).
                        setTarget(1.0).
                        restart()
            return this
        }
        return forwardMousePressedEvent(button, position)
    }
    
    mouseMoved: func (pos: NPoint, delta: NPoint) {
        if (_pressed) {
            over := size() contains(pos)
            if (over != _over) {
                _pressFade setInitial(_pressFade value())
                if (_pressed && over)
                    _pressFade setTarget(1.0)
                else
                    _pressFade setTarget(0.0)
                _pressFade restart()
            }
            _over = over
        }
    }
    
    mouseReleased: func (button: Int, pos: NPoint) {
        if (button == 1 && _pressed) {
            _pressed = false
            _pressFade setInitial(_pressFade value()).
                        setTarget(0.0).
                        restart()
            
            if (_over) {
                __onPress()
            }
        }
    }
    
    mouseEntered: func {
        _over = true
        _hiliteFade setInitial(_hiliteFade value()).
                    setTarget(1.0).
                    restart()
    }
    
    mouseLeft: func {
        _over = false
        _hiliteFade setInitial(_hiliteFade value()).
                    setTarget(0.0).
                    restart()
    }
    
    drawButton: func (renderer: NRenderer, inRect: NRect) {
        drw := drawable()
        if (drw) {
            renderer saveState()
            drw drawInRect(renderer, size() toRect(), 3*(disabled?(true) as Int))
            
            pressedAlpha := _pressFade value() as NFloat
            overAlpha := (_hiliteFade value() * (1.0 - pressedAlpha)) as NFloat
            
            renderer applyFillColor(NColor white(overAlpha))
            drw drawInRect(renderer, size() toRect(), 1)
            
            renderer applyFillColor(NColor white(pressedAlpha))
            drw drawInRect(renderer, size() toRect(), 2)
            renderer restoreState()
        }
    }
    
    draw: func (renderer: NRenderer) {
        drawButton(renderer, size() toRect())
        
        font := font()
        if (font && _caption) {
            sz := font sizeOfText(_caption)
            pos := size() toPoint()
            pos subtract(sz toPoint())
            pos x *= 0.5
            pos y *= 0.5
            pos y += font ascender() + font descender() + (_pressed&&_over)
            // something to note: when drawing text, floor the position
            pos x = pos x floor()
            pos y = pos y floor()
            
            renderer applyFillColor(NColor white(1.0))
            renderer drawText(_caption, font, pos)
        }
    }
    
    // override for different actions occurring when the button is pressed.
    // this is some bit of code that must always occur when the button is
    // pressed
    _buttonAction: func {}
    
    // override for different event names in button subclasses
    __firePressEvent: func {
        _fireEvent(NButtonPressedEvent, null)
    }
    
    __onPress: func {
        _buttonAction()
        onPress()
        __firePressEvent()
    }
    
    // user override
    // similar to _buttonAction, except this can be overridden without
    // modifying the core functionality of the button
    onPress: func {}
}
