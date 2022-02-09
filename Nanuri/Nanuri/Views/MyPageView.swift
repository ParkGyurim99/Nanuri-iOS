//
//  MyPageView.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/01/28.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import NaverThirdPartyLogin
import Kingfisher

struct MyPageView: View {
    @AppStorage("loginType") var loginType : String = ""
    
    @StateObject private var viewModel = MyPageViewModel()
    
    var Title : some View {
        HStack {
            Text("마이 페이지")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top)
            Spacer()
            Image(systemName: "gearshape.fill")
                .font(.system(size: 25))
        }.padding()
    }
    var LoginOption : some View {
        VStack {
            Divider()
            
            // 토큰 정보 있을때 (JWT 정보가 있을때)
            if let userInfo = viewModel.userInfo, let _ = MyPageViewModel.tokenInfo {
                HStack(spacing : 10) {
                    KFImage(URL(string : userInfo.imageUrl)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width : UIScreen.main.bounds.width * 0.15, height : UIScreen.main.bounds.width * 0.15)
                        .clipShape(Circle())
                    VStack(alignment : .leading, spacing : 5) {
                        Text(userInfo.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(userInfo.email)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image("loginWith_" + loginType)
                        .resizable()
                        .aspectRatio(contentMode : .fit)
                        .frame(width : 50)
                }.padding(.horizontal)
            } else {
                Text("로그인 후 이용할 수 있습니다 😆")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.darkGray)
                    .padding()
                
                // Kakao Login
                Button {
                    //카카오톡이 깔려있는지 확인하는 함수
                    if (UserApi.isKakaoTalkLoginAvailable()) {
                        //카카오톡이 설치되어있다면 카카오톡을 통한 로그인 진행
                        UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                            if let error = error { print(error) }
                            else {
                                print("loginWithKakaoTalk() success.")

                                if let accessToken = oauthToken?.accessToken {
                                    loginType = "kakao"
                                    print("kakao access token : " + accessToken)
                                    viewModel.OAuthLogin(type: loginType, accessToken: accessToken)
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
                } label : {
                    Image("kakao_login")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(20)
                }.frame(maxWidth : .infinity)
                
                // Naver Login
                Button {
                    if NaverThirdPartyLoginConnection
                        .getSharedInstance()
                        .isPossibleToOpenNaverApp() // Naver App이 깔려있는지 확인하는 함수
                    {
                        NaverThirdPartyLoginConnection.getSharedInstance().delegate = viewModel.self
                        NaverThirdPartyLoginConnection
                            .getSharedInstance()
                            .requestThirdPartyLogin()
                    } else { // 네이버 앱 안깔려져 있을때
                        // Appstore에서 네이버앱 열기
                        //NaverThirdPartyLoginConnection.getSharedInstance().openAppStoreForNaverApp()
                        
                        // 브라우저로 네이버 로그인 열기
                        UIApplication.shared.open(
                            URL(string: "https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=" + kConsumerKey + "&redirect_uri=nanuri://naverAuth")!,
                            options: [:]
                        )
                    }
                } label : {
                    Image("naver_login")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(20)
                }.frame(maxWidth : .infinity)
            }
            Divider()
        }.padding(.horizontal)
        .overlay(
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                .frame(maxWidth : .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
                .opacity(viewModel.showLoginProgress ? 1 : 0)
        )
    }
    var MyClasses : some View {
        VStack {
            Text("My Classes (#)")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
                .frame(maxWidth : .infinity, alignment: .leading)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0..<3, id : \.self) { _ in
                        Color.gray
                            .opacity(0.5)
                            .frame(width: 120, height: 120)
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            Title
            LoginOption
            Spacer()
            
            if viewModel.userInfo != nil {
                Divider()
                Button {
                    if loginType == "naver" { NaverThirdPartyLoginConnection.getSharedInstance().resetToken() }
                    else { viewModel.kakaoAccountSignOut() }
                    withAnimation {
                        viewModel.userInfo = nil
                        MyPageViewModel.tokenInfo = nil
                    }
                    loginType = ""
                } label : {
                    Text(loginType.uppercased() + " 로그아웃")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                Divider()
                
                Button {
                    if loginType == "naver" { NaverThirdPartyLoginConnection.getSharedInstance().requestDeleteToken() }
                    else { viewModel.kakaoAccountUnlink() }
                    
                    withAnimation {
                        viewModel.userInfo = nil
                        MyPageViewModel.tokenInfo = nil
                    }
                    loginType = ""
                } label : {
                    Text(loginType.uppercased() + " 연결끊기")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                Divider()
            }

            Button { NaverThirdPartyLoginConnection.getSharedInstance().requestDeleteToken() } label : {
                Text("naver unlink - temp button")
            }.padding()
            
            Button { viewModel.refrshToken() } label : {
                Text("token Refresh")
            }.padding()
            Spacer()
        } // VStack
        .navigationBarHidden(true)
        .onOpenURL { url in
            withAnimation { viewModel.showLoginProgress = true }
            if (AuthApi.isKakaoTalkLoginUrl(url)) { _ = AuthController.handleOpenUrl(url: url) }
            else if NaverThirdPartyLoginConnection.getSharedInstance().isNaverThirdPartyLoginAppschemeURL(url) {
                NaverThirdPartyLoginConnection.getSharedInstance().receiveAccessToken(url)
            }
        }
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView()
    }
}
