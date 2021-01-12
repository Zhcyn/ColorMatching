import SpriteKit
import StoreKit
extension SKSpriteNode {
    func addGlow(radius: Float = 200) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        addChild(effectNode)
        effectNode.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius":radius])
    }
}
class GamePlaySceneClass: SKScene, SKPhysicsContactDelegate{
    enum ColorState {
        case Red
        case Green
        case Blue
        case Yellow
        case White
        case Orange
        case Purple
        case Black
    }
    private var player: Player?;
    private var center = CGFloat();
    private var canMove = false, moveLeft = false;
    private var canFall = true, fall = true;
    private var itemController = ItemController();
    private var scoreLabel: SKLabelNode?
    private var score = 0;
    private var gameState = 0;
    private var colorState = ColorState.White;
    private var background: SKSpriteNode?;
    private var red = 0;
    private var green = 0;
    private var blue = 0;
    private var yellow = 0;
    private var white = 1;
    private var orange = 0;
    private var purple = 0;
    private var rainbow = 0;
    private var gameSpeed = 2.2;
    private var fallspeed = 12.0;
    private var backgroundMusic: SKAudioNode!
    private var clickSound: SKAudioNode!
    private var gameOver = false;
    private var gameoverBox: SKSpriteNode?;
    private var currentScoreLabel: SKLabelNode?
    private var secondHighscoreLabel: SKLabelNode?
    private var scoreBox: SKSpriteNode?;
    private var restartButton: SKSpriteNode?;
    private var rateButton: SKSpriteNode?;
    private var viewController: GameViewController!
    private var difficulty = 0;
    private var scoreSound: SKAudioNode!;
    private var musicOn = true;
    private var musicButton: SKSpriteNode?
    private var showAd = 0;
    private var playedConfetti = false;
    private var gameTimer: Timer!
    private var shareButton: SKSpriteNode?
    private var gameOverSound: SKAudioNode!
    private var scoreUpLabel: SKLabelNode?
    private var lowerPanel: SKNode?
    private var rateGameCounter = 0;
    override func didMove(to view: SKView) {
        initilizeGame()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideAd"), object: nil)
//        let controller = self.view?.window?.rootViewController as! GameViewController
        if let musicURL = Bundle.main.url(forResource: "backgroundmusic", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
        let returnValueAudio = UserDefaults.standard.integer(forKey: "audio")
        if  returnValueAudio == 0 {
            backgroundMusic?.run(SKAction.changeVolume(to: Float(0),duration: 0));
            musicOn = false;
            musicButton?.texture = SKTexture(imageNamed:"audioOff")
        }else{
            backgroundMusic?.run(SKAction.changeVolume(to: Float(1.0),duration: 0));
            musicOn = true;
            musicButton?.texture = SKTexture(imageNamed:"audioOn")
        }
        if let clickURL = Bundle.main.url(forResource: "click3", withExtension: "wav") {
            clickSound = SKAudioNode(url: clickURL)
            clickSound.autoplayLooped = false;
            print("clicksound activated")
            addChild(clickSound)
        }
        if let scoreSoundURL = Bundle.main.url(forResource: "scoreSound", withExtension: "wav") {
            scoreSound = SKAudioNode(url: scoreSoundURL)
            scoreSound.autoplayLooped = false;
            print("scoreSound activated")
            addChild(scoreSound)
        }
        if let gameOverSoundURL = Bundle.main.url(forResource: "gameOverSound", withExtension: "wav") {
            gameOverSound = SKAudioNode(url: gameOverSoundURL)
            gameOverSound.autoplayLooped = false;
            print("gameover activated")
            addChild(gameOverSound)
        }
    }
    override func update(_ deltaTime: TimeInterval) {
        if(!gameOver){
            manageColorObject()
        }
        if(score > 100){
            rotateObject()
        }
        let returnValue = UserDefaults.standard.integer(forKey: "HIGHSCORE")
        if(score > returnValue && !playedConfetti){
            let controller = self.view?.window?.rootViewController as! GameViewController
            controller.startEmitter()
            playedConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                controller.stopEmitter()
            })
        }
        if((difficulty >= 10) && score < 100){
            fallspeed += 0.4;
            difficulty = 0;
            gameSpeed -= 0.15;
            gameTimer.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(gameSpeed), target: self, selector: #selector(GamePlaySceneClass.spawnItems), userInfo: nil, repeats: true);
        }else if ((difficulty >= 10) && score > 100){
            fallspeed += 0.1;
            difficulty = 0;
            gameSpeed -= 0.05;
            gameTimer.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(gameSpeed), target: self, selector: #selector(GamePlaySceneClass.spawnItems), userInfo: nil, repeats: true);
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        restartButton?.texture = SKTexture(imageNamed:"red_button01")
        rateButton?.texture = SKTexture(imageNamed:"blue_button01")
        shareButton?.texture = SKTexture(imageNamed:"yellow_button01")
        blue = 0;
        red = 0;
        yellow = 0;
        white = 1
        colorState = ColorState.White
        setBackGround();
        for touch in touches{
            let location = touch.location(in: self)
             if atPoint(location).name == "playAgain" {
                 gameOver = false;
                 restartGame();
                 scoreLabel?.isHidden = false;
                 gameoverBox?.isHidden = true;
            }else if atPoint(location).name == "Rate" {
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                } else {
                }
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         clickSound.run(SKAction.play());
        for touch in touches{
            let location = touch.location(in: self)
            if atPoint(location).name == "Blue" {
                blue = 1;
                colorState = ColorState.Blue;
            }else if atPoint(location).name == "Yellow" {
                yellow = 1;
                colorState = ColorState.Yellow;
            }else if atPoint(location).name == "Red" {
                red = 1;
                colorState = ColorState.Red;
            }else if atPoint(location).name == "Red" && atPoint(location).name == "Yellow"  {
                red = 1;
                yellow = 1;
            }else if atPoint(location).name == "Blue" && atPoint(location).name == "Yellow"  {
                blue = 1;
                yellow = 1;
            }else if atPoint(location).name == "Blue" && atPoint(location).name == "Red"  {
                red = 1;
                blue = 1;
            }else if atPoint(location).name == "playAgain" {
                restartButton?.texture = SKTexture(imageNamed:"red_button02")
            }else if atPoint(location).name == "Rate" {
                rateButton?.texture = SKTexture(imageNamed:"blue_button05")
            }else if atPoint(location).name == "audioButton" {
                if(musicOn){
                    UserDefaults.standard.set(0, forKey: "audio")
                    backgroundMusic.run(SKAction.changeVolume(to: Float(0),duration: 0));
                    musicOn = false;
                    musicButton?.texture = SKTexture(imageNamed:"audioOff")
                }else{
                    UserDefaults.standard.set(1, forKey: "audio")
                    backgroundMusic.run(SKAction.changeVolume(to: Float(1.0),duration: 0));
                    musicOn = true;
                    musicButton?.texture = SKTexture(imageNamed:"audioOn")
                }
            }else if atPoint(location).name == "Share" {
                shareButton?.texture = SKTexture(imageNamed:"yellow_button01")
                let controller = self.view?.window?.rootViewController as! GameViewController
                controller.testShare()
            }
            setColor()
            setBackGround()
        }
    }
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody();
        var secondBody = SKPhysicsBody();
        if contact.bodyA.node?.name == "Player"{
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;
        }else{
            firstBody = contact.bodyB;
            secondBody = contact.bodyA;
        }
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Enemy1" && colorState == ColorState.Blue{
            score+=2;
            difficulty+=2;
            scoreUpLabel?.text = "+2"
            scoreSound.run(SKAction.play())
            scoreLabel?.text = String(score);
            secondBody.node?.removeFromParent();
        }else if firstBody.node?.name == "Player" && secondBody.node?.name == "Enemy2" && colorState == ColorState.Red{
            score+=2;
            difficulty+=2;
            scoreUpLabel?.text = "+2"
            scoreSound.run(SKAction.play())
            scoreLabel?.text = String(score);
            secondBody.node?.removeFromParent();
        }else if firstBody.node?.name == "Player" && secondBody.node?.name == "Enemy3" && colorState == ColorState.Green{
            score+=3;
            difficulty+=3;
            scoreUpLabel?.text = "+3"
            scoreSound.run(SKAction.play())
            scoreLabel?.text = String(score);
            secondBody.node?.removeFromParent();
        }else if firstBody.node?.name == "Player" && secondBody.node?.name == "Enemy4" && colorState == ColorState.Yellow{
            score+=2;
            scoreUpLabel?.text = "+2"
            difficulty+=2;
            scoreSound.run(SKAction.play())
            scoreLabel?.text = String(score);
            secondBody.node?.removeFromParent();
        }else if firstBody.node?.name == "Player" && secondBody.node?.name == "Enemy5" && colorState == ColorState.Orange{
            score+=3;
            scoreUpLabel?.text = "+3"
            difficulty+=3;
            scoreSound.run(SKAction.play())
            scoreLabel?.text = String(score);
            secondBody.node?.removeFromParent();
        }else if firstBody.node?.name == "Player" && secondBody.node?.name == "Enemy6" && colorState == ColorState.Purple{
            score+=3;
            scoreUpLabel?.text = "+3"
            difficulty+=3;
            scoreSound.run(SKAction.play())
            scoreLabel?.text = String(score);
            secondBody.node?.removeFromParent();
        }else if firstBody.node?.name == "Player" && secondBody.node?.name == "Enemy7" && colorState == ColorState.White{
            score+=1;
            scoreUpLabel?.text = "+1"
            difficulty+=1;
            scoreSound.run(SKAction.play())
            scoreLabel?.text = String(score);
            secondBody.node?.removeFromParent();
        }else{
            let rateGameValue = UserDefaults.standard.integer(forKey: "RATEGAME")
            UserDefaults.standard.set(rateGameValue+1, forKey: "RATEGAME")
            print(rateGameValue)
            if(rateGameValue >= 10) {
                    if #available(iOS 10.3, *) {
                        SKStoreReviewController.requestReview()
                    } else {
                    }
                UserDefaults.standard.set(0, forKey: "RATEGAME")
            }
            removeButtons()
            gameOverSound.run(SKAction.play())
            secondBody.node?.removeFromParent();
            backgroundMusic.run(SKAction.changeVolume(to: Float(0),duration: 0));
            let returnValue = UserDefaults.standard.integer(forKey: "HIGHSCORE")
            let adValue = UserDefaults.standard.integer(forKey: "SHOWAD")
            saveHighScore();
            gameOver = true;
            if(score < returnValue){
                currentScoreLabel?.text = "SCORE: " + String(score)
            }else{
                currentScoreLabel?.text = "NEW BEST: " + String(score)
            }
            secondHighscoreLabel?.text = "BEST: " + String(returnValue)
            scoreLabel?.isHidden = true;
            gameoverBox?.isHidden = false;
            let controller = self.view?.window?.rootViewController as! GameViewController
            if(score > returnValue){
                controller.startEmitter()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    controller.stopEmitter()
                })
            }
            if(adValue < 5){
                UserDefaults.standard.set(adValue+1, forKey: "SHOWAD")
            }else if adValue >= 5{
                UserDefaults.standard.set(0, forKey: "SHOWAD")
            }
            for child in children{
                if child.name == "Enemy1" || child.name == "Enemy2" || child.name == "Enemy3"  || child.name == "Enemy4"  || child.name == "Enemy5"  || child.name == "Enemy6"  || child.name == "Enemy7"  {
                        child.removeFromParent()
                }
            }
        }
        print("GAMESPEED: " + String(gameSpeed))
        print("FALLSPED: " + String(fallspeed))
        scoreUpLabel?.alpha = 1
        scoreUpLabel?.isHidden = false;
        let fadeAction = SKAction.fadeOut(withDuration: 1)
        scoreUpLabel?.run(fadeAction)
    }
    private func initilizeGame(){
        physicsWorld.contactDelegate = self;
        physicsWorld.gravity = CGVector(dx:0.0 , dy:  -1.0 );
        self.view?.showsPhysics = false;
        player = childNode(withName: "Player") as! Player?;
        player?.initializePlayer();
        scoreLabel = childNode(withName: "ScoreLabel") as? SKLabelNode;
        scoreLabel?.text = "0";
        background = childNode(withName: "Background") as? SKSpriteNode;
        gameoverBox = childNode(withName: "gameoverBox") as? SKSpriteNode;
        gameoverBox?.isHidden = true;
        currentScoreLabel = gameoverBox?.childNode(withName: "currentScoreLabel") as? SKLabelNode;
        secondHighscoreLabel = gameoverBox?.childNode(withName: "highScoreLabel") as? SKLabelNode;
        restartButton = gameoverBox?.childNode(withName: "playAgain") as? SKSpriteNode;
        rateButton = gameoverBox?.childNode(withName: "Rate") as? SKSpriteNode;
        musicButton = childNode(withName: "audioButton") as? SKSpriteNode
        shareButton = gameoverBox?.childNode(withName: "Share") as? SKSpriteNode
        scoreUpLabel = childNode(withName: "scoreUp") as? SKLabelNode;
        scoreUpLabel?.isHidden = true;
        lowerPanel = childNode(withName: "lowerPanel");
        if UIDevice.current.userInterfaceIdiom == .pad {
            scoreLabel?.position.y = 300
            scoreUpLabel?.position.y = 200;
            player?.position.y = -350
            lowerPanel?.position.y = -450
        }
        center = self.frame.size.width / self.frame.size.height;
        if(!gameOver){
         gameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(gameSpeed), target: self, selector: #selector(GamePlaySceneClass.spawnItems), userInfo: nil, repeats: true);
        }
    }
    private func manageColorObject(){
        for child in children{
        if child.name == "Enemy1" || child.name == "Enemy2" || child.name == "Enemy3" || child.name == "Enemy4" || child.name == "Enemy5" || child.name == "Enemy6" || child.name == "Enemy7" {
                    child.position.y = child.position.y - (CGFloat(fallspeed))
            }
        }
    }
    @objc func spawnItems(){
        if(!gameOver){
            self.scene?.addChild(itemController.spawnItems());
        }
    }
    private func rotateObject(){
        for child in children{
            if child.name == "Enemy1" || child.name == "Enemy2" || child.name == "Enemy3" || child.name == "Enemy4" || child.name == "Enemy5" || child.name == "Enemy6" || child.name == "Enemy7" {
                child.zRotation += 0.03
            }
        }
    }
    func removeButtons(){
        background?.zPosition = 3
    }
    @objc func restartGame(){
        let returnValueAudio = UserDefaults.standard.integer(forKey: "audio")
        if(returnValueAudio == 1){
        backgroundMusic.run(SKAction.changeVolume(to: Float(1),duration: 0));
        }
        if let scene = GamePlaySceneClass(fileNamed: "GamePlayScene"){
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.doorsOpenHorizontal(withDuration: TimeInterval(0.5)))
        }
    }
    func explosionEmitter() -> SKEmitterNode?{
        return SKEmitterNode(fileNamed: "BlockParticel")
    }
    func setBackGround(){
        if( colorState == ColorState.Green){
            let color = hexStringToUIColor(hex: "#7bc043")
            player?.color = color;
        }else if(colorState == ColorState.Purple){
            let color = hexStringToUIColor(hex: "#b967ff")
            player?.color = color;
        }else if(colorState == ColorState.Orange){
            let color = hexStringToUIColor(hex: "#f37736")
            player?.color = color;
        }else if (colorState == ColorState.White){
            player?.color = UIColor.white;
        }else if (colorState == ColorState.Red){
            let color = hexStringToUIColor(hex: "#ee4035")
            player?.color = color;
        }else if (colorState == ColorState.Blue){
            let color = hexStringToUIColor(hex: "#0392cf")
            player?.color = color;
        }else if (colorState == ColorState.Yellow){
            let color = hexStringToUIColor(hex: "#FDF146")
            player?.color = color;
        }
    }
    func setColor(){
        if((blue == 1 && yellow == 1) && (red == 0)){
            white = 0;
            yellow = 0;
            red = 0;
            blue = 0;
            orange = 0;
            purple = 0;
            green = 1;
            colorState = ColorState.Green;
        }else if((blue == 1 && red == 1) && (yellow == 0)){
            white = 0;
            yellow = 0;
            red = 0;
            blue = 0;
            orange = 0;
            purple = 1;
            green = 0;
            colorState = ColorState.Purple;
        }else if((yellow == 1 && red == 1) && (blue == 0)){
            white = 0;
            yellow = 0;
            red = 0;
            blue = 0;
            orange = 1;
            purple = 0;
            green = 0;
            colorState = ColorState.Orange;
        }else if ( yellow == 0 && red == 0 && blue == 0){
            white = 1;
            yellow = 0;
            red = 0;
            blue = 0;
            orange = 0;
            purple = 0;
            green = 0;
            colorState = ColorState.White;
        }
    }
    func hexStringToUIColor(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if(cString.hasPrefix("#")){
            cString.remove(at: cString.startIndex)
        }
        if((cString.count) != 6){
            return UIColor.gray
        }
        var rgbValue:UInt32 = 0;
        Scanner(string: cString).scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16 ) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    func saveHighScore() {
        let returnValue = UserDefaults.standard.integer(forKey: "HIGHSCORE")
        UserDefaults.standard.set(score, forKey: "CURRENTSCORE")
        if score > returnValue{
        UserDefaults.standard.set(score, forKey: "HIGHSCORE")
        }
    }
    public func getScore() -> Int{
        return score;
    }
    func getAudioSettings(){
        let returnValue = UserDefaults.standard.integer(forKey: "audio")
        if returnValue == 1 {
            backgroundMusic.run(SKAction.changeVolume(to: Float(0),duration: 0));
        }else{
            backgroundMusic.run(SKAction.changeVolume(to: Float(1),duration: 0));
        }
}
}
