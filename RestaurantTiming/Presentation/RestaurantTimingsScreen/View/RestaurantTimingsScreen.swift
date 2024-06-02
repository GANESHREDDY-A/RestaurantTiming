//
//  RestaurantTimingsScreen.swift
//  RestaurantTiming
//
//  Created by Ganesh reddy on 6/1/24.
//

import SwiftUI

struct RestaurantTimingsScreen: View {
    @State var showAllTimings: Bool = false
    @ObservedObject var viewmodel = RestaurantTimingsViewModel()
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            Image("restaurant")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)
            if viewmodel.resultState == .loading {
                ZStack {
                    Color(.black)
                        .opacity(0.4)
                    LoaderView(tintColor: .yellow, scaleSize: 2)
                }
            } else {
                VStack(alignment: .leading) {
                    Text(viewmodel.locationdata.locationName)
                        .font(AppFonts.firaSansBlack54)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.leading, AppConstants.Spacings._2x)
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 1) {
                                HStack() {
                                    Text(viewmodel.displayText)
                                        .foregroundColor(.gray)
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .renderingMode(.template)
                                        .frame(width: AppConstants.Spacings._1x, height: AppConstants.Spacings._1x)
                                        .foregroundColor(viewmodel.restaurantStatusColor)
                                }
                                Text(AppConstants.StringConstants.seeFullHour)
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            Spacer()
                            Image(systemName: showAllTimings ? "chevron.up" : "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: AppConstants.Spacings._2x, height:  AppConstants.Spacings._2x)
                        } .onTapGesture {
                            showAllTimings.toggle()
                        }
                        if showAllTimings && !viewmodel.allTimings.isEmpty {
                            ForEach(viewmodel.allTimings) { data in
                                VStack() {
                                    HStack(alignment: .top) {
                                        Text(EnumDays(rawValue: data.weekDay)?.description ?? "")
                                        Spacer()
                                        Text(data.time.joined(separator: ",\n"))
                                    }
                                }.padding(.top, AppConstants.Spacings._2x)
                            }
                        }
                    } .frame(maxWidth: UIScreen.main.bounds.width)
                        .padding(.leading, AppConstants.Spacings._2x)
                        .padding(.vertical, AppConstants.Spacings._2x)
                        .padding(.trailing, AppConstants.Spacings._1x)
                        .background(.white)
                        .cornerRadius(AppConstants.Spacings._1x)
                        .padding(.all, AppConstants.Spacings._2x)
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 0) {
                            Text("^").foregroundStyle(.white.opacity(0.5))
                            Text("^").foregroundStyle(.white)
                            Text("View Menu").foregroundStyle(.white)
                        }.onTapGesture {
                            print("view menu clicked")
                        }
                        Spacer()
                    }
                }
            }
        }.onAppear {
            viewmodel.fetchRestaurantData()
        }
    }
}
