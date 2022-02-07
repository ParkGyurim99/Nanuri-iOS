//
//  MyPageViewModel.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/01/31.
//

import Foundation
import Alamofire
import Combine
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import NaverThirdPartyLogin

class MyPageViewModel : NSObject, ObservableObject {
    static var tokenInfo : Token = Token(tokenType: "",
                                         accessToken: "",
                                         accessTokenValidityInMilliseconds: 0,
                                         refreshToken: "",
                                         refreshTokenValidityInMilliseconds: 0)
    
    @Published var authorizationCodeKakao : String = ""
    @Published var authorizationCodeNaver : String = ""
    
    // Kakao
    @Published var profileImage : URL?
    @Published var userMail : String = ""
    @Published var userName : String = ""
    
    // Naver
    @Published var isNaverLogined : Bool = false
    
    @Published var profileImageNaver : URL?
    @Published var userMailNaver : String = ""
    @Published var userNameNaver : String = ""
    
    private var subscription = Set<AnyCancellable>()
    private let baseURL = "http://ec2-3-39-19-215.ap-northeast-2.compute.amazonaws.com:8080"
    
    func OAuthLogin(type : String) {
        let url = baseURL + "/login/oauth/" + type
        var code : String {
            switch type {
                case "naver" : return authorizationCodeNaver
                case "kakao" : return authorizationCodeKakao
                default :
                    print("Wrong provider")
                    return ""
            }
        }
        print(type + " " + code)
        AF.request(url,
                   parameters: ["code" : code]
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
        } receiveValue: { recievedValue in
            print("OAuth Login received data")
            MyPageViewModel.tokenInfo = recievedValue.token
            print("received Token :")
            print(MyPageViewModel.tokenInfo)
            //print(recievedValue)
        }.store(in: &subscription)
    }
    
    func refrshToken() {
        let url = baseURL + "/token"
        let headerAuthInfo = MyPageViewModel.tokenInfo.tokenType
                            + " "
                            + MyPageViewModel.tokenInfo.accessToken

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
            print("Token Refresh")
            MyPageViewModel.tokenInfo = recievedValue
            print("refreshed Token :")
            print(MyPageViewModel.tokenInfo)
            print(recievedValue)
        }.store(in: &subscription)
    }
    
    // MARK: Temp
    private func getNaverInfo() {
        guard let tokenType = NaverThirdPartyLoginConnection.getSharedInstance().tokenType else { return }
        guard let accessToken = NaverThirdPartyLoginConnection.getSharedInstance().accessToken else { return }
        let url = "https://openapi.naver.com/v1/nid/me"
        //let url = URL(string: urlStr)!
        
        AF.request(url,
                   method: .get,
                   encoding: JSONEncoding.default,
                   headers: ["Authorization": "\(tokenType) \(accessToken)"]
        ).responseJSON { [weak self] response in
            guard let result = response.value as? [String: Any] else { return }
            guard let object = result["response"] as? [String: Any] else { return }
            guard let name = object["name"] as? String else { return }
            guard let email = object["email"] as? String else { return }
            guard let profileimage = object["profile_image"] as? String else { return }

            self?.profileImageNaver = URL(string: profileimage)
            self?.userMailNaver = email
            self?.userNameNaver = name
        }
    }
    
    
    func getUserInfo() {
        UserApi.shared.me { [weak self] User, Error in
            if let name = User?.kakaoAccount?.profile?.nickname {
                self?.userName = name
            }
            if let mail = User?.kakaoAccount?.email {
                self?.userMail = mail
            }
            if let profile = User?.kakaoAccount?.profile?.profileImageUrl {
                self?.profileImage = profile
            }
        }
    }
    
    func accountSignOut() {
        UserApi.shared.logout { (error) in
            if let error = error {
                print(error)
            }
            else {
                print("logout() success.")
            }
        }
    }
    
    func accountKakaoUnlink() {
        UserApi.shared.unlink { (error) in
            if let error = error {
                print(error)
            }
            else {
                print("unlink() success.")
            }
        }
    }
}

// Naver Login Delegate - call back
extension MyPageViewModel : UIApplicationDelegate, NaverThirdPartyLoginConnectionDelegate {
    // 로그인에 성공했을 경우 호출
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        isNaverLogined = true
        getNaverInfo()
        print("[Success] : Success Naver Login")
        //getNaverInfo()
        print("App Name : " + NaverThirdPartyLoginConnection.getSharedInstance().appName)
        print("Access Token : " + NaverThirdPartyLoginConnection.getSharedInstance().accessToken)
        print("Token Type : " + NaverThirdPartyLoginConnection.getSharedInstance().tokenType)
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
