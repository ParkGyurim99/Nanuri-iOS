//
//  Participant+ResponseData.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/02/16.
//

import Foundation

struct ParticipantInfo : Codable {
    var count : Int
    var status : Int
    var body : [Participant]
}

struct Participant : Codable, Hashable {
    var lessonId : Int
    var userId : Int
}
