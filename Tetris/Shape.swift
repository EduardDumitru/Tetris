//
//  Shape.swift
//  Tetris
//
//  Created by Eduard on 5/17/19.
//  Copyright © 2019 Eduard. All rights reserved.
//

//Clasa Shape ne ajuta sa definim formele pieselor de joc si modul lor de a functiona
import SpriteKit

let NumOrientations: UInt32 = 4

//o enumeratie care ne ajuta sa definim orientarea formei. Un bloc de tetris se poate roti in 4 directii: 0, 90, 180, 270.
enum Orientation: Int, CustomStringConvertible {
    case Zero = 0, Ninety, OneEighty, TwoSeventy
    
    var description: String {
        switch self {
        case .Zero:
            return "0"
        case .Ninety:
            return "90"
        case .OneEighty:
            return "180"
        case .TwoSeventy:
            return "270"
        }
    }
    
    static func random() -> Orientation {
        return Orientation(rawValue:Int(arc4random_uniform(NumOrientations)))!
    }
    
    
    //Aceasta metoda ne returneaza urmatoarea rotire pe care o poate face piesa noastra de joc fie in sensul ceasului, fie contra sensului ceasului
    static func rotate(orientation: Orientation, clockwise: Bool) -> Orientation {
        var rotated = orientation.rawValue + (clockwise ? 1 : -1)
        
        if(rotated > Orientation.TwoSeventy.rawValue) {
            rotated = Orientation.Zero.rawValue
        } else if rotated < 0 {
            rotated = Orientation.TwoSeventy.rawValue
        }
        return Orientation(rawValue:rotated)!
    }
    
}

//Numarul total de tipuri de piese de joc
let NumShapeTypes: UInt32 = 7

//Indecsii pieselor

let FirstBlockIdx: Int = 0

let SecondBlockIdx: Int = 1

let ThirdBlockIdx: Int = 2

let FourthBlockIdx: Int = 3

class Shape: Hashable, CustomStringConvertible {
    //culoarea formei
    let color: BlockColor
    
    //blocurile din care sunt facute formele
    var blocks = Array<Block>()
    
    var orientation: Orientation
    
    //Coloana si randul care reprezinta anchor pointul formei
    var column, row:Int
    
    //Overrides necesare
    
