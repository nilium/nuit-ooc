import Types, GUI, View, ScrollBar, Drawable, Renderer

_NSVClipView: class extends NView {
	init: super func
	
	clipsSubviews: func -> Bool {
		true
	}
	
    mousePressed: func (button: Int, point: NPoint) -> NView {
	    forwardMousePressedEvent(button, point)
	}
	
	mouseReleased: func (button: Int, point: NPoint) {
	    forwardMouseReleasedEvent(button, point)
	}
	
	mouseMoved: func (point, delta: NPoint) {
	    forwardMouseMovedEvent(point, delta)
	}
}

_NSVHScrollBar: class extends NHScrollBar {
	init: super func
	
	_scrollAction: func (prev: NFloat) {
		sv := superview() as NScrollView
		clipView := sv clipView
		clip := clipView bounds width()
		contentView := sv contentView()
		contentFrame := contentView frame()
		contentFrame origin x = (percentage() * (clip - contentFrame width())) floor()
		contentView setFrame(contentFrame)
	}
}

_NSVVScrollBar: class extends NVScrollBar {
	init: super func
	
	_scrollAction: func (prev: NFloat) {
		sv := superview() as NScrollView
		clipView := sv clipView
		clip := clipView bounds() height()
		contentView := sv contentView()
		contentFrame := contentView frame()
		contentFrame origin y = (percentage() * (clip - contentFrame height())) floor()
		contentView setFrame(contentFrame)
	}
}

NScrollView: class extends NView {
	_contentView: NView = null
	_cviewSize: NSize
	clipView: _NSVClipView
	hscroll: NHScrollBar
	vscroll: NVScrollBar
	
	scrollBarSize = 20.0: NFloat
	retainCorner := true
	
	init: func (=_gui, frame: NRect) {
		clipView = _NSVClipView new(_gui, NRect zero())
		hscroll = _NSVHScrollBar new(_gui, NRect zero())
		vscroll = _NSVVScrollBar new(_gui, NRect zero())
		
		super(_gui, frame)
		
		addSubview(hscroll)
		addSubview(vscroll)
		addSubview(clipView)
	}
	
	setContentView: func (view: NView) {
		if (_contentView)
			_contentView removeFromSuperview()
		
		_contentView = view
		
		if (view) {
			view setFrame(view size() toRect())
			clipView addSubview(view)
		}
		
		performLayout()
	}
	
	contentView: func -> NView { _contentView }
	
	performLayout: func {
		if (!(clipView && hscroll && vscroll))
			return
		
		if (_contentView == null || _contentView hidden?(false)) {
			clipView hide()
			hscroll hide()
			vscroll hide()
			return
		}
		
		ssz := scrollBarSize
		sbsz := NSize new(ssz, ssz)
		
		clipView show()
		hscroll show()
		vscroll show(). enable()
		
		if (retainCorner)
		    sbsz = sbsz max(_gui skin() sizeForName("FramedWindowResizer"))
		
		clipSize := size()
		clipSize subtract(sbsz)
		
		contentFrame := _contentView frame()
		
		if (contentFrame right() < clipSize width) {
		    contentFrame origin x = (contentFrame x() + (clipSize width - contentFrame right())) min(0.0) floor()
		    hscroll setValue(contentFrame width())
		}
		
		if (contentFrame width() <= clipSize width) {
		    hscroll setValue(0.0). hide()
		    clipSize height += sbsz height
		}
		
		if (contentFrame bottom() < clipSize height) {
		    contentFrame origin y = (contentFrame y() + (clipSize height - contentFrame bottom())) min(0.0) floor()
		    vscroll setValue(contentFrame height())
		}
		
		if (contentFrame height() <= clipSize height) {
		    vscroll setValue(0.0)
	        vscroll hide()
		    clipSize width += sbsz width
		}
		
		hscroll setMax(contentFrame width()).
		    setScrollSize(clipSize width).
		    setPercentage(0.0-(contentFrame x()) / (contentFrame width() - clipSize width())).
		    setFrame(NRect new(0.0, clipSize height, !retainCorner ? clipSize width : (size() width - sbsz width), ssz))
		
		vscroll setMax(contentFrame height()).
		    setScrollSize(clipSize height).
		    setPercentage(0.0-(contentFrame y()) / (contentFrame height() - clipSize height())).
		    setFrame(NRect new(clipSize width, 0.0, ssz, !retainCorner ? clipSize height : (size() height - sbsz height)))
		
		_contentView setFrame(contentFrame)
		clipView setFrame(clipSize toRect())
	}
	
	mousePressed: func (button: Int, point: NPoint) -> NView {
	    forwardMousePressedEvent(button, point)
	}
	
	mouseReleased: func (button: Int, point: NPoint) {
	    forwardMouseReleasedEvent(button, point)
	}
	
	mouseMoved: func (point, delta: NPoint) {
	    forwardMouseMovedEvent(point, delta)
	}
	
	setFrame: func (frame: NRect) {
		super(frame)
		performLayout()
	}
}
