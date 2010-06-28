import Types, GUI, View, Renderer, AnimatedValue

NViewSwitcher: class extends NView {
    _currentIndex: Int = 0
    _prev, _currentView: NView
    _switchInterp := NAnimatedValue new(0.0, 1.0, 150)
    
    init: super func
    
    drawSubviews: func (renderer: NRenderer) {
        if (0 == subviews size())
            _currentView = subviews get(0)
        else if (_currentView == null)
            return
        
        renderer saveState()
        _prepSubviewsDrawing(renderer)
        
        if (_switchInterp running?() && (_currentView || _prev)) {
            bounds := bounds()
            delta := _switchInterp value() as NFloat
            dwidth := delta * bounds width()
            
            bounds origin set(-dwidth, 0.0)
//            bounds origin += renderer drawingOrigin()
            
            if (_prev) {
                renderer saveState()
                renderer translateDrawingOrigin(bounds origin)
                renderer clipRegion(bounds)
                drawSubview(renderer, _prev)
                renderer restoreState()
            }
            
            if (_currentView) {
                bounds origin x += bounds size width
                renderer translateDrawingOrigin(bounds origin)
                renderer clipRegion(bounds)
                drawSubview(renderer, _currentView)
            }
        } else if (_currentView) {
            if (_prev && _prev != _currentView) _prev hide()
            drawSubview(renderer, _currentView)
        }
        renderer restoreState()
    }
    
/*    viewForPoint: func (point: NPoint) -> NView {
        res := super(point)
        if (res != null && res != this) {
            if (_currentView == null || res == _currentView || res isSubviewOf(_currentView))
                return null
        }
        
        return res
    } */
    
    clipsSubviews: func -> Bool { true }
    
    showView: func (view: NView) {
        if (view == _currentView)
            return
        
        if (!subviews contains(view))
            Exception new(This, "Specified view is not a subview of the view switcher")
        
        _prev = _currentView
        _currentView = view
        
        if (view)
            view show()
        
        _switchInterp restart()
    }
    
    showView: func ~index (view: Int) {
        if (view < 0 || subviews size() <= view)
            showView(null)
        else
            showView(subviews get(view))
    }
    
    addSubview: func (view: NView) {
        super(view)
        if (subviews size() == 1)
            _currentView = view
    }
}
