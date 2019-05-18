//
//  GameScene.swift
//  Tetris
//
//  Created by Eduard on 5/16/19.
//  Copyright © 2019 Eduard. All rights reserved.
//

import SpriteKit

//definim un pointsize pentru fiecare sprite a blocului, in cazul nostru 20.0 x 20.0, cea mai mica rezolutie pe care o avem pentru fiecare imagine a blocului. De asemenea declaram si o pozitie a layerului care ne va oferi un offset de la marginea ecranului
let BlockSize:CGFloat = 20.0

//Aceasta vriabila defineste cea mai mica viteza la care se pot misca formele geometrice. Am setat-o la 600 de milisecunde, lucru care ar trebui sa o faca sa coboare cate un rand odata
let TickLengthLevelOne = TimeInterval(600)

//O clasa care extinde SKScene mosteneste functia update(currnetTime: CFTimeInterval). iOS-ul apeleaza functia de update la fiecare frame.
class GameScene: SKScene {
    
    //niste noduri care se comporta ca niste layere suprapuse. gameLayer sta deasupra backgroundului iar shapeLayer deasupra lui gameLayer
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let LayerPosition = CGPoint(x: 6, y: -6)

    //tick mai este numit si closure. Closure inseamna un bloc de cod care efectueaza un anumit lucru, iar Swift defineste functiile ca closure. Codul de mai jos e un closure care nu primeste niciun parametru si nu returneaza nimic. Valoarea variabilei tick din cauza semnului intrebarii poate fi si nil
    var tick:(() -> ())?
    
    //o variabila care defineste lungimea curenta a ticks pentru GameScene
    var tickLengthMillis = TickLengthLevelOne
    
    var lastTick: NSDate?
    
