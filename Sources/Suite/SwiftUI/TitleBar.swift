//
//  TitleBar.swift
//  Internal
//
//  Created by Ben Gottlieb on 3/6/23.
//

import SwiftUI

public struct TitleBarFontKey: EnvironmentKey {
	public static var defaultValue = Font.title
}

public extension EnvironmentValues {
	var titleBarFont: Font {
		get { self[TitleBarFontKey.self] }
		set { self[TitleBarFontKey.self] = newValue }
	}
}

public struct TitleBar<Leading: View, Trailing: View, Title: View>: View {
	let title: () -> Title
	@ViewBuilder var leading: () -> Leading
	@ViewBuilder var trailing: () -> Trailing
	
	@State private var leadingFrame: CGRect?
	@State private var trailingFrame: CGRect?

	@Environment(\.titleBarFont) var titleBarFont
	
	public init(title: @escaping () -> Title, @ViewBuilder leading: @escaping () -> Leading, @ViewBuilder trailing: @escaping () -> Trailing) {
		self.title = title
		self.leading = leading
		self.trailing = trailing
	}
	
	public var body: some View {
		ZStack {
			leading()
				.reportGeometry(frame: $leadingFrame)
				.frame(maxWidth: .infinity, alignment: .leading)

			trailing()
				.reportGeometry(frame: $trailingFrame)
				.frame(maxWidth: .infinity, alignment: .trailing)

			title()
				.frame(maxWidth: .infinity, alignment: .center)
				.minimumScaleFactor(0.5)
				.multilineTextAlignment(.center)
				.font(titleBarFont)
				.padding(.horizontal, 1)
				.padding(.leading, leadingFrame?.width)
				.padding(.trailing, trailingFrame?.width)
		}
		.padding(.horizontal)
		.frame(height: 50)
		.navigationBarHidden(true)
	}
}

extension TitleBar where Leading == EmptyView {
	public init(title: @escaping () -> Title, @ViewBuilder trailing: @escaping () -> Trailing) {
		self.init(title: title, leading: { EmptyView() }, trailing: trailing)
	}
}

extension TitleBar where Trailing == EmptyView {
	public init(title: @escaping () -> Title, @ViewBuilder leading: @escaping () -> Leading) {
		self.init(title: title, leading: leading, trailing: { EmptyView() })
	}
}

extension TitleBar where Trailing == EmptyView, Leading == EmptyView {
	public init(title: @escaping () -> Title) {
		self.init(title: title, leading: { EmptyView() }, trailing: { EmptyView() })
	}
}

extension TitleBar where Title == Text {
	public init(_ title: String, @ViewBuilder leading: @escaping () -> Leading, @ViewBuilder trailing: @escaping () -> Trailing) {
		self.init(title: { Text(title) }, leading: leading, trailing: trailing)
	}
}

extension TitleBar where Leading == EmptyView, Title == Text {
	public init(_ title: String, @ViewBuilder trailing: @escaping () -> Trailing) {
		self.init(title: { Text(title) }, leading: { EmptyView() }, trailing: trailing)
	}
}

extension TitleBar where Trailing == EmptyView, Title == Text {
	public init(_ title: String, @ViewBuilder leading: @escaping () -> Leading) {
		self.init(title: { Text(title) }, leading: leading, trailing: { EmptyView() })
	}
}

extension TitleBar where Trailing == EmptyView, Leading == EmptyView, Title == Text {
	public init(_ title: String) {
		self.init(title: { Text(title) }, leading: { EmptyView() }, trailing: { EmptyView() })
	}
}

struct TitleBar_Previews: PreviewProvider {
	static var previews: some View {
		TitleBar("Title")
	}
}
