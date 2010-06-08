import GUI
import Types
import View

NWindow: class extends NView {
    init: super func
    
    canBecomeMainWindow?: func -> Bool {true}
    
    becameMainWindow: func {}
    lostMainWindow: func {}
    
    isMainWindow?: func -> Bool {
        _gui mainWindow() == this
    }
}
