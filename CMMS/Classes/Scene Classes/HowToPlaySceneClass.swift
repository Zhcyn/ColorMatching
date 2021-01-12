import SpriteKit
class HowToPlaySceneClass: SKScene{
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
    private var colorState = ColorState.White;
    private var player: Player?;
    private var itemController = ItemController();
    private var red = 0;
    private var green = 0;
    private var blue = 0;
    private var yellow = 0;
    private var white = 1;
    private var orange = 0;
    private var purple = 0;
    private var rainbow = 0;
    private var fallspeed = 10.0;
    private var clickSound: SKAudioNode!
    private var lowerPanel: SKNode?
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        blue = 0;
        red = 0;
        yellow = 0;
        colorState = ColorState.Black;
        setColor();
        setBackGround();
        for touch in touches{
            let location = touch.location(in: self)
            if atPoint(location).name == "Back" {
                if let scene = MainMenuScene(fileNamed: "MainMenu") {
                    scene.scaleMode = .aspectFill
                    view!.presentScene(scene,transition: SKTransition.doorsOpenHorizontal(withDuration: 0.5))
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
                colorState = ColorState.Orange;
            }else if atPoint(location).name == "Blue" && atPoint(location).name == "Yellow"  {
                blue = 1;
                yellow = 1;
                colorState = ColorState.Green;
            }else if atPoint(location).name == "Blue" && atPoint(location).name == "Red"  {
                red = 1;
                blue = 1;
                colorState = ColorState.Purple;
                }
            }
        setBackGround()
         setColor();
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
    override func didMove(to view: SKView) {
        interstitialGame()
//        let controller = self.view?.window?.rootViewController as! GameViewController
        if let clickURL = Bundle.main.url(forResource: "click3", withExtension: "wav") {
            clickSound = SKAudioNode(url: clickURL)
            clickSound.autoplayLooped = false;
            print("clicksound activated")
            addChild(clickSound)
        }
    }
    private func interstitialGame(){
        player = childNode(withName: "Player") as! Player?;
        lowerPanel = childNode(withName: "lowerPanel")
        if UIDevice.current.userInterfaceIdiom == .pad {
            player?.position.y = -350
            lowerPanel?.position.y = -450
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
}