    var textureCache = Dictionary<String, SKTexture>()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder nu e valabil!");
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0, y: 1.0)
        let background = SKSpriteNode(imageNamed: "background");
        //SpriteKit ruleaza pe OpenGL, deci (0, 0) este in coltul din stanga jos
        background.position = CGPoint(x: 0, y: 0)
        //Vom realiza acest joc de sus in jos, deci vom ancora jocul in coltul din stanga sus(0, 1.0)
        background.anchorPoint = CGPoint(x: 0, y: 1.0)
        //Dupa care cream un nod capabil sa reprezinte imaginea noastra de background si o adaugam
        addChild(background)
        
        addChild(gameLayer)
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSize(width: BlockSize * CGFloat(NumColumns), height: BlockSize * CGFloat(NumRows)))
        
        gameBoard.anchorPoint = CGPoint(x: 0, y: 1.0)
        gameBoard.position = LayerPosition
        
        shapeLayer.position = LayerPosition
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
        
        //setam un sunet pe looping
        //run(SKAction.repeatForever(SKAction.playSoundFileNamed("Sounds/theme.mp3", waitForCompletion: true)))
        
        
    }
    
    //adaugam o metoda prin care gameviewcontroller va putea pune orice sunet la cerere
    func playSound(sound: String) {
        run(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        //afirmatia guard verifica conditiile de care este urmata. Daca da gres, intra in blocul else'
        //daca last tick lipseste atunci jocul este in pauza.
        //dar daca exista, vom recupera din timpul pierdut de la ultima executie a updateului invocand metoda timeIntervalSinceNow pe obiectul lastTick. Dupa care multiplicam rezultatul cu -1000 ca sa fie milisecunde pozitive.
        guard let lastTick = lastTick else {
            return
        }
        
        let timePassed = lastTick.timeIntervalSinceNow * -1000.0
        
        if timePassed > tickLengthMillis {
            self.lastTick = NSDate()
            
            tick?()
        }
    }
    
    func startTicking() {
        lastTick = NSDate()
    }
    
    func stopTicking() {
        lastTick = nil
    }
    
    //Aceasta este cea mai importanta functie din GameScene. Ea ne returneaza cu precizie coordonatele de pe ecran pentru fiecare sprite al blocului bazat pe randul si coloana la care se afla acum. Ancoram fiecare sprite la centrul lui, deci trebuie sa afla coordonatele centrului inainte sa-l punem pe obiectul shapeLayer
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        let x = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize / 2)
        
        let y = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize / 2))
        
        return CGPoint(x: x, y: y)
    }
    
    func addPreviewShapeToScene(shape: Shape, completion: @escaping () -> ()) {
        for block in shape.blocks {
            //Aceasta metoda va adauga o forma ca un preview shape. Folosim un dictionar care stocheaza copii a obiectelor SKTexture refolosibile, avand in vedere ca fiecare forba va avea nevoie de mai multe copii a aceleiasi imagini
            var texture = textureCache[block.spriteName]
            
            if texture == nil {
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            let sprite = SKSpriteNode(texture: texture)
            //ne folosim de metoda pointForColumn ca sa plasam fiecare sprite al blocului la locul lui. Incepem cu row-2, ca piesa de preview sa se animeze frumos
            sprite.position = pointForColumn(column: block.column, row: block.row - 2)
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            
            // Animation
            sprite.alpha = 0
            
            //Obiectele de tip SKAction sunt responsabile pentru manipularea vizuala a obiectelor de tip SKNode. Fiecare bloc se va decolora si misca in locul lui. Se va muta doua randuri in jos si se va decolora de la transparenta completa la 70% opacitate. In acest fel playerul foarte posibil nu o va baga in seama
            let moveAction = SKAction.move(to: pointForColumn(column: block.column, row: block.row), duration: 0.2)
            moveAction.timingMode = .easeOut
            
            let fadeInAction = SKAction.fadeAlpha(to: 0.7, duration: 0.2)
            
            fadeInAction.timingMode = .easeOut
            
            sprite.run(SKAction.group([moveAction, fadeInAction]))
        }
        run(SKAction.wait(forDuration: 0.2), completion: completion)
    }
    
    func movePreviewShape(shape: Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            
            let moveTo = pointForColumn(column: block.column, row: block.row)
            
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.2)
            
            moveToAction.timingMode = .easeOut
            
            let fadeInAction = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
            fadeInAction.timingMode = .easeOut
            
            sprite.run(SKAction.group([moveToAction, fadeInAction]))
        }
        run(SKAction.wait(forDuration: 0.2), completion: completion)
    }
    
    func redrawShape(shape: Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            
            let moveTo = pointForColumn(column: block.column, row: block.row)
            
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.05)
            
            moveToAction.timingMode = .easeOut
            
            if block == shape.blocks.last {
                sprite.run(moveToAction, completion: completion)
            } else {
                sprite.run(moveToAction)
            }
        }
    }
    
    //Tuplu pe care tetris il returneaza de fiecare data cand sterge o linie. Ne asigura ca GameViewController va trimite elementele spre GameScene sa le animeze cum trebuie
    func animateCollapsingLines(linesToRemove: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>, completion: @escaping () -> ()) {
        var longestDuration: TimeInterval = 0
        
        //Blocurile le luam coloana cu coloana, bloc cu bloc si mai sus am creat longestDuration care determina precis cat de mult ar trebui sa asteptam inainte sa chemam completion closure
        for (columnIdx, column) in fallenBlocks.enumerated() {
            for (blockIdx, block) in column.enumerated() {
                let newPosition = pointForColumn(column: block.column, row: block.row)
                
                let sprite = block.sprite!
                
                //ca blocurile sa nu arate robotice vor unul dupa altul decat toate deodata. Bazat pe bloc si coloana am introdus un delay direct proportional cu ele
                let delay = (TimeInterval(columnIdx) * 0.05) + (TimeInterval(blockIdx) * 0.05)
                
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / BlockSize) * 0.1)
                
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                
                moveAction.timingMode = .easeOut
                
                sprite.run(SKAction.sequence([SKAction.wait(forDuration: delay), moveAction]))
                
                longestDuration = max(longestDuration, duration + delay)
            }
        }
        
        for rowToRemove in linesToRemove {
            for block in rowToRemove {
                //Cand stergem liniile vom face ca blocurile sa zboare de pe ecran ca un fel de explozie. Ne folosim de UIBezierPath. Arcul are nevoie de o raza si am ales sa generam una random ca sa introducem o varianta naturala la explozii. Am randomizat si daca blocul va zbura spre stanga sau spre dreapta
                let randomRadius = CGFloat(UInt(arc4random_uniform(400) + 100))
                
                let goLeft = arc4random_uniform(100) % 2 == 0
                
                var point = pointForColumn(column: block.column, row: block.row)
                
                point = CGPoint(x: point.x + (goLeft ? -randomRadius : randomRadius), y: point.y)
                
                let randomDuration = TimeInterval(arc4random_uniform(2)) + 0.5
                
                //Alegem unghiurile de inceput si cele de sfarsit. Unghiurile sunt in radiani. Cand mergem la stanga, incepem de la 0 si terminam la pi. cand mergem spre dreapta incepem de la pi spre 2 pi.
                var startAngle = CGFloat(Double.pi)
                var endAngle = startAngle * 2
                
                if goLeft {
                    endAngle = startAngle
                    
                    startAngle = 0
                }
                
                let archPath = UIBezierPath(arcCenter: point, radius: randomRadius, startAngle: startAngle, endAngle: endAngle, clockwise: goLeft)
                
                let archAction = SKAction.follow(archPath.cgPath, asOffset: false, orientToPath: true, duration: randomDuration)
                
                archAction.timingMode = .easeIn
                
                let sprite = block.sprite!
                
                //Punem sprite-ul blocului peste altele in asa fel incat sa se animeze deasupra celorlalte si sa inceapa o secventa de actiuni care rezulta in scoaterea sprite-ului de pe scena
                sprite.zPosition = 100
                
                sprite.run(
                SKAction.sequence([SKAction.group([archAction, SKAction.fadeOut(withDuration: TimeInterval(randomDuration))]),
                    SKAction.removeFromParent()])
                    )
                
                //facem completion action dupa un timp care echivaleaza timpul cat ii ia sa cada ultimului bloc catre noul sau loc de relaxare
                run(SKAction.wait(forDuration: longestDuration), completion: completion)
            }
        }
    }
}
