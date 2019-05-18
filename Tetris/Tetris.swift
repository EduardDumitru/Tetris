//
//  Tetris.swift
//  Tetris
//
//  Created by Eduard on 5/17/19.
//  Copyright © 2019 Eduard. All rights reserved.
//

//Aceasta clasa se ocupa cu logica jocului


//definim numarul total de randuri si coloane pe care le poate avea plasna de joc, locatia unde incepe fiecare piesa si locatia unde se va afla indicatorul cu piesa urmatoare
let NumColumns = 10
let NumRows = 20

let StartingColumn = 4
let StartingRow = 0

let PreviewColumn = 12
let PreviewRow = 1

//puncte + cand trecem la urmatorul nivel
let PointsPerLine = 10
let LevelThreshold = 500

//Tetris va notifica delegata atunci cand se intampla ceva descris aici. In cazul nostru, GameViewController se va atasa de delegata ca sa actualizeze interfata si sa reactioneze cand se chimba starea jocului
protocol TetrisDelegate {
    //Invocata atunci cand se termina runda de tetris
    func gameDidEnd(tetris: Tetris)
    
    //Invocata cand incepe noul joc
    func gameDidBegin(tetris: Tetris)
    
    //invocata cand fallingShape si-a schimbat locatia dupa ce a cazut
    func gameShapeDidDrop(tetris: Tetris)
    
    //invocata cand jocul a ajuns la un nivel nou
    func gameDidLevelUp(tetris: Tetris)
    
    func gameShapeDidMove(tetris: Tetris)
    
    func gameShapeDidLand(tetris: Tetris)
}

class Tetris {
    var blockArray: Array2D<Block>
    var nextShape: Shape?
    var fallingShape: Shape?
    var delegate: TetrisDelegate?
    
    var score = 0
    var level = 1
    
    init() {
        fallingShape = nil
        
        nextShape = nil
        
        blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
    }
    
    func beginGame() {
        if (nextShape == nil) {
            nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        }
        
        delegate?.gameDidBegin(tetris: self)
    }
    
    // Metoda asigneaza nextShape(rotatia urmatoare) lui fallingShape. fallingShape este piesa care se misca. newShape() creeaza apoi o piesa noua in indicatia piesei urmatoare inainte de a misca fallingShape la inceput.
    func newShape() -> (fallingShape: Shape?, nextShape: Shape?) {
        fallingShape = nextShape
        
        nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
        
        fallingShape?.moveTo(column: StartingColumn, row: StartingRow)
        
        //aici adaugam o logica jocului care va detecta atunci cand se termina jocul de Tetris. Jocul se termina atunci cand o piesa noua care incepe la locatia predefinita se va lovi de celelalte blocuri. Acesta este cazul cand un player nu mai are loc sa-si miste piesa cea noua.
        guard detectIllegalPlacement() == false
            else {
                nextShape = fallingShape
                nextShape!.moveTo(column: PreviewColumn, row: PreviewRow)
                endGame()
                return(nil, nil)
        }
        
        return (fallingShape, nextShape)
    }
    
