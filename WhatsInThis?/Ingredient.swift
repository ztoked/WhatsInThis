//
//  Ingredient.swift
//  WhatsInThis?
//
//  Created by Zach Halvorsen on 6/27/16.
//  Copyright © 2016 Halvorsen Games. All rights reserved.
//

import Foundation

class Ingredient {
    
    enum Measure: String {
        case NOTHING = "NOTHING"
        case TEA = "TEASPOON"
        case TABLE = "TABLESPOON"
        case CUP = "CUP"
        case FLOZ = "FLOZ"
        case OZ = "OZ"
        case PIECE = "PIECE"
    }
    
    var amount: Double = 0;
    var measurement = Measure.NOTHING;
    var object = "";
    
    func getMeasurementFromString(m: String) -> Bool {
        if(m.compare("t") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("tp") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("teapoon") == NSComparisonResult.OrderedSame) {
            measurement = Measure.TEA
            amount *= 2
            return true;
        }
        else if(m.compare("T") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("tb") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("tbp") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("tablepoon") == NSComparisonResult.OrderedSame) {
            measurement = Measure.TABLE
            amount *= 2
            return true;
        }
        else if( m.caseInsensitiveCompare("c") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("cup") == NSComparisonResult.OrderedSame) {
            measurement = Measure.CUP
            return true;
        }
        else if(m.caseInsensitiveCompare("pt") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("pint") == NSComparisonResult.OrderedSame) {
            measurement = Measure.CUP
            amount *= 2
            return true;
        }
        else if(m.caseInsensitiveCompare("qt") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("quart") == NSComparisonResult.OrderedSame) {
            measurement = Measure.CUP
            amount *= 4
            return true;
        }
        else if(m.caseInsensitiveCompare("gal") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("gallon") == NSComparisonResult.OrderedSame) {
            measurement = Measure.CUP
            amount *= 16
            return true;
        }
        else if(m.caseInsensitiveCompare("floz") == NSComparisonResult.OrderedSame) {
            measurement = Measure.FLOZ
            return true;
        }
        else if(m.caseInsensitiveCompare("oz") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("ounce") == NSComparisonResult.OrderedSame) {
            measurement = Measure.OZ
            return true;
        }
        else if(m.caseInsensitiveCompare("lb") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("pound") == NSComparisonResult.OrderedSame) {
            measurement = Measure.OZ
            amount *= 16
            return true;
        }
        else if(m.caseInsensitiveCompare("doz") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("dozen") == NSComparisonResult.OrderedSame) {
            measurement = Measure.PIECE
            amount *= 12
            return true;
        }
        else if(m.caseInsensitiveCompare("pkg") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("package") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("m") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("mall") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("med") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("medium") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("lg") == NSComparisonResult.OrderedSame
            || m.caseInsensitiveCompare("large") == NSComparisonResult.OrderedSame) {
            measurement = Measure.PIECE
            return true;
        }
        measurement = Measure.PIECE
        return false;
    }
}