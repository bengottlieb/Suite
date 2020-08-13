//
//  SwiftUIView.swift
//  
//
//  Created by ben on 8/13/20.
//

import SwiftUI

@available(OSX 10.15, iOS 13.0, *)
extension Alertive {
	public static func container() -> Container { Container() }
	
	public struct Container: View {
		//@Environment(\.alertive) var alertive
		@ObservedObject var alertive = Alertive.manager

		var alerts: some View {
			let count = alertive.pendingAlerts.count - 1
			return ForEach(alertive.pendingAlerts.indices, id: \.self) { index in
				Alertive.AlertView(alert: alertive.pendingAlerts[count - index])
					.offset(x: -CGFloat(count - index) * 10, y: -CGFloat(count - index) * 10)
			}
		}
		
		public var body: some View {
			Group() {
				if alertive.pendingAlerts.isEmpty {
					EmptyView()
				} else {
					ZStack() {
						Rectangle()
							.fill(Color.black.opacity(0.5))
							.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
							.transition(.opacity)
						
						alerts
					}
					.edgesIgnoringSafeArea(.all)
				}
			}
		}
	}
}
