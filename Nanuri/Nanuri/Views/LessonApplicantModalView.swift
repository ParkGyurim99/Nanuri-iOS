//
//  LessonApplicantModalView.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/02/16.
//

import SwiftUI
import Kingfisher

struct LessonApplicantModalView: View {
    @StateObject private var viewModel = LessonApplicantModalViewModel()
    @Binding var isPresented : Bool
    
    let lessonId : Int
    
    init(isPresented : Binding<Bool>, lessonId : Int) {
        _isPresented = isPresented
        self.lessonId = lessonId
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing : 0) {
                if viewModel.isFetching {
                    ProgressView()
                } else if viewModel.applicants.isEmpty {
                    Text("클래스 신청자가 없습니다.")
                } else {
                    ScrollView {
                        ForEach(viewModel.applicants, id : \.self) { applicant in
                            VStack {
                                HStack {
                                    KFImage(URL(string : applicant.user.imageUrl)!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width : UIScreen.main.bounds.width * 0.15, height : UIScreen.main.bounds.width * 0.15)
                                        .clipShape(Circle())

                                    VStack(alignment : .leading, spacing : 5) {
                                        Text(applicant.user.name)
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .lineLimit(1)
                                        Text(applicant.user.email)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                }
                                HStack {
                                    Button {
                                        if let index = viewModel.applicants.firstIndex(of: applicant) {
                                            viewModel.applicants.remove(at: index)
                                        }
                                        viewModel.acceptUser(lessonId: applicant.lessonId, userId: applicant.user.userId)
                                    } label : {
                                        Text("✓ 수락")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .padding(5)
                                            .frame(width: UIScreen.main.bounds.width * 0.45)
                                            .background(Color.green)
                                            .cornerRadius(10)
                                    }

                                    Button {
                                        viewModel.rejectUser(lessonId: applicant.lessonId, userId: applicant.user.userId)
                                    } label : {
                                        Text("Ｘ 거절")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .padding(5)
                                            .frame(width: UIScreen.main.bounds.width * 0.45)
                                            .background(Color.red)
                                            .cornerRadius(10)
                                    }
                                }
                            }.padding(5)
                            .padding(.horizontal, 10)
                            
                            Divider()
                        }
                    }.buttonStyle(BorderlessButtonStyle())
                }
            }.onAppear { viewModel.getApplicant(lessonId) }
            .navigationBarTitle(Text("신청자 관리"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("닫기") { isPresented.toggle() })
        }
    }
}
