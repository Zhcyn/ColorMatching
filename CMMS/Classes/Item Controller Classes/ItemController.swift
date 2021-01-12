import SpriteKit
struct ColliderType {
    static let PLAYER: UInt32 = 0;
    static let FRUIT_AND_BOMB: UInt32 = 1;
}
class ItemController {
    private var minX = CGFloat(-300), maxX = CGFloat(300);
    public func spawnItems() -> SKShapeNode{
         let item: SKShapeNode?;
         let color1 = hexStringToUIColor(hex: "#0392cf") 
         let color2 = hexStringToUIColor(hex: "#ee4035") 
         let color3 = hexStringToUIColor(hex: "#7bc043") 
         let color4 = hexStringToUIColor(hex: "#FDF146") 
         let color5 = hexStringToUIColor(hex: "#f37736") 
         let color6 = hexStringToUIColor(hex: "#b967ff") 
         let color7 = hexStringToUIColor(hex: "#ffffff") 
         let shapeNum = Int(randomBetweenNumbers(firstNum: 1, secondNum: 3))
         let num = Int(randomBetweenNumbers(firstNum: 1, secondNum: 8))
        if(shapeNum == 1){
            item = SKShapeNode(rectOf: CGSize(width: 140, height: 140),cornerRadius: CGFloat(15.0))
             item!.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 140, height: 140))
        }else{
             item = SKShapeNode(circleOfRadius: 80)
             item!.physicsBody = SKPhysicsBody(circleOfRadius: 80 )
        }
            if(num == 1){
                item!.fillColor = color1;
            }
            else if(num == 2){
                item!.fillColor = color2;
            }
            else if(num == 3){
                item!.fillColor = color3;
            }
            else if(num == 4){
                item!.fillColor = color4;
            }
            else if(num == 5){
                item!.fillColor = color5;
            }
            else if(num == 6){
                item!.fillColor = color6;
            }
            else{
                item!.fillColor = color7;
            }
            item!.name = "Enemy\(num)"
            item!.strokeColor = UIColor.white
            item!.physicsBody?.categoryBitMask = ColliderType.FRUIT_AND_BOMB;
            item!.zPosition = 2;
            item!.physicsBody?.affectedByGravity = false;
            item!.position.x = randomBetweenNumbers(firstNum: minX, secondNum: maxX)
            item!.position.y = randomBetweenNumbers(firstNum: 1000, secondNum: 1200)
        return item!;
    }
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) ->CGFloat{
        return CGFloat(arc4random())/CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
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
}
