//
//  SwipeActions.swift
//  
//
//  Created by Ben Gottlieb on 5/14/21.
//

#if canImport(Combine)
import SwiftUI

@available(macOS 10.15, iOS 13.0, watchOS 7.0, *)
public extension View {
    func addSwipeActions<TrailingViews: View>(trailing: TrailingViews, id: String) -> some View {
        SwipeActions(content: self, leading: EmptyView(), trailing: trailing, id: id)
    }
}

private var currentCellCollapseBlock: (() -> Void)?
private var currentCellID: String?
private var activeCellID: String?

@available(macOS 10.15, iOS 13.0, watchOS 7.0, *)
struct SwipeActions<Content: View, LeadingViews: View, TrailingViews: View>: View {
    let content: Content
    let leading: LeadingViews
    let trailing: TrailingViews
    let id: String
    
    @State var contentOffset: CGFloat = 0
    @State var trailingSize: CGSize = .zero
    @State var leadingSize: CGSize = .zero
    @State var isShowingButtons = false
    @State var yPosition: CGFloat = 0
    @State var screenWidth: CGFloat = 320

    var maxScroll: CGFloat { leadingSize.width == 0 ? 0 : screenWidth }
    var minScroll: CGFloat { trailingSize.width == 0 ? 0 : -screenWidth }

    func buildContent(in geo: GeometryProxy) -> some View {
        let current = geo.frame(in: .global).minY
        DispatchQueue.main.async {
            screenWidth = geo.width
        }
    
        if current != yPosition {
            DispatchQueue.main.async {
                yPosition = current
                hideButtons()
                activeCellID = nil
            }
        }
        return content
    }
    
    func hideCurrent() {
        if currentCellID == id { return }
        let block = currentCellCollapseBlock
        DispatchQueue.main.async { block?() }
        currentCellCollapseBlock = hideButtons
        currentCellID = id
    }
    
    func hideButtons() {
        withAnimation() { isShowingButtons = false; contentOffset = 0 }
    }
    
    var body: some View {
        content
            .opacity(0.0)
            .overlay(
                GeometryReader() { geo in
                    ZStack() {
                        buildContent(in: geo)
                            .overlay(blocker)
                            .frame(width: geo.width)
                            .offset(x: contentOffset)
                            .layoutPriority(1)
                            .highPriorityGesture(DragGesture(minimumDistance: 30).onChanged { recog in
                                if activeCellID == nil {
                                    activeCellID = id
                                    hideCurrent()
                                } else if activeCellID != id {
                                    return
                                }
                                contentOffset = max(min(maxScroll, recog.translation.width), minScroll)
                            }.onEnded { recog in
                                if activeCellID != id { return }
                                activeCellID = nil
                                contentOffset = max(min(maxScroll, recog.predictedEndTranslation.width), minScroll)
                                
                                if contentOffset < -trailingSize.width * 0.75 {
                                    isShowingButtons = true
                                    withAnimation() { contentOffset = -trailingSize.width }
                                } else if contentOffset > leadingSize.width * 0.75 {
                                    isShowingButtons = true
                                    withAnimation() { contentOffset = leadingSize.width }
                                } else {
                                    hideButtons()
                                }
                            })
                            .background(buttons)
                            .clipped()
                    }
                }
                .onDisappear() {
                    DispatchQueue.main.async { hideButtons() }
                }
            )
    }
    
    @ViewBuilder var blocker: some View {
        if isShowingButtons {
            Rectangle()
                .fill(Color.black.opacity(0.01))
                .onTapGesture(perform: hideButtons)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder var buttons: some View {
        HStack(spacing: 0) {
            leading
                .sizeReporting($leadingSize)
            Spacer()
            trailing
                .offset(x: max(0, contentOffset + trailingSize.width))
                .sizeReporting($trailingSize)
        }
        .opacity(contentOffset == 0 ? 0 : 1.0)
        .animation(.none)
    }
}

#if os(iOS) || os(macOS)
	@available(macOS 10.15, iOS 13.0, *)
	struct SwipeActions_Previews: PreviewProvider {
			struct Row: View {
					var body: some View {
							ZStack() {
									Text("My Row")
									VStack() {
											Spacer()
											Rectangle().fill(Color.gray)
													.frame(height: 1)
									}
							}
							.frame(height: 50)
							.background(Color.systemBackground)
					}
			}
			
			static var previews: some View {
					SwipeActions(content: Row(), leading: EmptyView(), trailing: Button("Delete", action: { print("Delete") }).padding().frame(maxHeight: .infinity).backgroundColor(.red).foregroundColor(.white), id: "none").frame(height: 50)
			}
	}
#endif
#endif
