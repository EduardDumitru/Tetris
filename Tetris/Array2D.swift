//
//  Array2D.swift
//  Tetris
//
//  Created by Eduard on 5/16/19.
//  Copyright © 2019 Eduard. All rights reserved.
//

//Din cate am inteles, vectorii generici in swift sunt de tip struct nu de tip class, dar aici aveam nevoie sa ma folosesc de array-ul care formeaza plansa de joc peste tot in proiect ca sa manipulez datele cu usurinta
class Array2D<T> {
    let columns: Int
    let rows: Int
    
    //este o structura de date care salveaza obiectele
    //variabilele optionale pot contine sau nu date si pot fi chiar si nil sau goale
    //locatiile care sunt nil pe plansa mea de joc, vor reprezenta locuri goale unde nu este prezent niciun bloc
    var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        
        self.rows = rows
        
        //initializarea vectorului cu o marime de rows * columns
        array = Array<T?>(repeating: nil, count:rows * columns)
    }
    
    subscript(column: Int, row: Int) -> T? {
        //ca sa primim valoarea de la o anumita locatie trebuie sa inmultim randul primit cu coloanele si apoi sa adaugam coloana la rezultat
        get {
            return array[(row * columns) + column]
        }
        
        //asignam o noua valoare locatiei determinata de acelasi algoritm din getter
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
    }
}


