//
//  LessonParticipantModalView.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/02/16.
//

import SwiftUI
import Kingfisher

struct LessonParticipantModalView: View {
    @StateObject private var viewModel = LessonParticipantModalViewModel()
    @Binding var isPresented : Bool
    
    let lessonId : Int
    
    init(isPresented : Binding<Bool>, lessonId : Int) {
        _isPresented = isPresented
        self.lessonId = lessonId
    }
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isFetching {
                    ProgressView()
                } else if viewModel.participants.isEmpty {
                    Text("클래스 참가자가 없습니다.")
                } else {
                    List {
                        ForEach(viewModel.participants.indices, id : \.self) { index in
                            HStack {
                                KFImage(URL(string : viewModel.participantsInfo[viewModel.participants[index].userId]?.imageUrl
                                           ?? "https://static.thenounproject.com/png/741653-200.png")!
                                ).resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width : UIScreen.main.bounds.width * 0.15,
                                       height : UIScreen.main.bounds.width * 0.15)
                                .clipShape(Circle())

                                VStack(alignment : .leading, spacing : 5) {
                                    Text(viewModel.participantsInfo[viewModel.participants[index].userId]?.name ?? "")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                    Text(viewModel.participantsInfo[viewModel.participants[index].userId]?.email ?? "")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                                Spacer()
                                Button {
                                    viewModel.deleteParticipant(lessonId, viewModel.participants[index].userId) { completion in
                                        switch completion {
                                            case .success(true) :
                                                isPresented = false
                                            default :
                                                viewModel.showErrorAlert = true
                                        }
                                    }
                                } label : {
                                    Text("참가취소")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .background(Color.red)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }.buttonStyle(BorderlessButtonStyle())
                    .listStyle(PlainListStyle())
                }
            }.onAppear {viewModel.getParticipant(lessonId)}
            .navigationBarTitle(Text("참가자 관리"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("닫기") { isPresented.toggle() })
            .alert(isPresented: $viewModel.showErrorAlert) {
                Alert(
                    title: Text("알림"),
                    message: Text("참가자 삭제 중 오류가 발생했습니다."),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
    }
}
