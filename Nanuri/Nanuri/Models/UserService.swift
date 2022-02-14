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
    
    func refrshToken(completion : @escaping (Result<Bool, Error>) -> ()) { // 나중에 Result<Int, Error> 로 상태 코드에 따라 나눠도 될 듯
        let url = baseURL + "/token"

        //print("Try token refresh")
        AF.request(url,
                   method: .get,
                   interceptor: authorizationInterceptor()
        ).responseJSON { response in
            guard let statusCode = response.response?.statusCode else { return }
            switch statusCode {
                case 200 :
                    print("Refresh token success (\(statusCode))")
                    completion(.success(true))
                default :
                    completion(.success(false))
            }
            print(response)
        }
        .publishDecodable(type : Token.self)
        .compactMap { $0.value }
        .sink { completion in
            switch completion {
                case let .failure(error) :
                    print("Token Refresh Error : " + error.localizedDescription)
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

// JWT Authorization interceptor
class authorizationInterceptor : RequestInterceptor {
    // Adapter for attaching JWT access token
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var urlRequest = urlRequest
        guard let userInfo = UserService.shared.userInfo else { return }
        
        //print("-- Attaching authentication header")
        urlRequest.headers.add(
            name: "X-AUTH-TOKEN",
            value: userInfo.token.tokenType + " " + userInfo.token.accessToken
        )
        
        completion(.success(urlRequest))
    }
    
    // Retrier for authentication error (invalid access token)
    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void
    ) {
        guard let statusCode = request.response?.statusCode else { return }
        print("status code catched by retrier : \(statusCode)")
        
        //MARK: Authentication Error - Expired AccessToken
        if statusCode == 403 {
            //print("-- Refresh token and Retry request")
            UserService.shared.refrshToken { result in
                switch result {
                    case .success(true) :
                        //completion(.retry) // 토큰이 갱신 됐지만 저장 되기전에 실행될 수 도 있어서!
                        completion(.retryWithDelay(TimeInterval(1.0)))
                    case .success(false) :
                        print("Token refresh error - Expired refresh token error")
                        UserService.shared.userInfo = nil
                        UserService.shared.loginType = nil
                    case let .failure(error) :
                        print("Retry error : " + error.localizedDescription)
                }
            }
        } else { completion(.doNotRetry) }
    }
}
