//
//  GameViewController.swift
//  Tetris
//
//  Created by Eduard on 5/16/19.
//  Copyright © 2019 Eduard. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, TetrisDelegate, UIGestureRecognizerDelegate {
    //swift de obicei te pune sa instantiezi fie in linie fie in init, dar ca sa trecem peste aceasta regula am adaugat !
    var scene: GameScene!
    var tetris: Tetris!
    
    //tinem minte ultimul punct al ecranului in care s-a miscat o forma sau une incepe pan
    var panPointReference: CGPoint?
    
    
    //aceasta functie ii da o valoare variabile scene si o prezentam userului
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configuram view-ul
        //fara a face downcast la view, nu am putea accesa metodele si proprietatile SKView-ului
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        //cream si configuram scena
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        //am adaugat un closure pentru proprietatea de tick de pe GameScene. Functiile sunt closures cu nume. In cazul nostru am folosit o functie care se cheama didTick(). Tot ce face e sa coboare fallingShape cu un rand si apoi roaga GameScene sa redeseneze forma la noua locatie
        scene.tick = didTick
        
        tetris = Tetris()
        
        tetris.delegate = self
        
        tetris.beginGame()
        
        //prezentam scena
        skView.presentScene(scene)
        
        //Adaugam nextShape la layerul jocului la locatia de preview. Cand animatia se termina, repozitionam obiectul Shape de acolo la inceputul randului si coloane si cerem GameScene sa o mute din zona de preview in zona de inceput. O data ce se termina, rugam Tetris sa creeze o noua forma, sa inceapa sa se miste si sa adauge o noua pisa la zona de preview
        
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func didTick() {
        tetris.letShapeFall()
    }
    
    @IBOutlet weak var LevelLabel: UILabel!
    @IBOutlet weak var ScoreLabel: UILabel!
    @IBAction func didSwipe(_ sender: UISwipeGestureRecognizer) {
        tetris.dropShape()
    }
    
    //GameViewController va implementa o metoda delegata optionala pe care o gasim in UIGestureRecognizerDelegate care ne va lasa sa folosim fiecare gesture recognizer in acelasi timp cu celelalte. Cateodata un gesture recognizer s-ar putea lovi de celalalt.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //Cateodata cand dam swipe in jos, un pan gesture s-ar putea intampla simultan cu un swipe gesture. Ca sa se distinga, vom implementa inca o metoda delegata optionala. Verificarile conditionale sunt pentru a vedea daca parametrii generici ai lui UIGestureRecognizer sunt de tipul specific pe care-l asteptam. Daca este cu succes, continuam executia. Pan se face inaintea lui swipe, iar tap inaintea lui pan.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer {
            if otherGestureRecognizer is UIPanGestureRecognizer {
                return true
            }
        } else if gestureRecognizer is UIPanGestureRecognizer {
            if otherGestureRecognizer is UITapGestureRecognizer {
                return true
            }
        }
        
        return false
    }
    @IBAction func didPan(_ sender: UIPanGestureRecognizer) {
        //recuperam un punct care defineste translatia miscarii relativ cu locul de unde a inceput. Este doar o masura a distantei pe care a parcurs-o degetul utilizatorului pe ecran
        let currentPoint = sender.translation(in: self.view)
        
        if let originalPoint = panPointReference {
            //verificam daca translatia x a depasit thresholdul nostru - 90% din blockSize - inainte sa incepem
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                //Verificam velocitatea. Velocitatea ne da directie, in cazul in care e pozitiva degetul se duce spre dreapta, altfel spre stanga. Dupa mutam forma in directia corespunzatoare si resetam punctul de referinta
                if sender.velocity(in: self.view).x > CGFloat(0) {
                    tetris.moveShapeRight()
                    
                    panPointReference = currentPoint
                } else {
                    tetris.moveShapeLeft()
                    
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .began {
            panPointReference = currentPoint
        }
    }
    
    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        tetris.rotateShape()
    }
    
    
    func nextShape() {
        let newShapes = tetris.newShape()
        
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        self.scene.addPreviewShapeToScene(shape: newShapes.nextShape!) {}
        
        self.scene.movePreviewShape(shape: fallingShape) {
            //O booleana care ne permite sa oprim/pornim interactiunea cu viewul. E folositoare cand animam sau mutam blocuri si facem calcule. Altfel daca userul interactioneaza la momentul potrivit ar putea cauza un bug
            self.view.isUserInteractionEnabled = true
            
            self.scene.startTicking()
        }
    }
    
    func gameDidBegin(tetris: Tetris) {
        //fals cand restartam jocul
        LevelLabel.text = "\(tetris.level)"
        ScoreLabel.text = "\(tetris.score)"
        
        scene.tickLengthMillis = TickLengthLevelOne
        
        if tetris.nextShape != nil && tetris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(shape: tetris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(tetris: Tetris) {
        view.isUserInteractionEnabled = false
        
        scene.stopTicking()
        
        //scene.playSound(sound: "Sounds/gameover.mp3")
        
        scene.animateCollapsingLines(linesToRemove: tetris.removeAllBlocks(), fallenBlocks: tetris.removeAllBlocks()) {
        }
        
        tetris.beginGame()
    }
    
    func gameDidLevelUp(tetris: Tetris) {
        LevelLabel.text = "\(tetris.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        
        //scene.playSound(sound: "Sounds/levelup.mp3")
    }
    
    func gameShapeDidDrop(tetris: Tetris) {
        //oprim miscarile, redesenam forma si o lasam sa cada. Asta returneaza un apel catre GameViewController si-l anunta ca piesa a aterizat
        scene.stopTicking()
        
        scene.redrawShape(shape: tetris.fallingShape!) {
            tetris.letShapeFall()
        }
        
        //scene.playSound(sound: "Sounds/drop.mp3")
    }
    
    func gameShapeDidLand(tetris: Tetris) {
        scene.stopTicking()
        
        self.view.isUserInteractionEnabled = false
        
        //cand o forma cade natural sau dupa un drop, trebuie sa verificam daca exista lini icompletate. Invocam removeCompletedLines ca sa recuperam cei doi vectori din Tetris. Daca Tetris a sters vreo linie, actualizam scorul sa reprezinte cel mai nou scor si animam blocurile cu explozia din functia de animatie
        let removedLines = tetris.removeCompletedLines()
        
        if removedLines.linesRemoved.count > 0 {
            self.ScoreLabel.text = "\(tetris.score)"
            
            scene.animateCollapsingLines(linesToRemove: removedLines.linesRemoved, fallenBlocks: removedLines.fallenBlocks) {
            }
            //Facem un apel recursiv ca sa vedem daca s-au format alte noi linii
            self.gameShapeDidLand(tetris: tetris)
            
            //scene.playSound(sound: "Sounds/bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    func gameShapeDidMove(tetris: Tetris) {
        scene.redrawShape(shape: tetris.fallingShape!) {}
    }
}
