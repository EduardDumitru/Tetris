//
//  SquareShape.swift
//  Tetris
//
//  Created by Eduard on 5/17/19.
//  Copyright © 2019 Eduard. All rights reserved.
//

class SquareShape: Shape {
    //forma de patrat nu se va roti
    //subclasele acum trebuie doar sa ne ofere distanta dintre fiecare bloc din locatia randului si coloanei formei la fiecare posibila orientare.
    
    
    //fiecare index al acestor vectori reprezinta unul dintre cele 4 blocuri pornind de la blocul 0 si oprindu-ne la blocul 3. De exemplu, blocul din stanga sus(bloc 0) al unui patrat este identic cu randul si coloana locatiei.
    override var blockRowColumnPositions: [Orientation : Array<(columnDiff: Int, rowDiff: Int)>] {
        return [
            Orientation.Zero: [(0,0), (1,0), (0,1), (1,1)],
            Orientation.OneEighty: [(0,0), (1,0), (0,1), (1,1)],
            Orientation.Ninety: [(0,0), (1,0), (0,1), (1,1)],
            Orientation.TwoSeventy: [(0,0), (1,0), (0,1), (1,1)],
        ]
    }
    
    //aceasta functie ar trebui sa roteasca forma, dar cum forma patratuli ramane aceeasi, ne folosim de al treilea si al patrulea index peste tot
    override var bottomBlocksForOrientations: [Orientation : Array<Block>] {
        return [
            Orientation.Zero: [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.OneEighty: [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.Ninety: [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]],
            Orientation.TwoSeventy: [blocks[ThirdBlockIdx], blocks[FourthBlockIdx]]
        ]
    }
}
