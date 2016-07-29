//: Playground - noun: a place where people can play

import Cocoa
import XCPlayground

var str = "Hello, playground"
let frame = CGRect(x: 0, y: 0, width: 300, height: 300)

let view = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))

XCPlayground.XCPlaygroundPage.currentPage.liveView = view