    //Subclasele trebuie sa faca override la urmatoarele proprietati
    //Aici definim un dictionary computat. Dictionarele se definesc cu [...] si le folosim ca sa mapam obiecte intre ele. Primul tip de obiect listat defineste cheia si al doilea valoarea. Cheile mapeaza unu la unu valorile. Nu exista chei duplicate
    //cheile in cazul acestei variabile sunt obiecte de tip Orientation. Valorile aflate in acest dictionar formeaza un tuplu. Un tuplu este perfect pentru a returna sau a trimite mai mult de o variabila fara sa definim un struct.
    //elementele(cheie,valoare) intr-un dictionar sunt optionale by default. De aceea atunci cand ne folosim de ele vom pune la final un !.
    //override
    var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [:]
    }
    
    //override
    var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [:]
    }
    
    //proprietate computata care returneaza blocurile de jos a formei la orientarea actuala. Acest lucru devine folositor cand blocurile devin fizice si incep sa atinga peretii sau sa se atinga intre ele
    var bottomBlocks: Array<Block> {
        guard let bottomBlocks = bottomBlocksForOrientations[orientation] else {
            return []
        }
        return bottomBlocks
    }
    
    //Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(blocks.reduce(0) {
            $0.hashValue ^ $1.hashValue
        })
    }
    
    // CustomStringConvertible
    var description: String {
        return "\(color) block faceing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"
    }
    
    init(column: Int, row: Int, color: BlockColor, orientation: Orientation) {
        self.color = color
        
        self.column = column
        
        self.row = row
        
        self.orientation = orientation
        
        initializeBlocks()
    }
    
    
    //convenience este un initializer special. Un convenience initalizer trebuie sa foloseasca neaparat un  initializer normal. Aici l-am folosit pentru a simplifica felul cum interactioneaza utilizatorul cu aplicatia, trebuind sa-i trimita doar randul si coloana la care vrea sa fie piesa.
    convenience init(column: Int, row: Int) {
        self.init(column:column, row:row, color:BlockColor.random(), orientation:Orientation.random())
    }
    
    static func ==(lhs: Shape, rhs: Shape) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column
    }
    
    //O functie final nu poate fi suprascrisa de subclase.
    final func initializeBlocks() {
        guard let blockRowColumnTranslations = blockRowColumnPositions[orientation] else {
            return
        }
        //Folosim functia map ca sa ne cream un blocks array.
        //map face un task specific: executa codul pe care i l-am dat pentru fiecare obiect gasit, si in cazul nostru, fiecare bloc trebuie sa returneze un obiect de tip Block
        //map adauga fiecare Block returnat de codul nostur in vectorul blocks.
        blocks = blockRowColumnTranslations.map { (diff) -> Block in
            return Block(column: column + diff.columnDiff, row: row + diff.rowDiff, color: color)
        }
    }
    
    final func rotateBlocks(orientation: Orientation) {
        guard let blockRowColumnTranslation: Array<(columnDiff: Int, rowDiff: Int)> = blockRowColumnPositions[orientation] else {
            return
        }
        
        //functia enumerated ne lasa sa iteram vectorul obiect definind o variabila index, dar si contentul de la indexul respectiv, diff, care face referire la (columnDiff: Int, rowDiff: Int)
        for (idx, diff) in blockRowColumnTranslation.enumerated() {
            blocks[idx].column = column + diff.columnDiff
            blocks[idx].row = row + diff.rowDiff
        }
    }
    
    final func rotateClockwise() {
        let newOrientation = Orientation.rotate(orientation: orientation, clockwise: true)
        rotateBlocks(orientation: newOrientation)
        orientation = newOrientation
    }
    
    final func rotateCounterClockwise() {
        let newOrientation = Orientation.rotate(orientation: orientation, clockwise: false)
        rotateBlocks(orientation: newOrientation)
        orientation = newOrientation
    }
    
    final func lowerShapeByOneRow() {
        shiftBy(columns: 0, rows: 1)
    }
    
    final func raiseShapeByOneRow() {
        shiftBy(columns: 0, rows: -1)
    }
    
    final func shiftRightByOneColumn() {
        shiftBy(columns: 1, rows: 0)
    }
    
    final func shiftLeftByOneColumn() {
        shiftBy(columns: -1, rows: 0)
    }
    
    //va ajusta fiecare rand si coloane cu rows si columns
    final func shiftBy(columns: Int, rows: Int) {
        self.column += columns
        self.row += rows
        for block in blocks {
            block.column += columns
            block.row += rows
        }
    }
    
    //un approach absolut la modificarea pozitiei setand randul si coloana inainte de a roti blocurile, care cauzeaza un realiniament accurate a tuturor blocurilor relative cu noile proprietati row si column
    final func moveTo(column: Int, row: Int) {
        self.column = column
        self.row = row
        rotateBlocks(orientation: orientation)
    }
    
    //metoda aceasta genereaza o forma random. subclasele mostenesc natural initializerii de la parinti
    final class func random(startingColumn: Int, startingRow: Int) -> Shape {
        switch Int(arc4random_uniform(NumShapeTypes)) {
        case 0:
            return SquareShape(column:startingColumn, row:startingRow)
        case 1:
            return LineShape(column:startingColumn, row:startingRow)
        case 2:
            return TShape(column:startingColumn, row:startingRow)
        case 3:
            return LShape(column:startingColumn, row:startingRow)
        case 4:
            return JShape(column:startingColumn, row:startingRow)
        case 5:
            return SShape(column:startingColumn, row:startingRow)
        default:
            return ZShape(column:startingColumn, row:startingRow)
        }
    }
}
