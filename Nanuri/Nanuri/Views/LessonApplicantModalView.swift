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
    @State var editMode : EditMode = .inactive
    
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
                } else if viewModel.applicants.isEmpty {
                    Text("클래스 신청자가 없습니다.")
                } else {
                    List {
                        ForEach(viewModel.applicants.indices, id : \.self) { index in
                            VStack {
                                HStack {
                                    KFImage(URL(string : viewModel.applicantsInfo[viewModel.applicants[index].userId]?.imageUrl
                                               ?? "https://static.thenounproject.com/png/741653-200.png")!
                                    ).resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width : UIScreen.main.bounds.width * 0.15,
                                           height : UIScreen.main.bounds.width * 0.15)
                                    .clipShape(Circle())

                                    VStack(alignment : .leading, spacing : 5) {                                    Text(viewModel.applicantsInfo[viewModel.applicants[index].userId]?.name ?? "")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .lineLimit(1)
                                        Text(viewModel.applicantsInfo[viewModel.applicants[index].userId]?.email ?? "")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                    switch viewModel.applicants[index].status {
                                        case "ACCEPTED" :
                                            Text("수락됨")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.darkGray)
                                        case "DENIED" :
                                            Text("거절됨")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.darkGray)
                                        default :
                                            Text("대기중")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.darkGray)
                                    }
                                }
                                
                                switch viewModel.applicants[index].status {
                                    case "ACCEPTED" :
                                        Text("이미 수락된 신청서입니다.")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.gray)
                                    case "DENIED" :
                                        Text("이미 거절된 신청서입니다.")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.gray  )
                                    default :
                                        HStack {
                                            Button {
                                                viewModel.acceptUser(lessonId: lessonId, userId: viewModel.applicants[index].userId)
                                                viewModel.applicants[index].status = "ACCEPTED"
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
                                                viewModel.rejectUser(lessonId: lessonId, userId: viewModel.applicants[index].userId)
                                                viewModel.applicants[index].status = "DENIED"
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
                                }
                                
                            }
                        }.onDelete { indexOffset in
                            let index = indexOffset[indexOffset.startIndex]
                            let userId = viewModel.applicants[index].userId
                            viewModel.applicants.remove(at: index)
                            viewModel.applicantsInfo.removeValue(forKey: userId)
                            viewModel.removeUser(lessonId: lessonId, userId: userId)
                        }
                    }.buttonStyle(BorderlessButtonStyle())
                    .listStyle(PlainListStyle())
                    .environment(\.editMode, self.$editMode.animation())
                }
            }.onAppear { viewModel.getApplicant(lessonId) }
            .navigationBarTitle(Text("신청자 관리"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading : Button(editMode == .active ? "취소" : "삭제") {
                    if editMode == .active { withAnimation { editMode = .inactive } }
                    else { withAnimation { editMode = .active } }
                },
                trailing: Button("닫기") { isPresented.toggle() })
        }
    }
}
