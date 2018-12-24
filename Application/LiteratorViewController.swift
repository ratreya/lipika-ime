/*
 * LipikaApp is companion application for LipikaIME.
 * Copyright (C) 2018 Ranganath Atreya
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */

import Cocoa
import LipikaEngine_OSX

extension NSView {
    class func getAllSubviews<T: NSView>(view: NSView) -> [T] {
        return view.subviews.flatMap { subView -> [T] in
            var result = getAllSubviews(view: subView) as [T]
            if let view = subView as? T {
                result.append(view)
            }
            return result
        }
    }
    
    func getAllSubviews<T: NSView>() -> [T] {
        return NSView.getAllSubviews(view: self) as [T]
    }
}

class LiteratorViewController: NSViewController, NSTextViewDelegate {
    
    @IBOutlet weak var isInputScheme: NSButton!
    @IBOutlet weak var isInputScript: NSButton!
    @IBOutlet weak var isOutputScheme: NSButton!
    @IBOutlet weak var isOutputScript: NSButton!
    
    @IBOutlet weak var inputScheme: NSPopUpButton!
    @IBOutlet weak var inputScript: NSPopUpButton!
    @IBOutlet weak var outputScheme: NSPopUpButton!
    @IBOutlet weak var outputScript: NSPopUpButton!
    
    var splitView: NSSplitView!
    var input: NSTextView!
    var output: NSTextView!
    
    private let config = LipikaConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let factory = try! LiteratorFactory(config: config)
        inputScheme.addItems(withTitles: try! factory.availableSchemes())
        outputScheme.addItems(withTitles: try! factory.availableSchemes())
        inputScript.addItems(withTitles: try! factory.availableScripts())
        inputScript.insertItem(withTitle: "Autodetect...", at: 0)
        outputScript.addItems(withTitles: try! factory.availableScripts())

        inputScheme.selectItem(withTitle: config.schemeName)
        inputScript.selectItem(at: 0)
        outputScript.selectItem(withTitle: config.scriptName)
        outputScheme.selectItem(withTitle: config.schemeName)

        isInputScript.state = .off
        inputScript.isEnabled = false
        isOutputScheme.state = .off
        outputScheme.isEnabled = false
        isInputScheme.state = .on
        isOutputScript.state = .on
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let controller = segue.destinationController as? NSSplitViewController {
            splitView = controller.splitView
        }
    }
    
    override func viewWillAppear() {
        let textViews:[NSTextView] = splitView.getAllSubviews()
        input = textViews.first
        output = textViews.last
        input.delegate = self
        output.delegate = self
    }

    @IBAction func inputSchemeSelected(_ sender: NSButton) {
        isInputScheme.state = .on
        isInputScript.state = .off
        inputScheme.isEnabled = true
        inputScript.isEnabled = false
        reload()
    }
    
    @IBAction func inputScriptSelected(_ sender: NSButton) {
        isInputScheme.state = .off
        isInputScript.state = .on
        inputScheme.isEnabled = false
        inputScript.isEnabled = true
        reload()
    }
    
    @IBAction func outputSchemeSelected(_ sender: NSButton) {
        isOutputScheme.state = .on
        isOutputScript.state = .off
        outputScheme.isEnabled = true
        outputScript.isEnabled = false
        reload()
    }
    
    @IBAction func ouputScriptSelected(_ sender: NSButton) {
        isOutputScheme.state = .off
        isOutputScript.state = .on
        outputScheme.isEnabled = false
        outputScript.isEnabled = true
        reload()
    }
    
    @IBAction func selectionChanged(_ sender: NSPopUpButton) {
        reload()
    }
    
    func textDidChange(_ notification: Notification) {
        reload()
    }
    
    private func reload() {
        let factory = try! LiteratorFactory(config: config)
        if isInputScript.state == .on {
            let schemeName = isOutputScheme.isEnabled ? outputScheme.selectedItem!.title : "Barahavat"
            let anteliterator = try! factory.anteliterator(schemeName: schemeName, scriptName: inputScript.selectedItem!.title)
            let anteliterated = anteliterator.anteliterate(input.string)
            if isOutputScheme.state == .on {
                output.string = anteliterated
            }
            else {
                let transliterator = try! factory.transliterator(schemeName: schemeName, scriptName: outputScript.selectedItem!.title)
                let transliterated = transliterator.transliterate(anteliterated)
                output.string = transliterated.finalaizedOutput + transliterated.unfinalaizedOutput
            }
        }
        else {
            let scriptName = isOutputScript.isEnabled ? outputScript.selectedItem!.title : "Devanagari"
            let transliterator = try! factory.transliterator(schemeName: inputScheme.selectedItem!.title, scriptName: scriptName)
            let transliterated = transliterator.transliterate(input.string)
            if isOutputScript.state == .on {
                output.string = transliterated.finalaizedOutput + transliterated.unfinalaizedOutput
            }
            else {
                let anteliterator = try! factory.anteliterator(schemeName: outputScheme.selectedItem!.title, scriptName: scriptName)
                output.string = anteliterator.anteliterate(transliterated.finalaizedOutput + transliterated.unfinalaizedOutput)
            }
        }
    }
}
