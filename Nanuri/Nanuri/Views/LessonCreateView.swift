//
//  LessonCreateView.swift
//  Nanuri
//
//  Created by Park Gyurim on 2022/01/30.
//

import SwiftUI
import PhotosUI

struct LessonCreateView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = LessonCreateViewModel()
    
    var ImageArea : some View {
        VStack {
            Divider()
            HStack {
                Button {
                    viewModel.showImagePicker = true
                } label : {
                    VStack {
                        Image(systemName : "camera")
                                .font(.system(size : 22))
                        Text("\(viewModel.selectedImages.count)/4")
                    }.foregroundColor(.gray)
                    .frame(width : 65, height : 65)
                    .background(Color.systemDefaultGray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }.disabled(viewModel.selectedImages.count == 4)
                
                ForEach(viewModel.selectedImages.indices, id : \.self) { index in
                    Image(uiImage: viewModel.selectedImages[index])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width : 65, height : 65)
                        .cornerRadius(10)
                        .overlay(
                            Button {
                                withAnimation { _ = viewModel.selectedImages.remove(at: index) }
                            } label : {
                                Image(systemName: "xmark")
                                    .font(.system(size: 11))
                                    .padding(4)
                                    .background(Color.black)
                                    .clipShape(Circle())
                                    .foregroundColor(.white)
                                    .offset(x: 27, y: -27)
                            }
                        )
                }
            }.padding()
            .frame(maxWidth : .infinity, alignment : .leading)
            Divider().padding(.horizontal)
        }
    }
    
    var InputField : some View {
        VStack {
            TextField("????????? ??????", text : $viewModel.titleText)
                .padding()
                .frame(width: UIScreen.main.bounds.width * 0.95, height: 50)
            Divider().padding(.horizontal)
            HStack {
                TextField("????????????", text : $viewModel.categoryText)
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.6, height: 50)
                Spacer()
                TextField("????????????", text : $viewModel.participantLimit)
                    .keyboardType(.decimalPad)
                    .padding()
                    .frame(width: UIScreen.main.bounds.width * 0.3, height: 50)
            }.frame(maxWidth: UIScreen.main.bounds.width * 0.95)
            Divider().padding(.horizontal)
            NavigationLink {
                VStack {
                    Text("?????? ?????? : " + viewModel.locationText)
                        .fontWeight(.semibold)
                        //.frame(maxWidth : .infinity, alignment: .leading)
                        .padding()
                    
                    List {
                        ForEach(districtList, id : \.self) { district in
                            HStack {
                                Text(district)
                                    .fontWeight(.semibold)
                                Spacer()
                                if district == viewModel.locationText {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.mainTheme)
                                }
                            }.padding(.horizontal)
                            .onTapGesture { viewModel.locationText = district }
                        }
                    }.listStyle(.plain)
                }.navigationTitle(Text("????????? ?????? ?????? (???-???)"))
                .navigationBarTitleDisplayMode(.inline)
            } label : {
                HStack {
                    Text("????????? ?????? : " + viewModel.locationText)
                    Spacer()
                    Image(systemName: "chevron.right")
                }.foregroundColor(.black)
                .padding()
                .frame(width: UIScreen.main.bounds.width * 0.95, height: 50, alignment: .leading)
            }
            Divider().padding(.horizontal)
            Text("??????")
                .foregroundColor(.gray)
                .frame(maxWidth: UIScreen.main.bounds.width * 0.9, alignment: .leading)
                .font(.caption)
            TextEditor(text : $viewModel.contentText)
                .frame(width: UIScreen.main.bounds.width * 0.9, height : UIScreen.main.bounds.height * 0.3)
                .padding(.horizontal)
        }
    }
    
    var BottomToolbar : some View {
        VStack {
            Divider()
            HStack {
                Spacer()
                Button {
                    hideKeyboard()
                } label : {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .font(.system(size : 20))
                        .foregroundColor(.gray)
                }.padding(.vertical, 5)
                .padding(.horizontal)
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    ImageArea
                    InputField
                }
                BottomToolbar
            }.blur(radius: viewModel.isUploadProcessing ? 2.0 : 0)
            
            if viewModel.isUploadProcessing {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.vertical)
                    .frame(maxWidth : .infinity, maxHeight: .infinity)
                    .overlay(
                        VStack {
                            ProgressView()
                            Text("????????? ?????????..")
                                .foregroundColor(.darkGray)
                                .padding()
                        }
                    )
            }
        }.navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text("????????? ??????"))
        .navigationBarBackButtonHidden(viewModel.isUploadProcessing ? true : false)
        .navigationBarItems(
            trailing:
                Button {
                    // ?????? API ?????? .. button disable ?????? ????????? ?????? ?????????.
                    withAnimation {
                        viewModel.isUploadProcessing = true
                        viewModel.upload()
                    }
                } label : {
                    Text("??????")
                        .foregroundColor(.mainTheme)
                        .opacity(viewModel.payloadFillCheck || viewModel.isUploadProcessing ? 0.3 : 1)
                }.disabled(viewModel.payloadFillCheck || viewModel.isUploadProcessing)
        )
        .sheet(isPresented: $viewModel.showImagePicker) {
            PhotoPicker(
                configuration: viewModel.configuration,
                isPresented: $viewModel.showImagePicker,
                pickerResult: $viewModel.selectedImages)
                .edgesIgnoringSafeArea(.bottom)
        }.onChange(of: viewModel.isUploadDone) { _ in
            presentationMode.wrappedValue.dismiss()
        }.alert(isPresented: $viewModel.isUploadFail) {
            Alert(
                title: Text("??????"),
                message: Text("????????? ?????? ??????"),
                dismissButton: .default(Text("??????"))
            )
        }
    }
}

struct LessonCreateView_Previews: PreviewProvider {
    static var previews: some View {
        LessonCreateView()
    }
}
