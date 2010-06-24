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


/* this is going to be the most fun thing to implement ever */
NSkin: abstract class {
    fontForName: abstract func (name: String) -> NFont
    imageForName: abstract func (name: String) -> NImage
    drawableForName: abstract func (name: String) -> NDrawable
    numberForName: abstract func (name: String) -> NFloat
    stringForName: abstract func (name: String) -> String
    colorForName: abstract func (name: String) -> NColor
    pointForName: abstract func (name: String) -> NPoint
    sizeForName: abstract func (name: String) -> NSize
    rectForName: abstract func (name: String) -> NRect
    boolForName: abstract func (name: String) -> Bool
    
    numberForName: final func ~default (name: String, deflt: NFloat) -> NFloat {
        hasNumberForName?(name) ? numberForName(name) : deflt
    }
    stringForName: final func ~default (name: String, deflt: String) -> String {
        val := stringForName(name)
        if (val != null)
            return val
        return deflt
    }
    colorForName: final func ~default (name: String, deflt: NColor) -> NColor {
        hasColorForName?(name) ? colorForName(name) : deflt
    }
    pointForName: final func ~default (name: String, deflt: NPoint) -> NPoint {
        hasPointForName?(name) ? pointForName(name) : deflt
    }
    sizeForName: final func ~default (name: String, deflt: NSize) -> NSize {
        hasSizeForName?(name) ? sizeForName(name) : deflt
    }
    rectForName: final func ~default (name: String, deflt: NRect) -> NRect {
        hasRectForName?(name) ? rectForName(name) : deflt
    }
    boolForName: final func ~default (name: String, deflt: Bool) -> Bool {
        hasBoolForName?(name) ? boolForName(name) : deflt
    }
    
    hasNumberForName?: abstract func (name: String) -> Bool
    hasColorForName?: abstract func (name: String) -> Bool
    hasPointForName?: abstract func (name: String) -> Bool
    hasSizeForName?: abstract func (name: String) -> Bool
    hasRectForName?: abstract func (name: String) -> Bool
    hasBoolForName?: abstract func (name: String) -> Bool
}

NMultiSkin: class extends NSkin {
    __skins := LinkedList<NSkin> new()
    
    addSkin: func (skin: NSkin) {
        __skins add(skin)
    }
    
    fontForName: func (name: String) -> NFont {
        for (skin: NSkin in __skins) {
            if (skin == null)
                continue
            res := skin fontForName(name)
            if (res) return res
        }
        return null
    }
    
    imageForName: func (name: String) -> NImage {
        for (skin: NSkin in __skins) {
            if (skin == null)
                continue
            res := skin imageForName(name)
            if (res) return res
        }
        return null
    }
    
    drawableForName: func (name: String) -> NDrawable {
        for (skin: NSkin in __skins) {
            if (skin == null)
                continue
            res := skin drawableForName(name)
            if (res) return res
        }
        return null
    }
    
    numberForName: func (name: String) -> NFloat {
        for (skin: NSkin in __skins) {
            if (skin == null || !skin hasNumberForName?(name))
                continue
            return skin numberForName(name)
        }
        return 0.0
    }
    
    stringForName: func (name: String) -> String {
        for (skin: NSkin in __skins) {
            if (skin == null)
                continue
            res := skin stringForName(name)
            if (res) return res
        }
        return null
    }
    
    colorForName: func (name: String) -> NColor {
        for (skin: NSkin in __skins) {
            if (skin == null || !skin hasColorForName?(name))
                continue
            return skin colorForName(name)
        }
        return NColor black(0.0)
    }
    
    pointForName: func (name: String) -> NPoint {
        for (skin: NSkin in __skins) {
            if (skin == null || !skin hasPointForName?(name))
                continue
            return skin pointForName(name)
        }
        return NPoint zero()
    }
    
    sizeForName: func (name: String) -> NSize {
        for (skin: NSkin in __skins) {
            if (skin == null || !skin hasSizeForName?(name))
                continue
            return skin sizeForName(name)
        }
        return NSize zero()
    }
    
    rectForName: func (name: String) -> NRect {
        for (skin: NSkin in __skins) {
            if (skin == null || !skin hasRectForName?(name))
                continue
            return skin rectForName(name)
        }
        return NRect zero()
    }
}

