import Types
import View

NWindow: class extends NView {
    init: func (frame: NRect) {
        super(frame)
    }
    
    canBecomeMainWindow?: func -> Bool {true}
    
    becameMainWindow: func {}
    lostMainWindow: func {}
}
