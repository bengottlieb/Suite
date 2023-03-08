//
//  SwiftUIView.swift
//  
//
//  Created by Ben Gottlieb on 3/7/23.
//

import SwiftUI

public extension View {
	func addTextContentType(_ type: UITextContentType) -> some View {
		self
			.textContentType(type)
			.autocorrectionDisabled(!type.shouldAutocorrect)
			.autocapitalization(type.shouldAutocapitalize ? .words : .none )
	}
}

private extension UITextContentType {
	var shouldAutocorrect: Bool {
		switch self {
		case .name, .givenName, .middleName, .familyName, .nickname, .organizationName, .streetAddressLine1, .fullStreetAddress, .username, .password, .newPassword, .oneTimeCode, .emailAddress: return false
			
			
			
		default:
			if #available(iOS 15.0, *) {
				if self == .flightNumber || self == .shipmentTrackingNumber { return false }
			}
			return true
		}
	}
	
	var shouldAutocapitalize: Bool {
		switch self {
		case .username, .password, .newPassword, .oneTimeCode, .emailAddress: return false
			
			
			
		default:
			if #available(iOS 15.0, *) {
				if self == .flightNumber || self == .shipmentTrackingNumber { return false }
			}
			return true
		}
	}
}
