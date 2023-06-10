//
//  WidgetFamily.swift
//  Suite
//
//  Created by Ben Gottlieb on 6/10/23.
//

// https://developer.apple.com/design/human-interface-guidelines/widgets/overview/design/

import WidgetKit

@available(iOS 14.0, *)
public extension WidgetFamily {
	#if os(macOS)
		var size: CGSize {
			return CGSize(width: 170, height: 170)
		}
	#endif
	#if os(iOS)
		var size: CGSize {
			switch self {
			case .systemSmall:
				switch UIScreen.main.bounds.size.screenSize {
				case .iPhone14ProMax, .iPhone12ProMax: return CGSize(width: 170, height: 170)
				case .iPhone14Pro, .iPhone12: return CGSize(width: 158, height: 158)
				case .iPhone11ProMax: return CGSize(width: 169, height: 169)
				case .iPhoneX: return CGSize(width: 155, height: 155)
				case .iPhoneSixPlus: return CGSize(width: 159, height: 159)
				case .iPhoneSix: return CGSize(width: 148, height: 148)
				case .iPhone5: return CGSize(width: 141, height: 141)
				case .iPhone: return CGSize(width: 141, height: 141)
				
				case .iPadPro11: return CGSize(width: 170, height: 170)
				case .iPadPro10_5: return CGSize(width: 150, height: 150)
				case .iPadPro12_9: return CGSize(width: 170, height: 170)
				case .iPadAir_4thGen: return CGSize(width: 155, height: 155)
				case .iPad_7thGen: return CGSize(width: 146, height: 146)
				case .iPad: return CGSize(width: 141, height: 141)

				default: return CGSize(width: 169, height: 169)
				}
			
			case .systemMedium:
				switch UIScreen.main.bounds.size.screenSize {
				case .iPhone12ProMax: return CGSize(width: 364, height: 170)
				case .iPhone12: return CGSize(width: 338, height: 158)
				case .iPhone11ProMax: return CGSize(width: 360, height: 169)
				case .iPhoneX: return CGSize(width: 329, height: 155)
				case .iPhoneSixPlus: return CGSize(width: 348, height: 159)
				case .iPhoneSix: return CGSize(width: 321, height: 148)
				case .iPhone5: return CGSize(width: 292, height: 141)
				case .iPhone: return CGSize(width: 292, height: 141)

				case .iPadPro11: return CGSize(width: 378.5, height: 170)
				case .iPadPro10_5: return CGSize(width: 327.5, height: 150)
				case .iPadPro12_9: return CGSize(width: 378.5, height: 170)
				case .iPadAir_4thGen: return CGSize(width: 342, height: 155)
				case .iPad_7thGen: return CGSize(width: 320.5, height: 146)
				case .iPad: return CGSize(width: 305.5, height: 141)

				default: return CGSize(width: 360, height: 169)
				}


			case .systemExtraLarge:
				switch UIScreen.main.bounds.size.screenSize {
				case .iPadPro11: return CGSize(width: 378.5, height: 378.5)
				case .iPadPro10_5: return CGSize(width: 327.5, height: 327.5)
				case .iPadPro12_9: return CGSize(width: 378.5, height: 378.5)
				case .iPadAir_4thGen: return CGSize(width: 342, height: 342)
				case .iPad_7thGen: return CGSize(width: 320.5, height: 320.5)
				case .iPad: return CGSize(width: 305.5, height: 305.5)

				default: return CGSize(width: 360, height: 379)
				}

			case .systemLarge: fallthrough
			default:
				switch UIScreen.main.bounds.size.screenSize {
				case .iPhone12ProMax: return CGSize(width: 364, height: 382)
				case .iPhone12: return CGSize(width: 338, height: 354)
				case .iPhone11ProMax: return CGSize(width: 360, height: 379)
				case .iPhoneX: return CGSize(width: 329, height: 345)
				case .iPhoneSixPlus: return CGSize(width: 348, height: 357)
				case .iPhoneSix: return CGSize(width: 321, height: 324)
				case .iPhone5: return CGSize(width: 292, height: 311)
				case .iPhone: return CGSize(width: 292, height: 311)

				case .iPadPro11: return CGSize(width: 795, height: 378.5)
				case .iPadPro10_5: return CGSize(width: 682, height: 327.5)
				case .iPadPro12_9: return CGSize(width: 795, height: 378.5)
				case .iPadAir_4thGen: return CGSize(width: 715.5, height: 342)
				case .iPad_7thGen: return CGSize(width: 669.5, height: 320.5)
				case .iPad: return CGSize(width: 634.5, height: 305.5)

				default: return CGSize(width: 795, height: 378.5)
				}
			}
		}
	#endif
}


