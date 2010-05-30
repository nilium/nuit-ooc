import Drawable
import Types
import Window
import Renderer

NFramedWindow: class extends NWindow {
    _drawable: NDrawable = null
    _dragging := 0
    _drag_point: NPoint
    
    init: func (frame: NRect) {
        super(frame)
    }
    
    draw: func (renderer: NRenderer) {
        if (_drawable != null)
            _drawable drawInRect(renderer, NRect new(NPoint zero(), size()), 0)
    }
    
    mousePressed: func (button: Int, position: NPoint) {
        if (button == 1) {
            region: NRect
            
            region size = size()
            region set(region width() - 20.0, region height() - 20.0, 20.0, 20.0)
            if (region contains(position)) {
                _dragging = 2
                _drag_point = size() toPoint()
                _drag_point subtract(position)
                return
            }
            
            region = frame()
            region origin = NPoint zero()
            region size height = 24.0
            if (region contains(position)) {
                _dragging = 1
                return
            }
        }
        
        super(button, position)
    }
    
    mouseMoved: func (to: NPoint, delta: NPoint) {
        if (_dragging == 1) {
            frame := frame()
            frame origin add(delta)
            setFrame(frame)
        } else if (_dragging == 2) {
            frame := frame()
            to add(_drag_point)
            frame size = to toSize()
            setFrame(frame)
        }
    }
    
    mouseReleased: func (button: Int, position: NPoint) {
        if (button == 1) {
            _dragging = 0
        }
    }
}