NBasicSkin: class extends NSkin {
    _table := HashMap<String, Cell<Pointer>> new(64)
    
    _key: func (T: Class, name: String) -> String {
        "%s_%s" format(T name, name)
    }
    
    _contains: func <T> (name: String, T: Class) -> Bool {
        cell := _table get(_key(T, name))
        return cell != null
    }
    
    _insert: func <T> (name: String, value: T) {
        _table put(_key(T, name), Cell<T> new(value))
    }
    
    _get: func <T> (name: String, T: Class) -> T {
        cell := _table get(_key(T, name)) as Cell<T>
        if (cell != null)
            return cell val
        return null
    }
    
    addFont: func (name: String, font: NFont) {
        _insert(name, font)
    }
    
    fontForName: func (name: String) -> NFont {
        _get(name, NFont)
    }
    
    addImage: func (name: String, image: NImage) {
        _insert(name, image)
    }
    
    imageForName: func (name: String) -> NImage {
        _get(name, NImage)
    }
    
    addDrawable: func (name: String, drawable: NDrawable) {
        _insert(name, drawable)
    }
    
    drawableForName: func (name: String) -> NDrawable {
        _get(name, NDrawable)
    }
    
    addNumber: func (name: String, num: NFloat) {
        _insert(name, num)
    }
    
    hasNumberForName?: func (name: String) -> Bool {
        _contains(name, NFloat)
    }
    
    numberForName: func (name: String) -> NFloat {
        _get(name, NFloat)
    }
    
    addString: func (name: String, str: String) {
        _insert(name, str)
    }
    
    stringForName: func (name: String) -> String {
        _get(name, String)
    }
    
    addColor: func (name: String, clr: NColor) {
        _insert(name, clr)
    }
    
    hasColorForName?: func (name: String) -> Bool {
        _contains(name, NColor)
    }
    
    colorForName: func (name: String) -> NColor {
        _get(name, NColor)
    }
    
    hasPointForName?: func (name: String) -> Bool {
        _contains(name, NPoint)
    }
    
    pointForName: func (name: String) -> NPoint {
        _get(name, NPoint)
    }
    
    addPoint: func (name: String, point: NPoint) {
        _insert(name, point)
    }
    
    hasSizeForName?: func (name: String) -> Bool {
        _contains(name, NSize)
    }
    
    sizeForName: func (name: String) -> NSize {
        _get(name, NSize)
    }
    
    addSize: func (name: String, size: NSize) {
        _insert(name, size)
    }
    
    hasRectForName?: func (name: String) -> Bool {
        _contains(name, NRect)
    }
    
    rectForName: func (name: String) -> NRect {
        _get(name, NRect)
    }
    
    addRect: func (name: String, rect: NRect) {
        _insert(name, rect)
    }
    
    hasBoolForName?: func (name: String) -> Bool {
        _contains(name, Bool)
    }
    
    boolForName: func (name: String) -> Bool {
        _get(name, Bool)
    }
    
    addBool: func (name: String, val: Bool) {
        _insert(name, val)
    }
}

NNullSkin: class extends NSkin {
	fontForName: func (name: String) -> NFont { null }
    imageForName: func (name: String) -> NImage { null }
    drawableForName: func (name: String) -> NDrawable { null }
    numberForName: func (name: String) -> NFloat { 0.0 }
    stringForName: func (name: String) -> String { null }
    colorForName: func (name: String) -> NColor { NColor black(0.0) }
    pointForName: func (name: String) -> NPoint { NPoint zero() }
    sizeForName: func (name: String) -> NSize { NSize zero() }
    rectForName: func (name: String) -> NRect { NRect zero() }
    boolForName: func (name: String) -> Bool { false }
    
    hasNumberForName?: func (name: String) -> Bool { false }
    hasColorForName?: func (name: String) -> Bool { false }
    hasPointForName?: func (name: String) -> Bool { false }
    hasSizeForName?: func (name: String) -> Bool { false }
    hasRectForName?: func (name: String) -> Bool { false }
    hasBoolForName?: func (name: String) -> Bool { false }
}
