//
//  NanuriApp.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/01/28.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import NaverThirdPartyLogin

@main
struct NanuriApp: App {
    init() {
        // Kakao SDK
        KakaoSDK.initSDK(appKey: "5999200bd2791859bfa2ab7f781dcf89")
        
        // Naver SDK
        NaverThirdPartyLoginConnection.getSharedInstance()?.isNaverAppOauthEnable = true // 네이버 앱으로 로그인 허용
        NaverThirdPartyLoginConnection.getSharedInstance()?.isInAppOauthEnable = true // 브라우저 로그인 허용
 
        // 네이버 로그인 세로모드 고정
        NaverThirdPartyLoginConnection.getSharedInstance().setOnlyPortraitSupportInIphone(true)
        
        // 우측 상수들 전부 NaverThirdPartyConstantsForApp.h에 선언되어있음
        NaverThirdPartyLoginConnection.getSharedInstance().serviceUrlScheme = kServiceAppUrlScheme
        NaverThirdPartyLoginConnection.getSharedInstance().consumerKey = kConsumerKey
        NaverThirdPartyLoginConnection.getSharedInstance().consumerSecret = kConsumerSecret
        NaverThirdPartyLoginConnection.getSharedInstance().appName = kServiceAppName
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
