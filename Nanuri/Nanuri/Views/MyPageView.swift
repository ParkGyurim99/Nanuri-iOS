//
//  MyPageView.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/01/28.
//

import SwiftUI
import URLImage
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import NaverThirdPartyLogin

struct MyPageView: View {
    @AppStorage("isSignIn") var isSignIn = false
    
    @StateObject private var viewModel = MyPageViewModel()
    
    var Title : some View {
        HStack {
            //Image(systemName: "person.circle")
            //    .font(.system(size : 30))
            Text("마이 페이지")
                .font(.largeTitle)
                .fontWeight(.bold)
                //.frame(maxWidth : .infinity, alignment: .leading)
            Spacer()
            Image(systemName: "gearshape.fill")
                .font(.system(size: 25))
        }
    }
    var Profile : some View {
        VStack {
            Divider()
            if !isSignIn {
                //MARK: Kakao Auth API TEMP
                Button {
                    //카카오톡이 깔려있는지 확인하는 함수
                    if (UserApi.isKakaoTalkLoginAvailable()) {
                        //카카오톡이 설치되어있다면 카카오톡을 통한 로그인 진행
                        UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                            //print(oauthToken)
                            //print(error)
                            viewModel.getUserInfo()
                            //isSignIn = true
                        }
                    } else {
                        //카카오톡이 설치되어있지 않다면 사파리에서 카카오 계정을 통한 로그인 진행
                        UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                            //print(oauthToken)
                            //print(error)
                            viewModel.getUserInfo()
                            //isSignIn = true
                        }
                    }
                } label : {
                    Image("kakao_login_large")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        
                }.frame(width: UIScreen.main.bounds.width * 0.6, height : UIScreen.main.bounds.height * 0.05)
                .padding(.vertical, 10)
                
                Button {
                    if NaverThirdPartyLoginConnection
                        .getSharedInstance()
                        .isPossibleToOpenNaverApp() // Naver App이 깔려있는지 확인하는 함수
                    {
                        NaverThirdPartyLoginConnection.getSharedInstance().delegate = viewModel.self
                        NaverThirdPartyLoginConnection
                            .getSharedInstance()
                            .requestThirdPartyLogin()
                    } else { // 브라우저로 로그인
                        // Appstore에서 네이버앱 링크 열기
                        //NaverThirdPartyLoginConnection.getSharedInstance().openAppStoreForNaverApp()
                        
                        NaverThirdPartyLoginConnection.getSharedInstance().delegate = viewModel.self
                        NaverThirdPartyLoginConnection
                            .getSharedInstance()
                            .requestThirdPartyLogin()
                    }
                } label : {
                    Image("naver_login_large")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }.frame(width: UIScreen.main.bounds.width * 0.6, height : UIScreen.main.bounds.height * 0.05)
                .padding(.vertical, 10)
            } else {
                HStack {
                    if let profileImage = viewModel.profileImage {
                        URLImage(profileImage) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .clipShape(Circle())
                        }
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 25))
                            .padding()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.white)
                            .background(Color.darkGray)
                            .clipShape(Circle())
                            .onTapGesture {
                                isSignIn = false
                            }
                    }

                    VStack(alignment : .leading, spacing : 10) {
                        Text(viewModel.userName)
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Text(viewModel.userMail)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.gray)
                    }.padding(.leading, 10)
                    Spacer()
                }.padding(.vertical, 10)
            }
            Divider()
        }.padding(.bottom, 20)
    }
    
    var body: some View {
        VStack {
            Title
            Profile
//            Text("My Classes (#)")
//                .font(.system(.title3, design: .rounded))
//                .fontWeight(.semibold)
//                .frame(maxWidth : .infinity, alignment: .leading)
//            ScrollView(.horizontal) {
//                HStack {
//                    ForEach(0..<3, id : \.self) { _ in
//                        Color.gray
//                            .opacity(0.5)
//                            .frame(width: 120, height: 120)
//                            .cornerRadius(20)
//                    }
//                }
//            }
            
            Spacer()
            Text("Kakao login auth code : \n" + viewModel.authorizationCodeKakao)
                .fontWeight(.semibold)
                .frame(maxWidth : UIScreen.main.bounds.width * 0.9, alignment : .leading)
                .padding()
                .background(Color.yellow.opacity(0.7))
                .cornerRadius(20)
                
            Text("Naver login auth code : \n" + viewModel.authorizationCodeNaver)
                .fontWeight(.semibold)
                .frame(maxWidth : UIScreen.main.bounds.width * 0.9, alignment : .leading)
                .padding()
                .background(Color.green.opacity(0.7))
                .cornerRadius(20)
                
            Divider()
            Button {
                viewModel.accountSignOut()
            } label : {
                Text("카카오 로그아웃")
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .padding()
            }
            Button {
                NaverThirdPartyLoginConnection.getSharedInstance().requestDeleteToken() // 연동 해제
            } label : {
                Text("네이버 로그아웃")
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        } // VStack
        .onAppear{ viewModel.getUserInfo() }
        .padding()
        .navigationBarHidden(true)
        .onOpenURL { url in // code를 파라미터로해서 서버에 jwt 발급 요청
            print(url)
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                // 카카오 로그인 리다이렉트일 경우
                // ex) kakaoc95be0b24be89d4167b238b296e8396d://oauth?
                //      code=c5ih7yqbTO3g0jBfVHcbPpNkurHZHUEcotDsqchDIx1avCIgwSGlDYltCCalX6n4CGv1sQo9cpcAAAF-yUFuzA

                // url : redirect uri 랑 authorization code
                
                viewModel.authorizationCodeKakao = url.oauthResult().code ?? ""
                
                // -- Access Token 발급 요청
                //_ = AuthController.handleOpenUrl(url: url)
            } else if NaverThirdPartyLoginConnection
                        .getSharedInstance()
                        .isNaverThirdPartyLoginAppschemeURL(url) {
                // 네이버 로그인 리다이렉트일 경우
                // ex) nanuri://thirdPartyLoginResult?version=2&code=0&authCode=lDDBH4j7LV1iMWGUWH
                if UIApplication.shared.canOpenURL(url) {
                    print("can open Url")
                } else {
                    print("can't open Url")
                }
                print("naver authorization code")
                print(url.absoluteString)
                if let authCode = url.absoluteString.components(separatedBy: "&").last?.components(separatedBy: "=").last {
                    viewModel.authorizationCodeNaver = authCode
                }
                
                // -- Access Token 발급 요청
                //NaverThirdPartyLoginConnection
                //    .getSharedInstance()
                //    .receiveAccessToken(url)
            }
        }
    }
}

struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView()
    }
}
