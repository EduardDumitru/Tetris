//
//  Block.swift
//  Tetris
//
//  Created by Eduard on 5/17/19.
//  Copyright © 2019 Eduard. All rights reserved.
//

import SpriteKit

//cate culori vor fi in jocul de tetris
let NumberOfColors: UInt32 = 6

//declararea enumerarii culorilor de tetris
//clasele care implementeaza CustomStringConvertible sunt capabile sa genereze stringuri care sunt usor de citit de catre oameni atunci cand facem debug sau print
enum BlockColor: Int, CustomStringConvertible {
    //Declaram culoarea albastra cu 0, iar asta va continua pana la galben care va avea valoarea 5
    case Blue = 0, Orange, Purple, Red, Teal, Yellow
    
    //definim o proprietate computata
    //O proprietatea computata se poarta ca o variabila normala, doar ca atunci cand o accesam blocul de cod se va genera de fiecare data cu o noua valoare. Am fi putut folosi o functie noua, dar asa e mai usor de citit
    var spriteName: String {
        switch self {
        case .Blue:
            return "blue"
        case .Orange:
            return "orange"
        case .Purple:
            return "purple"
        case .Red:
            return "red"
        case .Teal:
            return "teal"
        case .Yellow:
            return "yellow"
        }
    }
    
    //o alta proprietate computata. Aderand la proprietatea CustomStringConvertible este obligatoriu sa scriem aceasta functie.
    var description: String {
        return self.spriteName
    }
    
    //Aceasta e o functie statica. Ne vom folosi de ea ca sa returnam o alegere random dintre culorile gasite in BlockColor. Creeaza un BlockColor folosind rawValue: Int initializer care va fi asignata valorilor de la 0 la 5
    static func random() -> BlockColor {
        return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
    }
}

//definim un bloc ca o clasa care implementeaza cele doua protocoale
//cu Hashable putem salva blocul ca un Array 2D
class Block: Hashable, CustomStringConvertible {
    //definim culoarea ca o constanta ca blocurile deja colorate sa nu-si schimbe culoarea in mijlocul jocului
    let color: BlockColor
    
    //coloana si randul reprezinta locatia blocului pe tabla de joc. Nodule sprite reprezinta elementul vizual al blocului pe care GameScene il va folosi ca sa il randeze si sa-l animeze
    var column: Int
    
    var row: Int
    
    var sprite: SKSpriteNode?
    
    //ne folosim de aceasta variabila ca sa scurtam numele variabile pe care o vom utiiza. Din block.color.spriteName in block.spriteName
    var spriteName: String {
        return color.spriteName
    }
    
    //implementam descrierea ca sa respectam protocolul CustomStringConvertible. Putem sa punem obiecte de tipul CustomStringConvertible in mijlocul unui string inconjurandu-le de \( si )
    var description: String {
        return "\(color): [\(column), \(row)]"
    }
    
    init(column:Int, row:Int, color:BlockColor) {
        self.column = column
        
        self.row = row
        
        self.color = color
    }
    
    //Am implementat aceasta functie pentru a respecta protocolul Hashable. Returnam un xor format din row si column care genereaza un integer unic pentru fiecare bloc
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.column)
        hasher.combine(self.row)
    }
    
    //Am creat un operator custom care sa compare blocurile intre ele. Daca este true atunci blocurile se afla la aceeasi locatie si au aceeasi culoare. Hashable mosteneste din Equatable, ceea ce ne obliga sa supraincarcam acest operator
    static func ==(lhs: Block, rhs: Block) -> Bool {
        return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
    }
}
