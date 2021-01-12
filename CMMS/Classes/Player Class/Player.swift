import SpriteKit

//class Player: SKSpriteNode
 
class Player: SKSpriteNode {
    
    private var minX = CGFloat(-200), maxX = CGFloat(200);

    func initializePlayer(){
        name = "Player";

        physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width,
                                                        height: size.height));
        physicsBody?.affectedByGravity = false;
        physicsBody?.isDynamic = false;
        physicsBody?.categoryBitMask = ColliderType.PLAYER;
        physicsBody?.contactTestBitMask = ColliderType.FRUIT_AND_BOMB;

    }


}
