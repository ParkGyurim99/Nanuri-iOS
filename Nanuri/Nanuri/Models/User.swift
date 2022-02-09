//
//  User.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/02/10.
//

import Foundation

class User : ObservableObject {
    static let shared = User()
    
    @Published var userInfo : OAuthLoginResponse?
    @Published var loginType : String?
    
    func isLoggedIn() -> Bool {
        if userInfo != nil { return true }
        else { return false }
    }
    
    // func logout()
    // func unlink()
    
    // social token 확인하는 함수
}
