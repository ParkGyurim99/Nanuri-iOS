//
//  MyPageViewModel.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/01/31.
//

import SwiftUI
import Alamofire
import Combine
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import NaverThirdPartyLogin

class MyPageViewModel : NSObject, ObservableObject {
    @Published var showLoginProgress : Bool = false
    
    private var subscription = Set<AnyCancellable>()
    
    func OAuthLogin(type : String, accessToken : String) {
        let url = baseURL + "/login/oauth/" + type
        
        AF.request(url,
                   method : .post,
                   parameters : ["accessToken" : accessToken]
        ).responseJSON { response in print(response) }
        .publishDecodable(type : OAuthLoginResponse.self)
        .compactMap { $0.value }
        .sink { completion in
            switch completion {
                case let .failure(error) :
                    print("OAuth Login Fail : " + error.localizedDescription)
                case .finished :
                    print("OAuth Login Finished")
            }
        } receiveValue: { [weak self] recievedValue in
            User.shared.userInfo = recievedValue
            withAnimation {self?.showLoginProgress = false}
        }.store(in: &subscription)
    }
    
    func refrshToken() {
        let url = baseURL + "/token"
        
        guard let userInfo = User.shared.userInfo else { return }
        let headerAuthInfo = userInfo.token.tokenType + " " + userInfo.token.accessToken

        AF.request(url,
                   method: .get,
                   headers: ["X-AUTH-TOKEN" : headerAuthInfo]
        ).responseJSON { response in print(response) }
        .publishDecodable(type : Token.self)
        .compactMap { $0.value }
        .sink { completion in
            switch completion {
                case let .failure(error) :
                    print("Token Refresh Fail : " + error.localizedDescription)
                case .finished :
                    print("Token Refresh Finished")
            }
        } receiveValue: { recievedValue in
            User.shared.userInfo?.token = recievedValue
            print("Refreshed Token :")
            print(User.shared.userInfo?.token as Any)
        }.store(in: &subscription)
    }
    
    func kakaoAccountSignOut() {
        UserApi.shared.logout { (error) in
            if let error = error { print(error) }
            else { print("logout() success.") }
        }
    }
    
    func kakaoAccountUnlink() {
        UserApi.shared.unlink { (error) in
            if let error = error { print(error) }
            else { print("unlink() success.") }
        }
    }
}

// Naver Login Delegate - call back
extension MyPageViewModel : UIApplicationDelegate, NaverThirdPartyLoginConnectionDelegate {
    // 로그인에 성공했을 경우 호출
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("[Success] : Success Naver Login")
        User.shared.loginType = "naver"
        
        print("App Name : " + NaverThirdPartyLoginConnection.getSharedInstance().appName)
        print("Access Token : " + NaverThirdPartyLoginConnection.getSharedInstance().accessToken)
        print("Token Type : " + NaverThirdPartyLoginConnection.getSharedInstance().tokenType)
        
        OAuthLogin(type: User.shared.loginType!, accessToken: NaverThirdPartyLoginConnection.getSharedInstance().accessToken)
    }
    
    // 접근 토큰 갱신
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print("[Success] : Success Naver AccessToken Refresh")
    }
    
    // 로그아웃 할 경우 호출(토큰 삭제)
    func oauth20ConnectionDidFinishDeleteToken() {

        print("[Success] : Success Naver Logout")
    }
    
    // 모든 Error
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("[Error] :", error.localizedDescription)
    }
}
