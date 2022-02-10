//
//  MyPageView.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/01/28.
//

import SwiftUI
import Kingfisher

// For distinguish redirected URL
import NaverThirdPartyLogin
import KakaoSDKAuth

struct MyPageView: View {
    @StateObject private var viewModel = MyPageViewModel()
    @StateObject private var instance = UserService.shared
    
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
            if let userInfo = instance.userInfo, let type = instance.loginType { // 토큰 정보 있을때 (JWT 정보가 있을때)
                HStack(spacing : 15) {
                    KFImage(URL(string : userInfo.imageUrl)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width : UIScreen.main.bounds.width * 0.15, height : UIScreen.main.bounds.width * 0.15)
                        .clipShape(Circle())
                    VStack(alignment : .leading, spacing : 5) {
                        Text(userInfo.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            
                        Text(userInfo.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    Spacer()
                    Image("loginWith_" + type)
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
                    instance.kakaoLogin()
                } label : {
                    Image("kakao_login")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(20)
                }.frame(maxWidth : .infinity)
                
                // Naver Login
                Button {
                    instance.naverLogin()
                } label : {
                    Image("naver_login")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(20)
                }.frame(maxWidth : .infinity)
            }
            Divider()
        }.padding(.horizontal)
            .blur(radius: viewModel.showLoginProgress ? 2.0 : 0)
        .overlay(
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                .frame(maxWidth : .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
                .opacity(viewModel.showLoginProgress ? 1 : 0)
        ).onChange(of: instance.userInfo) { newValue in
            if newValue != nil { viewModel.showLoginProgress = false }
        }
    }
    var MyClasses : some View {
        VStack {
            HStack {
                Text("내가 개설한 클래스(#)")
                    .fontWeight(.semibold)
                    .frame(maxWidth : .infinity, alignment: .leading)
                Spacer()
                Button {
                    
                } label : {
                    Text("더보기 ")
                        .foregroundColor(.gray)
                }
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0..<4, id : \.self) { _ in
                        Color.gray
                            .opacity(0.5)
                            .frame(width: 120, height: 120)
                            .cornerRadius(20)
                    }
                }
            }
            Divider()
            HStack {
                Text("내가 신청한 클래스(#)")
                    .fontWeight(.semibold)
                    .frame(maxWidth : .infinity, alignment: .leading)
                Spacer()
                Button {
                    
                } label : {
                    Text("더보기 ")
                        .foregroundColor(.gray)
                }
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(0..<4, id : \.self) { _ in
                        Color.gray
                            .opacity(0.5)
                            .frame(width: 120, height: 120)
                            .cornerRadius(20)
                    }
                }
            }
        }.padding()
    }
    
    var body: some View {
        VStack {
            Title
            LoginOption
            if instance.userInfo != nil { MyClasses }
            Spacer()
            if instance.userInfo != nil {
                Divider()
                Button {
                    instance.logout()
                } label : {
                    Text("로그아웃")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth : .infinity)
                }
                Divider()
                
                Button {
                    instance.unlink()
                    // 카카오계정 언링크 후에 다시 로그인 시도시 오류있음
                } label : {
                    Text("서비스 연동해제")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth : .infinity)
                }
                Divider()
            }

            Spacer()
        } // VStack
        .navigationBarHidden(true)
        .onOpenURL { url in
            
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                withAnimation { viewModel.showLoginProgress = true }
                _ = AuthController.handleOpenUrl(url: url)
            }
            else if NaverThirdPartyLoginConnection.getSharedInstance().isNaverThirdPartyLoginAppschemeURL(url) {
                withAnimation { viewModel.showLoginProgress = true }
                print("Received URL : ")
                print(url)
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
