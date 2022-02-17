//
//  Applicant+ResponseData.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/02/16.
//

import Foundation

struct ApplicantInfo : Codable {
    var count : Int
    var status : Int
    var body : [Applicant]
}

struct Applicant : Codable, Hashable {
    var lessonId : Int
    var userId : Int
    var status : String
    var registrationForm : String
}