    //aici verificam conditiile limitelor placii de joc. Prima determina daca trece de limita placii. A doua determina daca locatia curenta a unui bloc se afla in acelasi loc cu un bloc deja existent.
    func detectIllegalPlacement() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        
        for block in shape.blocks {
            if block.column < 0 || block.column >= NumColumns || block.row < 0 || block.row >= NumRows {
                return true
            } else if blockArray[block.column, block.row] != nil {
                return true
            }
        }
        return false
    }
    
    //functia asta face ca piesa sa cada mai repede atunci cand userul vrea asta. Va continua sa cada pana cand detecteaza o stare de placement ilegala, punct in care o va ridica si va anunta delegata ca a cazut. Aceste functii folosesc asignare conditionala, ceea ce garanteaza ca in orice stadiu ar fi interfata, Tetris nu va opera cu piese invalide
    func dropShape() {
        guard let shape = fallingShape else {
            return
        }
        
        while detectIllegalPlacement() == false {
            shape.lowerShapeByOneRow()
        }
        
        shape.raiseShapeByOneRow()
        
        delegate?.gameShapeDidDrop(tetris: self)
    }
    
    //O functie definita care sa fie chemata o data la fiecare tick. Incearca sa duca piesa cu un rand mai jos si termina jocul atunci cand nu reuseste.
    func letShapeFall() {
        guard let shape = fallingShape else {
            return
        }
        
        shape.lowerShapeByOneRow()
        
        if detectIllegalPlacement() {
            shape.raiseShapeByOneRow()
            if detectIllegalPlacement() {
                endGame()
            } else {
                settleShape()
            }
        } else {
            delegate?.gameShapeDidMove(tetris: self)
            if detectTouch() {
                settleShape()
            }
        }
    }
    
    //Interfata ne va lasa sa rotim piesa folosind aceasta functie. Daca incearca sa roteasca piesa intr-o stare ilegala, inversam rotatia si o returnam. Altfel, lasam delegata sa stie ca piesa s-a miscat
    func rotateShape() {
        guard let shape = fallingShape else {
            return
        }
        
        shape.rotateClockwise()
        
        guard detectIllegalPlacement() == false else {
            shape.rotateCounterClockwise()
            return
        }
        delegate?.gameShapeDidMove(tetris: self)
    }
    
    //Aceste functii urmaresc acelasi pattern ca la rotateShape si e de la sine inteles ce fac
    func moveShapeLeft() {
        guard let shape = fallingShape else {
            return
        }
        
        shape.shiftLeftByOneColumn()
        
        guard detectIllegalPlacement() == false else {
            shape.shiftRightByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(tetris: self)
    }
    
    func moveShapeRight() {
        guard let shape = fallingShape else {
            return
        }
        
        shape.shiftRightByOneColumn()
        
        guard detectIllegalPlacement() == false else {
            shape.shiftLeftByOneColumn()
            return
        }
        delegate?.gameShapeDidMove(tetris: self)
    }
    
    //Adauga piesa care cade la colectia de blocuri deja existente in tetris. Odata ce face parte din ele, o facem nula si notificam delegate ca o noua piesa a ajuns pe placa de joc.
    func settleShape() {
        guard let shape = fallingShape else {
            return
        }
        
        for block in shape.blocks {
            blockArray[block.column, block.row] = block
        }
        
        fallingShape = nil
        
        delegate?.gameShapeDidLand(tetris: self)
    }
    
    //Tetris trebuie sa-si dea seama cand o piesa a fost adaugata. Se intampla in doua conditii: cand blocurile de jos ale unei piese au atins alt bloc deja existent sau cand unul dintre blocuri a ajuns pe fundul plansei de joc.
    func detectTouch() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        for bottomBlock in shape.bottomBlocks {
            if bottomBlock.row == NumRows - 1 || blockArray[bottomBlock.column, bottomBlock.row + 1] != nil {
                return true
            }
        }
        return false
    }
    
    func endGame() {
        score = 0
        
        level = 1
        
        delegate?.gameDidEnd(tetris: self)
    }
    
    //Definim o functie care returneaza un tuplu. Este format din linesRemoved si fallenBlocks. linesRemoves retine cate randuri de blocuri a umplut userul
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
        var removedLines = Array<Array<Block>>()
        
        for row in (1..<NumRows).reversed() {
            var rowOfBlocks = Array<Block>()
            
            //for care merge de la 0 pana la NumColumns. Acesta adauga fiecare bloc de la randul dat intr-un vector local numit rowOfBlocks. Daca ajunge sa fie un set full(10 blocuri in total) atunci numara acea linie ca pe una stearsa si o adauga variabilei pe care o vom returna
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
            }
            
            if rowOfBlocks.count == NumColumns {
                removedLines.append(rowOfBlocks)
                
                for block in rowOfBlocks {
                    blockArray[block.column, block.row] = nil
                }
            }
        }
        
        //verificam daca am sters vreo linie pana acum. Daca nu returnam un tuplu format din doi vectori goi
        if removedLines.count == 0 {
            return ([], [])
        }
        
        //adaugam puncte la scor in functie de cate linii a distrus. Daca depaseste nivelul * 1000 atunci trece la nivelul urmator si informam delegata
        let pointsEarned = removedLines.count * PointsPerLine * level
        
        score += pointsEarned
        
        if score >= level * LevelThreshold {
            level += 1
            delegate?.gameDidLevelUp(tetris: self)
        }
        
        var fallenBlocks = Array<Array<Block>>()
        
        for column in 0..<NumColumns {
            var fallenBlocksArray = Array<Block>()
            
            //incepand cu coloana cea mai din stanga si de deasupra randului distrus cel mai de jos, numaram in sus pana la capatul placii de joc. Facand asta luam toate blocurile care exista si le dam cat de jos putem noi. fallenBlocks este un vector de vectori si am umplut fiecare sub-vector cu blocuri care au cazut la noile pozitii.
            for row in (1..<removedLines[0][0].row).reversed() {
                guard let block = blockArray[column, row] else {
                    continue
                }
                
                var newRow = row
                
                while (newRow < NumRows - 1 && blockArray[column, newRow + 1] == nil) {
                    newRow += 1
                }
                
                block.row = newRow
                
                blockArray[column, row] = nil
                
                blockArray[column, newRow] = block
                
                fallenBlocksArray.append(block)
            }
            if fallenBlocksArray.count > 0 {
                fallenBlocks.append(fallenBlocksArray)
            }
        }
        return (removedLines, fallenBlocks)
    }
    
    //functia asta trece prin tot si creeaza randuri de blocuri pe care le arunca din scena folosind animatii.
    func removeAllBlocks() -> Array<Array<Block>>
    {
        var allBlocks = Array<Array<Block>>()
        
        for row in 0..<NumRows {
            var rowOfBlocks = Array<Block>()
            
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                
                rowOfBlocks.append(block)
                
                blockArray[column, row] = nil
            }
            
            allBlocks.append(rowOfBlocks)
        }
        return allBlocks
    }
}
