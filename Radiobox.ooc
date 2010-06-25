import Types, GUI, View, Checkbox, Renderer

NRadiobox: class extends NCheckbox {
	
	_groupID: Int = 0
	
	init: super func
	
	_loadDefaultDrawables: func {
        setDrawable(_gui skin() drawableForName("Radiobox"))
    }
	
	setGroup: func (=_groupID) { }
	group: func -> Int { _groupID }
	
	_buttonAction: func {
		setChecked(true)
	}
	
	setChecked: func (checked: Bool) {
		super(checked)
		if (checked()) {
			for (view in superview() subviews) {
				if (view != this && view instanceOf(NRadiobox) && view as NRadiobox group() == _groupID) {
					view as NRadiobox setChecked(false)
				}
			}
		}
	}
}


