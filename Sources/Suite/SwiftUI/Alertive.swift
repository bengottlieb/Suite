//
//  AlertiveView.swift
//  
//
//  Created by ben on 8/13/20.
//

#if canImport(Combine)
import SwiftUI
import Combine

@available(OSX 10.15, iOS 13.0, *)
public struct Alertive {
	
}

@available(OSX 10.15, iOS 13.0, *)
extension Alertive {
	struct AlertView: View {
		let alert: Manager.PendingAlert
		
		let radius: CGFloat = 8
		
		public var body: some View {
			ZStack() {
				RoundedRectangle(cornerRadius: radius)
					.fill(Color.black.opacity(0.9))
				
				RoundedRectangle(cornerRadius: radius)
					.stroke(Color.white.opacity(0.9))
				
				VStack() {
					if alert.title?.isEmpty == false {
						Text(alert.title ?? "")
							.font(.headline)
							.multilineTextAlignment(.center)
							.foregroundColor(.white)
							.padding(3)
					}

					if alert.body?.isEmpty == false {
						Text(alert.body ?? "")
							.font(.body)
							.multilineTextAlignment(.center)
							.foregroundColor(.white)
							.padding(3)
					}
					
					ForEach(alert.buttons) { button in
						SwiftUI.Button(action: {
							button.pressed()
							self.alert.buttonPressed()
						}) {
							ZStack() {
								RoundedRectangle(cornerRadius: self.radius)
									.fill(Color.black.opacity(0.9))
								
								RoundedRectangle(cornerRadius: self.radius)
									.stroke(Color.white.opacity(0.9))
								
								Text(button.label)
									.font(.callout)
									.multilineTextAlignment(.center)
									.foregroundColor(.white)
									.padding(.vertical, 3)
									.frame(minWidth: 220)
									.layoutPriority(1)
							}
						}
					}
				}
				.padding(10)
				.layoutPriority(1)
			}
			.transition(AnyTransition.scale)
		}
	}
}


@available(OSX 10.15, iOS 13.0, *)
struct Alertive_Previews: PreviewProvider {
	static var previews: some View {
		Alertive.container()
	}
}
#endif
