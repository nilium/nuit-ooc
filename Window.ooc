import GUI
import Types
import View

NWindow: class extends NView {
    init: super func
    
    _contentView: NView
    
    canBecomeMainWindow?: func -> Bool {true}
    
    becameMainWindow: func {}
    lostMainWindow: func {}
    
    isMainWindow?: func -> Bool {
        _gui mainWindow() == this
    }
    
    setContentView: func (view: NView) {
        if (_contentView)
            _contentView removeFromSuperview()
        _contentView = view
        if (view)
            addSubview(view)
        performLayout()
    }
    
    setFrame: func (frame: NRect) {
        super(frame)
        performLayout()
    }
    
    setBounds: func (tl, br: NSize) {
        super(tl, br)
        performLayout()
    }
    
    performLayout: func {
        if (_contentView)
            _contentView setFrame(bounds() size toRect())
    }
}
