//
//  Map.swift
//  SwiftRPG
//
//  Created by 兎澤佑 on 2016/02/22.
//  Copyright © 2016年 兎澤佑. All rights reserved.
//

import Foundation
import SpriteKit

open class Map {
    /// タイルシート
    fileprivate(set) var sheet: TileSheet? = nil
    
    ///  コンストラクタ
    ///
    ///  - parameter mapName:     マップである JSON ファイルの名前
    ///  - parameter frameWidth:  フレームの幅
    ///  - parameter frameHeight: フレームの高さ
    ///
    ///  - returns:
    init?(mapName: String,
          frameWidth: CGFloat,
          frameHeight: CGFloat)
    {
        let parser: TiledMapJsonParser
        do {
            parser = try TiledMapJsonParser(fileName: mapName)
        } catch ParseError.illegalJsonFormat {
            print("Invalid JSON format in \(mapName)")
            return nil
        } catch ParseError.jsonFileNotFound {
            print("JSON file \(mapName) is not found")
            return nil
        } catch {
            return nil
        }

        let tiles: Dictionary<TileCoordinate, Tile>
        var objects: Dictionary<TileCoordinate, [Object]>
        do {
            let cols, rows: Int
            (cols, rows) = try parser.getLayerSize()
            let tileProperties = try parser.getTileProperties()
            let tileSets = try parser.getTileSets()
            let collisionLayer = try parser.getInfoFromLayer(cols, layerTileRows: rows, kind: .collision)
            let tileLayer = try parser.getInfoFromLayer(cols, layerTileRows: rows, kind: .tile)
            let objectLayer = try parser.getInfoFromLayer(cols, layerTileRows: rows, kind: .object)
            tiles = try Tile.createTiles(rows,
                                         cols: cols,
                                         properties: tileProperties,
                                         tileSets: tileSets,
                                         collisionPlacement: collisionLayer,
                                         tilePlacement: tileLayer)
            objects = try Object.createObjects(tiles,
                                               properties: tileProperties,
                                               tileSets: tileSets,
                                               objectPlacement: objectLayer)
        } catch ParseError.invalidValueError(let string) {
            print(string)
            return nil
        } catch ParseError.swiftyJsonError(let errors) {
            for error in errors { print(error!) }
            return nil
        } catch MapObjectError.failedToGenerate(let string) {
            print(string)
            return nil
        } catch {
            return nil
        }

        let sheet = TileSheet(parser: parser,
                              frameWidth: frameWidth,
                              frameHeight: frameHeight,
                              tiles: tiles,
                              objects: objects)
        self.sheet = sheet!
    }

    func wait(_ time: Int, callback: @escaping () -> Void) {
        self.sheet?.runAction([SKAction.wait(forDuration: TimeInterval(time))], callback: callback)
    }

    func addSheetTo(_ scene: SKScene) {
        self.sheet!.addTo(scene)
    }

    func getObjectByName(_ name: String) -> Object? {
        return self.sheet?.getObjectByName(name)
    }

    func getObjectCoordinateByName(_ name: String) -> TileCoordinate? {
        return self.sheet?.getObjectCoordinateByName(name)
    }

    func removeObject(_ id: MapObjectId) {
        self.sheet?.removeObject(id)
    }

    func getAllObjects() -> [Object] {
        return (self.sheet?.getAllObjects())!
    }

    func setObject(_ object: Object) {
        let coordinate = TileCoordinate.getTileCoordinateFromSheetCoordinate(object.position)
        self.sheet?.setObject(object: object, coordinate: coordinate)
    }

    func setEventsOf(_ objectId: MapObjectId, coordinate: TileCoordinate) {
        self.sheet?.setEventsOf(objectId, coordinate: coordinate)
    }

    func getMapObjectsOn(_ coordinate: TileCoordinate) -> [MapObject]? {
        return self.sheet?.getMapObjectsOn(coordinate)
    }

    func getEventsOn(_ coordinate: TileCoordinate) -> [EventListener] {
        return (self.sheet?.getEventsOn(coordinate))!
    }

    func setCollisionOn(coordinate: TileCoordinate) {
        self.sheet?.getTileOn(coordinate)!.setCollision()
    }

    func removeCollisionOn(coordinate: TileCoordinate) {
        self.sheet?.getTileOn(coordinate)!.removeCollision()
    }

    func canPass(_ coordinate: TileCoordinate) -> Bool {
        if let mapObjects = self.sheet?.getMapObjectsOn(coordinate) {
            for mapObject in mapObjects {
                if mapObject.hasCollision { return false }
            }
        }
        return true
    }

    func updateObjectPlacement(_ object: Object, departure: TileCoordinate, destination: TileCoordinate) {
        self.sheet?.replaceObject(object.id, departure: departure, destination: destination)
        print(destination.description)
    }

    ///  オブジェクトのZ方向の位置を更新する
    func updateObjectsZPosition() {
        var objects: [(Object, CGFloat)] = []

        for object in (self.sheet?.getAllObjects())! {
            objects.append((object, object.position.y))
        }
        
        // Y座標に基づいてオブジェクトを並べ替え，zPosition を更新する
        objects.sort { $0.1 > $1.1 }
        let base = zPositionTable.BASE_OBJECT_POSITION
        var incremental: CGFloat = 0.0
        for (obj, _) in objects {
            obj.setZPosition(base + incremental)
            incremental += 1
        }
    }
}
