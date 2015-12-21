//
//  GameScene.swift
//  RunTowardTheLight
//
//  Created by 兎澤佑 on 2015/06/27.
//  Copyright (c) 2015年 兎澤佑. All rights reserved.
//

import SpriteKit
import Foundation

protocol GameSceneDelegate: class {
    func displayTouched(touch: UITouch?)

    func actionButtonTouched()
}

class GameScene: SKScene {
    var gameSceneDelegate: GameSceneDelegate?
    var sheet: TileSheet!
    var textBox_: Dialog!
    var actionButton_: UIButton!

    override func didMoveToView(view: SKView) {
        sheet = TileSheet(jsonFileName: "sample_map02",
                          frameWidth: self.frame.width,
                          frameHeight: self.frame.height)
        sheet.addTilesheetTo(self)
        sheet.placementObjectOnTileWithName("tasuwo",
                                            image_name: "plr_down.png",
                                            coordinate: TileCoordinate(x: 10, y: 10))

        // 「Start」を表示。
        actionButton_ = UIButtonAnimated(frame: CGRectMake(0, 0, 100, 40))
        actionButton_.backgroundColor = UIColor.blackColor();
        actionButton_.setTitle("TALK", forState: UIControlState.Normal)
        actionButton_.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        actionButton_.layer.cornerRadius = 10.0
        actionButton_.layer.position = CGPoint(x: self.view!.frame.width / 2, y: 200)
        actionButton_.addTarget(self, action: "actionButtonTouched:", forControlEvents: .TouchUpInside)
        actionButton_.hidden = true
        self.view!.addSubview(actionButton_);

        textBox_ = Dialog(frame_width: self.frame.width,
                          frame_height: self.frame.height)
        textBox_.hide()
        textBox_.setPosition(Dialog.DIALOG_POSITION.top)
        textBox_.addTo(self)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        gameSceneDelegate?.displayTouched(touches.first)
    }

    func actionButtonTouched(sender: UIButton) {
        gameSceneDelegate?.actionButtonTouched()
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}