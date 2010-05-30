import structs/HashMap
import View

NEventHandler: abstract class {
    fire: abstract func (sender: NView, event: String, data: HashMap<String, Object>)
}

NClosureEventHandler: class {
    _closure: Func (NView, String, HashMap<String, Object>)
    
    init: func (=_closure) {}
    
    fire: func (sender: NView, event: String, data: HashMap<String, Object>) {
        _closure(sender, event, data)
    }
}
