//
//  UserService.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/02/10.
//

import SwiftUI
import Alamofire
import Combine
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import NaverThirdPartyLogin

class UserService : NSObject, ObservableObject {
    static let shared = UserService()
    
    @Published var userInfo : OAuthLoginResponse?
    @Published var loginType : String?
    
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
            withAnimation { self?.userInfo = recievedValue }
        }.store(in: &subscription)
    }
    
    func refrshToken() {
        let url = baseURL + "/token"
        
        guard let userInfo = UserService.shared.userInfo else { return }
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
            UserService.shared.userInfo?.token = recievedValue
            print("Refreshed Token :")
            print(UserService.shared.userInfo?.token as Any)
        }.store(in: &subscription)
    }
    
    func kakaoLogin() {
        if (UserApi.isKakaoTalkLoginAvailable()) {
            //카카오톡이 설치되어있다면 카카오톡을 통한 로그인 진행
            UserApi.shared.loginWithKakaoTalk { [weak self] (oauthToken, error) in
                if let error = error { print(error.localizedDescription) }
                else {
                    print("loginWithKakaoTalk() success.")
                    TokenManager.manager.setToken(oauthToken)
                    
                    if let accessToken = oauthToken?.accessToken {
                        self?.loginType = "kakao"
                        print("kakao access token : " + accessToken)
                        self?.OAuthLogin(type: "kakao", accessToken: accessToken)
                        
                    }
                }
            }
        } else {
            /*
            //카카오톡이 설치되어있지 않다면 사파리에서 카카오 계정을 통한 로그인 진행
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoAccount() success.")

                    //do something
                    _ = oauthToken
                }
            }
            */
            
            // Appstore에서 카카오톡 열기
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id362057947"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
    
    func naverLogin() {
//        if NaverThirdPartyLoginConnection
//            .getSharedInstance()
//            .isPossibleToOpenNaverApp() // Naver App이 깔려있는지 확인하는 함수
//        { }
            NaverThirdPartyLoginConnection.getSharedInstance().delegate = self
            NaverThirdPartyLoginConnection
                .getSharedInstance()
                .requestThirdPartyLogin()
    }
    
    func logout() {
        switch loginType {
            case "kakao" :
                UserApi.shared.logout { (error) in
                    if let error = error { print(error) }
                    else {
                        print("Kakao account logout() success.")
                        TokenManager.manager.deleteToken()
                        withAnimation {
                            self.loginType = nil
                            self.userInfo = nil
                        }
                    }
                }
            case "naver" :
                NaverThirdPartyLoginConnection.getSharedInstance().resetToken()
                print("Naver account logout() success.")
                withAnimation {
                    self.loginType = nil
                    self.userInfo = nil
                }
            default : print("Unknown login type")
        }
    }
    
    func unlink() {
        switch loginType {
            case "kakao" :
                UserApi.shared.unlink { (error) in
                    if let error = error { print(error) }
                    else {
                        print("Kakao account unlink() success.")
                        TokenManager.manager.deleteToken()
                        withAnimation {
                            self.loginType = nil
                            self.userInfo = nil
                        }
                    }
                }
            case "naver" :
                NaverThirdPartyLoginConnection.getSharedInstance().requestDeleteToken()
                print("Naver account unlink() success.")
                withAnimation {
                    self.loginType = nil
                    self.userInfo = nil
                }
            default : print("Unknown login type")
        }
    }
}


// Naver Login Delegate - call back
extension UserService : UIApplicationDelegate, NaverThirdPartyLoginConnectionDelegate {
    // 로그인에 성공했을 경우 호출
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("[Success] : Success Naver Login")
        
        //print("App Name : " + NaverThirdPartyLoginConnection.getSharedInstance().appName)
        //print("Access Token : " + NaverThirdPartyLoginConnection.getSharedInstance().accessToken)
        //print("Token Type : " + NaverThirdPartyLoginConnection.getSharedInstance().tokenType)
        
        loginType = "naver"
        OAuthLogin(type: "naver", accessToken: NaverThirdPartyLoginConnection.getSharedInstance().accessToken)
    }
    
    // 접근 토큰 갱신
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print("[Success] : Success Naver AccessToken Refresh")
    }
    
    // 연동해제 할 경우 호출(토큰 삭제)
    func oauth20ConnectionDidFinishDeleteToken() {
        print("[Success] : Success Naver Logout")
    }
    
    // 모든 Error
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("[Error] :", error.localizedDescription)
    }
}
