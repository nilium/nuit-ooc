import structs/[HashMap, LinkedList]
import Types, Drawable, Font, Image

NAbstractSkinFactory: abstract class {
    loadSkin: abstract func (url: String) -> NSkin
}

NSkinFactoryManager: class {
    __factories := LinkedList<NAbstractSkinFactory> new()
    
    addFactory: func (factory: NAbstractSkinFactory) {
        __factories add(factory)
    }
    
    removeFactory: func (factory: NAbstractSkinFactory) -> Bool {
        __factories remove(factory)
    }
    
    loadSkin: func (url: String) -> NSkin {
        for (factory: NAbstractSkinFactory in __factories) {
            skin := factory loadSkin(url)
            if (skin) return skin
        }
        return null
    }
}
NSkinFactory := NSkinFactoryManager new()

NSkin: abstract class {
    fontForName: abstract func (name: String, deflt: NFont) -> NFont
    imageForName: abstract func (name: String, deflt: NImage) -> NImage
    drawableForName: abstract func (name: String, deflt: NDrawable) -> NDrawable
    numberForName: abstract func (name: String, deflt: NFloat) -> NFloat
    stringForName: abstract func (name: String, deflt: String) -> String
    colorForName: abstract func (name: String, deflt: NColor) -> NColor
    fontForName: final func ~deflt (name: String) -> NFont { fontForName(name, null) }
    imageForName: final func ~deflt (name: String) -> NImage { imageForName(name, null) }
    drawableForName: final func ~deflt (name: String) -> NDrawable { drawableForName(name, null) }
    numberForName: final func ~deflt (name: String) -> NFloat { numberForName(name, 0.0) }
    stringForName: final func ~deflt (name: String) -> String { stringForName(name, null) }
    colorForName: final func ~deflt (name: String) -> NColor { colorForName(name, NColor new()) }
    
    hasNumberForName?: abstract func (name: String) -> Bool
    hasColorForName?: abstract func (name: String) -> Bool
}

NMultiSkin: class extends NSkin {
    __skins := LinkedList<NSkin> new()
    
    addSkin: func (skin: NSkin) {
        __skins add(skin)
    }
    
    fontForName: func (name: String, deflt: NFont) -> NFont {
        for (skin: NSkin in __skins) {
            if (skin == null)
                continue
            res := skin fontForName(name)
            if (res) return res
        }
        return deflt
    }
    
    imageForName: func (name: String, deflt: NImage) -> NImage {
        for (skin: NSkin in __skins) {
            if (skin == null)
                continue
            res := skin imageForName(name)
            if (res) return res
        }
        return deflt
    }
    
    drawableForName: func (name: String, deflt: NDrawable) -> NDrawable {
        for (skin: NSkin in __skins) {
            if (skin == null)
                continue
            res := skin drawableForName(name)
            if (res) return res
        }
        return deflt
    }
    
    numberForName: func (name: String, deflt: NFloat) -> NFloat {
        for (skin: NSkin in __skins) {
            if (skin == null || !skin hasNumberForName?(name))
                continue
            return skin numberForName(name)
        }
        return deflt
    }
    
    stringForName: func (name: String, deflt: String) -> String {
        for (skin: NSkin in __skins) {
            if (skin == null)
                continue
            res := skin stringForName(name)
            if (res) return res
        }
        return deflt
    }
    
    colorForName: func (name: String, deflt: NColor) -> NColor {
        for (skin: NSkin in __skins) {
            if (skin == null || !skin hasColorForName?(name))
                continue
            return skin colorForName(name)
        }
        return deflt
    }
}

NBasicSkin: class extends NSkin {
    _fonts := HashMap<String, NFont> new(4)
    _images := HashMap<String, NImage> new(16)
    _drawables := HashMap<String, NDrawable> new(16)
    _strings := HashMap<String, String> new(16)
    _numbers := HashMap<String, NFloat> new(16)
    _colors := HashMap<String, NColor> new(16)
    
    addFont: func (name: String, font: NFont) {
        _fonts put(name, font)
    }
    
    fontForName: func (name: String, deflt: NFont) -> NFont {
        if (_fonts contains(name))
            return _fonts get(name)
        return deflt
    }
    
    addImage: func (name: String, image: NImage) {
        _images put(name, image)
    }
    
    imageForName: func (name: String, deflt: NImage) -> NImage {
        if (_images contains(name))
            return _images get(name)
        return deflt
    }
    
    addDrawable: func (name: String, drawable: NDrawable) {
        _drawables put(name, drawable)
    }
    
    drawableForName: func (name: String, deflt: NDrawable) -> NDrawable {
        if (_drawables contains(name))
            return _drawables get(name)
        return deflt
    }
    
    addNumber: func (name: String, num: NFloat) {
        _numbers put(name, num)
    }
    
    hasNumberForName?: func (name: String) -> Bool {
        _numbers contains(name)
    }
    
    numberForName: func (name: String, deflt: NFloat) -> NFloat {
        if (hasNumberForName?(name))
            return _numbers get(name)
        return deflt
    }
    
    addString: func (name: String, str: String) {
        _strings put(name, str)
    }
    
    stringForName: func (name: String, deflt: String) -> String {
        if (_strings contains(name))
            return _strings get(name)
        return deflt
    }
    
    addColor: func (name: String, clr: NColor) {
        _colors put(name, clr)
    }
    
    hasColorForName?: func (name: String) -> Bool {
        _colors contains(name)
    }
    
    colorForName: func (name: String, deflt: NColor) -> NColor {
        if (hasColorForName?(name))
            return _colors get(name)
        return deflt
    }
}

NNullSkin: class extends NSkin {
	fontForName: func (name: String, deflt: NFont) -> NFont { deflt }
    imageForName: func (name: String, deflt: NImage) -> NImage { deflt }
    drawableForName: func (name: String, deflt: NDrawable) -> NDrawable { deflt }
    numberForName: func (name: String, deflt: NFloat) -> NFloat { deflt }
    stringForName: func (name: String, deflt: String) -> String { deflt }
    colorForName: func (name: String, deflt: NColor) -> NColor { deflt }
    hasNumberForName?: func (name: String) -> Bool { false }
    hasColorForName?: func (name: String) -> Bool { false }
}
