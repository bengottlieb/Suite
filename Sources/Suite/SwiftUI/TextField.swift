//
//  SwiftUIView.swift
//  
//
//  Created by Ben Gottlieb on 3/7/23.
//

import SwiftUI

#if os(iOS)
	public typealias TextContentType = UITextContentType
#elseif os(macOS)
	public typealias TextContentType = NSTextContentType

	extension NSTextContentType {
		public static let name = NSTextContentType(rawValue: "name")
		public static let givenName = NSTextContentType(rawValue: "givenName")
		public static let middleName = NSTextContentType(rawValue: "middleName")
		public static let familyName = NSTextContentType(rawValue: "familyName")
		public static let nickname = NSTextContentType(rawValue: "nickname")
		public static let organizationName = NSTextContentType(rawValue: "organizationName")
		public static let streetAddressLine1 = NSTextContentType(rawValue: "streetAddressLine1")
		public static let fullStreetAddress = NSTextContentType(rawValue: "fullStreetAddress")
		public static let newPassword = NSTextContentType(rawValue: "newPassword")
		public static let emailAddress = NSTextContentType(rawValue: "emailAddress")
		public static let flightNumber = NSTextContentType(rawValue: "flightNumber")
		public static let shipmentTrackingNumber = NSTextContentType(rawValue: "shipmentTrackingNumber")
		public static let URL = NSTextContentType(rawValue: "URL")
	}
#endif

#if os(iOS) || os(macOS)
@available(macOS 11.0, *)
public extension View {
	func addTextContentType(_ type: TextContentType) -> some View {
		#if os(macOS)
			self
				.textContentType(type)
				.autocorrectionDisabled(!type.shouldAutocorrect)
		#else
			self
				.textContentType(type)
				.autocorrectionDisabled(!type.shouldAutocorrect)
				.autocapitalization(type.shouldAutocapitalize ? .words : .none )
				.keyboardType(type.requiresURLKeyboard ? .URL : .default)
		#endif
	}
}

@available(macOS 11.0, *)
private extension TextContentType {
	var requiresURLKeyboard: Bool {
		self == .emailAddress || self == .URL
	}

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
#endif
