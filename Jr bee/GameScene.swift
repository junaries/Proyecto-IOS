//
//  GameScene.swift
//  Jr bee
//
//  Created by JUNIORS ANTONIO MEDINA LANDEON on 13/7/17.
//  Copyright © 2017 JUNIORS ANTONIO MEDINA LANDEON. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    // creo mi variable global de la abeja
    var separacionEnemigos = 150.0
    var abejita = SKSpriteNode() // Un elemento de SK
    var colorCielo = SKColor()
    var sol = SKSpriteNode()
    var texturaPlantaFea = SKTexture()
    var texturaAvispa = SKTexture()
    var repeticion = SKAction()
    // creo un nuevo nodo, que será el letrero "peligro-No tocar"
    var peligro = SKSpriteNode()
    // creo la textura del cartel de peligro
    let texturaPeligro = SKTexture(imageNamed: "peligro")
    
    let categoriaAbeja : UInt32 = 1 << 0
    let categoriaPeligro : UInt32 = 1 << 1
    let categoriaEnemigos : UInt32 = 1 << 2
    let categoriaSuelo : UInt32 = 1 << 3
    let categoriaPuntua : UInt32 = 1 << 4
    
    let movimientoDelConjunto = SKNode() // Este nodo, será el encargado de representar a cada uno de los elementos que tienen movimiento en la app como el suelo, la plantaFea y la avispa
    var reiniciar = false // variable para definir el reinicio o reseteo del juego
    // He probado que hay una mala gestion de las plantasFeas y las avispas, en un momento dado se llegan a solapar entre ellos, quedando un aspecto visual muy horrible, con lo cual tengo que gestionar dichos elementos para evitar dicho efecto no deseado
    var gestionDeEnemigos = SKNode()
    // En todo juego tiene que haber una puntuación, con lo cual:
    var puntuacion = NSInteger()
    var etiqueta_puntuacion = SKLabelNode()
 
    
    
    /* Esto se ejecuta cuando se lanza la aplicación */
    override func didMove(to view: SKView) {
        // añado ese nodo "movimientoDelConjunto" a la aplicación
        self.addChild(movimientoDelConjunto)
        movimientoDelConjunto.addChild(gestionDeEnemigos)
        // Voy a crear gravedad en los objetos de este juego
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        self.physicsWorld.contactDelegate = self // la propia aplicación va a controlar los contactos o choques
        
        // Asigno mediante el formato RGB el color de fondo de mi aplicación
        let colorCielo = SKColor(red: 164/255, green: 235/255, blue: 237/255, alpha: 1)
        self.backgroundColor = colorCielo
        // Creo la textura (imagen) de la abeja
        let imagenAbeja = SKTexture(imageNamed: "abeja1")
        // Aplico un filtro para que la imagen quede bien establecida
        imagenAbeja.filteringMode = SKTextureFilteringMode.nearest
        // Es aqui donde creo una animación mediante la incorporación de una segunda imagen:
        let imagenAbeja2 = SKTexture(imageNamed: "abeja2")
        imagenAbeja2.filteringMode = SKTextureFilteringMode.nearest
        
        // Aquí se origina el efecto del aleteo de la abeja:
        let movimientoAbeja = SKAction.animate(with: [imagenAbeja, imagenAbeja2], timePerFrame: 0.2)
        
        // Una vez creada la animación,lo que tengo que definir es la acción de la ejecucion de dicha animacion 
        let vuelo = SKAction.repeatForever(movimientoAbeja)
        
        
        // Lo que me queda es asociar esa textura(imagen) al elemento creado (abejita)
        abejita = SKSpriteNode.init(texture: imagenAbeja)
        
        // Ahora me encargo de la posicion de la abejita en la pantalla
        abejita.position = CGPoint(x: self.frame.size.width / 40.0 - 40, y: self.frame.midY)
        
        // Lanzo el aleteo de la abeja:
        abejita.run(vuelo)
        // Defino a la abejita como cuerpo físico para que tenga gravedad
        abejita.physicsBody = SKPhysicsBody(circleOfRadius: abejita.size.height/2)
        // Le asigno características dinámicas:
        abejita.physicsBody?.isDynamic = true
        // A la abejita no se le va a permitir rotar
        abejita.physicsBody?.allowsRotation = false
        // Asigno la categoria de la abejita
        abejita.physicsBody?.categoryBitMask = categoriaAbeja
        // Defino las colisiones que va a tener
        abejita.physicsBody?.collisionBitMask = categoriaPeligro | categoriaEnemigos | categoriaSuelo
        // Testeo dichas colisiones
        abejita.physicsBody?.contactTestBitMask = categoriaPeligro | categoriaEnemigos | categoriaSuelo
        // Muestro (añado) la abejita en pantalla de la aplicación
        self.addChild(abejita)
        //Creo la textura del sol
        let texturaSol = SKTexture(imageNamed: "solJR")
        //Creo un filtro para que la imagen quede correctamente colocada
        texturaSol.filteringMode = SKTextureFilteringMode.nearest
        // Asocio el elemento creado a la imagen
        sol = SKSpriteNode.init(texture: texturaSol)
        // Me encargo de la posicion del sol en la pantalla de mi aplicación
        sol.position = CGPoint(x: self.frame.size.width / 40.0 + 295, y: self.frame.midY + 500)
        sol.zPosition = -120
        self.addChild(sol)
        
        //Creo un filtro para que quede OK la imagen "peligro"
        texturaPeligro.filteringMode = SKTextureFilteringMode.nearest
        //Como siempre, asocio la textura(imagen) con su respectivo elemento
        peligro = SKSpriteNode.init(texture: texturaPeligro)
        //Lo posiciono en la pantalla de mi aplicación
        peligro.position = CGPoint(x: self.frame.size.width / 40.0 - 390 , y: self.frame.midY + 210)
        peligro.physicsBody = SKPhysicsBody(rectangleOf: peligro.size )
        peligro.physicsBody?.isDynamic = false
        peligro.physicsBody?.categoryBitMask = categoriaPeligro
        peligro.physicsBody?.contactTestBitMask = categoriaAbeja

        // lo añado en la pantalla
        self.addChild(peligro)
        
        
        
        
        // Ahora creo la textura del cielo, textura es lo mismo que decir imagen
        let texturaCielo = SKTexture(imageNamed: "cieloDefinitivo")
        texturaCielo.filteringMode = SKTextureFilteringMode.nearest
        // Para causar la sensación de que la abeja avanza, el cielo se tienen que despplazar hacia la izquierda
        let moverCielo = SKAction.moveBy(x: -texturaCielo.size().width, y: 0, duration:TimeInterval( 0.05 * texturaCielo.size().width))
        // luego tengo que colocar el cielo en su posición normal
        let posicionInicialCielo = SKAction.moveBy(x: texturaCielo.size().width, y: 0, duration: 0.0005)
        // Esta acción de desplazar hacia la izquierda y volver al sitio inicial, tengo que repetirlo constantemente
        let movimientoConstanteCielo = SKAction.repeatForever(SKAction.sequence([moverCielo, posicionInicialCielo]))

        
        // Ahora creo la textura de las flores
        let texturaFlores = SKTexture(imageNamed: "flores")
        texturaFlores.filteringMode = SKTextureFilteringMode.nearest
        // Para causar la sensación de que la abeja avanza, las flores se tienen que despplazar hacia la izquierda
        let moverFlores = SKAction.moveBy(x: -texturaFlores.size().width, y: 0, duration:TimeInterval( 0.01 * texturaFlores.size().width))
        // luego tengo que colocar las flores en su posición normal
        let posicionInicialFlores = SKAction.moveBy(x: texturaFlores.size().width, y: 0, duration: 0.0005)
        // Esta acción de desplazar hacia la izquierda y volver al sitio inicial, tengo que repetirlo constantemente
        let movimientoConstanteFlores = SKAction.repeatForever(SKAction.sequence([moverFlores, posicionInicialFlores]))
        
        
        // Creo un iterador para saber cuantas veces tengo que repetit la imagen de las flores hasta que ocupe toda la pantalla
        for i in stride(from: 0, to: 3 + self.frame.size.width / texturaFlores.size().width, by: 1) {
            let franja_imagen = SKSpriteNode.init(texture: texturaFlores)
            // Recordemos que hay una tercera coordenada, la cual nos va a servir de cuan atras, va a estar esta imagen respecto de las otras imagenes
            franja_imagen.zPosition = -5 // Quiero que mi imagen del cielo, sea una imagen de fondo, por eso lo del signo negativo
            //Posiciono cada una de las franjas (trozos) de la imagen del cielo (cieloDefinitivo)
            franja_imagen.position = CGPoint(x: -330 + i*franja_imagen.size.width, y: franja_imagen.size.height - 307)
            // ejecuto esa animacion constante en cada franja
            franja_imagen.run(movimientoConstanteFlores)
            
            // Añado a la pantalla de mi aplicacion cada franja de la imagen del cielo (imagen cieloDefinitivo.png)
            movimientoDelConjunto.addChild(franja_imagen)
            
        }

        
        // Creo un iterador para saber cuantas veces tengo que repetit la imagen del cielo hasta que ocupe toda la pantalla
        for i in stride(from: 0, to: 3 + self.frame.size.width / texturaCielo.size().width, by: 1) {
            let franja_imagen = SKSpriteNode.init(texture: texturaCielo)
            // Recordemos que hay una tercera coordenada, la cual nos va a servir de cuan atras, va a estar esta imagen respecto de las otras imagenes
            franja_imagen.zPosition = -100 // Quiero que mi imagen del cielo, sea una imagen de fondo, por eso lo del signo negativo
            //Posiciono cada una de las franjas (trozos) de la imagen del cielo (cieloDefinitivo)
            franja_imagen.position = CGPoint(x: -275 + i*franja_imagen.size.width, y: franja_imagen.size.height - 130)
            // ejecuto esa animacion constante en cada franja
           franja_imagen.run(movimientoConstanteCielo)
            // Añado a la pantalla de mi aplicacion cada franja de la imagen del cielo (imagen cieloDefinitivo.png)
            movimientoDelConjunto.addChild(franja_imagen)
            
        }
        
        // Ahora creo la textura del suelo, textura es lo mismo que decir imagen
        let texturaSuelo = SKTexture(imageNamed: "sueloDefinitivo")
        texturaSuelo.filteringMode = SKTextureFilteringMode.nearest
        // Para causar la sensación de que la abeja avanza, el suelo se tiene que despplazar hacia la izquierda
        let moverSuelo = SKAction.moveBy(x: -texturaSuelo.size().width, y: 0, duration:TimeInterval( 0.01 * texturaSuelo.size().width))
        // luego tengo que colocar el suelo en su posición normal
        let posicionInicialSuelo = SKAction.moveBy(x: texturaSuelo.size().width, y: 0, duration: 0.0005)
        // Esta acción de desplazar hacia la izquierda y volver al sitio inicial, tengo que repetirlo constantemente
        let movimientoConstanteSuelo = SKAction.repeatForever(SKAction.sequence([moverSuelo, posicionInicialSuelo]))
        // Creo un iterador para saber cuantas veces tengo que repetit la imagen del suelo hasta que ocupe toda la pantalla
        for i in stride(from: 0, to: 3 + self.frame.size.width / texturaSuelo.size().width, by: 1) {
            let franja_imagen = SKSpriteNode.init(texture: texturaSuelo)
            // Recordemos que hay una tercera coordenada, la cual nos va a servir de cuan atras, va a estar esta imagen respecto de las otras imagenes
            franja_imagen.zPosition = -100 // Quiero que mi imagen del cielo, sea una imagen de fondo, por eso lo del signo negativo
            //Posiciono cada una de las franjas (trozos) de la imagen del suelo(sueloDefinitivo)
            franja_imagen.position = CGPoint(x: -400 + i*franja_imagen.size.width, y: franja_imagen.size.height - 890)
            // ejecuto esa animacion constante en cada franja
            //franja_imagen.run(movimientoConstanteSuelo)
            // Añado a la pantalla de mi aplicacion cada franja de la imagen del suelo (imagen sueloJR.png)
            movimientoDelConjunto.addChild(franja_imagen)
            
        }
        //Creo un tope o limite para el suelo, para que al caer la abejita, ésta no se "desaparezca" de la aplicación
        let limiteSuelo = SKNode()
        limiteSuelo.position = CGPoint(x: -400, y: texturaSuelo.size().height - 890)
        limiteSuelo.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: texturaSuelo.size().height))
        limiteSuelo.physicsBody?.isDynamic = false
        limiteSuelo.physicsBody?.categoryBitMask = categoriaSuelo
        movimientoDelConjunto.addChild(limiteSuelo)
        
        // Asocio esas variables a sus respectivas imágenes
        texturaPlantaFea = SKTexture(imageNamed: "plantaFea")
        texturaPlantaFea.filteringMode = SKTextureFilteringMode.nearest
        texturaAvispa = SKTexture(imageNamed: "avispa")
        texturaAvispa.filteringMode = SKTextureFilteringMode.nearest
        
        let distancia_acercamiento = CGFloat(self.frame.size.width / 8  + 900.0 )
        let enemigos_movimiento = SKAction.moveBy(x: -distancia_acercamiento - 200, y: 0.0, duration:TimeInterval(0.005 * distancia_acercamiento))
        let quitar_elementos = SKAction.removeFromParent()
        // Estas acciones de desplazarse y eliminar tengo que repetirlo
        repeticion = SKAction.sequence([enemigos_movimiento, quitar_elementos])
        
        
        let crearClonesEnemigos = SKAction.run({() in self.RepetirTodo()}) // lo que hace la función run es ejecutar todo lo que está entre sus parentesis, es decir este caso lo de RepetirTodo
        //los clones se van a separar entre ellos 4 segundos
        var tiempoEntreEnemigos = SKAction.wait(forDuration: 4.0)
        var crearClonesEnemigosSiguientes = SKAction.sequence([crearClonesEnemigos, tiempoEntreEnemigos])
        var crearParaSiempreClones = SKAction.repeatForever(crearClonesEnemigosSiguientes)
        self.run(crearParaSiempreClones)
        puntuacion = 0
        etiqueta_puntuacion.text = "Vamos! \(puntuacion)"
        etiqueta_puntuacion.fontName = "Times New Roman"
        etiqueta_puntuacion.fontSize = 100
        
        etiqueta_puntuacion.alpha = 0.4
        etiqueta_puntuacion.fontColor = UIColor.darkText
        etiqueta_puntuacion.zPosition = 0
        etiqueta_puntuacion.position = CGPoint(x: self.frame.size.width/40.0 - 156, y: self.frame.midY - 300 + 900 - 500 + 200)
        self.addChild(etiqueta_puntuacion)
        
        
    }
    func RepetirTodo(){
        // Tanto la avispa como la planta carnivora son enemigos de la abeja, asi k los asocio
        let conjuntoEnemigo = SKNode()
        
        conjuntoEnemigo.position = CGPoint(x: self.frame.size.width / 8 + 600, y: 0)
        conjuntoEnemigo.zPosition = -2
        
        let altura = UInt(self.frame.size.height / 10)
        let ordenada = UInt(arc4random()) % altura
        
        let planta = SKSpriteNode(texture: texturaPlantaFea)
        planta.position = CGPoint(x: -50 , y: CGFloat(ordenada) - 150)
        planta.physicsBody = SKPhysicsBody(texture: texturaPlantaFea, size: planta.size)
        planta.physicsBody?.isDynamic = false
        planta.physicsBody?.categoryBitMask = categoriaEnemigos
        planta.physicsBody?.contactTestBitMask = categoriaAbeja
        
        conjuntoEnemigo.addChild(planta)
        
        // lo mismo pero para la avispa
        
        let avispaMala = SKSpriteNode(texture: texturaAvispa)
        avispaMala.position = CGPoint(x: 290, y: CGFloat(ordenada) + planta.size.height + CGFloat(separacionEnemigos) - 340)
        avispaMala.physicsBody = SKPhysicsBody(texture: texturaAvispa, size: avispaMala.size)
        avispaMala.physicsBody?.isDynamic = false
        avispaMala.physicsBody?.categoryBitMask = categoriaEnemigos
        avispaMala.physicsBody?.contactTestBitMask = categoriaAbeja
        
        conjuntoEnemigo.addChild(avispaMala)
        var elQuePuntua = SKNode()
        elQuePuntua.position = CGPoint(x: planta.size.width + abejita.size.width/2, y: self.frame.midY)
        elQuePuntua.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: planta.size.width, height: self.frame.size.height))
        elQuePuntua.physicsBody?.isDynamic = false
        elQuePuntua.physicsBody?.categoryBitMask = categoriaPuntua
        elQuePuntua.physicsBody?.contactTestBitMask = categoriaAbeja
        conjuntoEnemigo.addChild(elQuePuntua)
        
        conjuntoEnemigo.run(repeticion)
        
        gestionDeEnemigos.addChild(conjuntoEnemigo)
        
        
    }
    func DeNuevoEscenario(){
        
        abejita.position = CGPoint(x: self.frame.size.width / 40.0 - 40, y: self.frame.midY)
        abejita.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        abejita.speed = 0
        reiniciar = false
        movimientoDelConjunto.speed = 1
        abejita.speed = 1
        self.backgroundColor = SKColor(red: 164/255, green: 235/255, blue: 237/255, alpha: 1)
        gestionDeEnemigos.removeAllChildren()
        
        puntuacion = 0
        etiqueta_puntuacion.text = "Vamos! \(puntuacion)"
        
        
    }
    
    // Esta función se ejecuta cuando se hacen toques en la pantalla
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Le aplico un impulso a la abejita
        //print(5)
        //print(abejita)
        if movimientoDelConjunto.speed > 0 {
        abejita.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        abejita.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
        }
        
        else if reiniciar == true {
            self.DeNuevoEscenario()
        }
        
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
       
        
    }
    func didBegin(_ contact: SKPhysicsContact) {
        if movimientoDelConjunto.speed > 0 {
            if ((contact.bodyA.categoryBitMask & categoriaPuntua) == categoriaPuntua || (contact.bodyB.categoryBitMask & categoriaPuntua) == categoriaPuntua) {
                puntuacion = puntuacion + 1
                etiqueta_puntuacion.text = "\(puntuacion)"
            }
            else{
                movimientoDelConjunto.speed = 0
                
                let reinicioJuego = SKAction.run({() in self.ReiniciarJuego()})
                
                let cambiarColorCielo = SKAction.run({() in self.CieloRojo()})
                // la accion de cambiar el color del cielo y el reinicio tiene que ir de la mano:
                var colorCielo_reinicio = SKAction.group([cambiarColorCielo, reinicioJuego])
                self.run(colorCielo_reinicio)
            }
        }
    }
    func CieloRojo(){
        self.backgroundColor = UIColor.red
    }
    func ReiniciarJuego(){
        reiniciar = true
    }
}
