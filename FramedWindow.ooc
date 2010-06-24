import GUI
import Drawable
import Types
import Window
import Renderer

NFramedWindow: class extends NWindow {
    _dragging := 0
    _drag_point: NPoint
    _caption := ""
    
    init: func (gui: NGUI, frame: NRect) {
        super(gui, frame)
        setMinimumSize(NSize new(40.0, 40.0))
        setMinimumSizeEnabled(true)
    }
    
    draw: func (renderer: NRenderer) {
        drw := drawable()
        if (drw != null) {
            // Only draw the title and shadow if we have a frame to begin with
            
            frame: Int = (isMainWindow?() ? 0 : 1)
            drw drawInRect(renderer, NRect new(NPoint zero(), size()), frame)
            
            font := font()
            if (font && _caption) {
                renderer saveState()
                origin := renderer drawingOrigin()
                origin x += 2
                origin y += 2
                renderer enableClipping()
                renderer clipRegion(NRect new(origin, NSize new(size() width-4, 22.0)))
                sz := font sizeOfText(_caption)
                asc := font ascender()
                pos := NPoint new(_bounds_topLeft width + (((size() width - (_bounds_topLeft width + _bounds_bottomRight width)) - sz width)*0.5) floor(), (_bounds_topLeft height - sz height)*0.5 + font ascender() + font descender())
                renderer drawText(_caption, font, pos)
                renderer restoreState()
            }
        }
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
        if (_dragging != 0) {
            frame := frame()
            if (_dragging == 1) {
                frame origin add(delta)
            } else {
                to add(_drag_point)
                frame size = to toSize()
            }
            setFrame(frame)
        }
    }
    
    mouseReleased: func (button: Int, position: NPoint) {
        if (button == 1) {
            _dragging = 0
        }
    }
    
    bounds: func -> NRect {
        bounds: NRect
        bounds origin set(1.0, 24.0)
        bounds size = size()
        bounds size subtract(bounds origin toSize())
        bounds size width -= 1
        bounds size height -= 1
        return bounds
        
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
}
