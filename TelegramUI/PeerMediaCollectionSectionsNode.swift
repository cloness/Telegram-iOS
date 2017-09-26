import Foundation
import AsyncDisplayKit
import Display
import TelegramCore

final class PeerMediaCollectionSectionsNode: ASDisplayNode {
    private var theme: PresentationTheme
    private var strings: PresentationStrings
    
    private let segmentedControl: UISegmentedControl
    private let separatorNode: ASDisplayNode
    
    var indexUpdated: ((Int) -> Void)?
    
    init(theme: PresentationTheme, strings: PresentationStrings) {
        self.theme = theme
        self.strings = strings
        
        self.segmentedControl = UISegmentedControl(items: [
            strings.SharedMedia_CategoryMedia,
            strings.SharedMedia_CategoryDocs,
            strings.SharedMedia_CategoryLinks,
            strings.SharedMedia_CategoryOther
        ])
        self.segmentedControl.selectedSegmentIndex = 0
        
        self.separatorNode = ASDisplayNode()
        self.separatorNode.isLayerBacked = true
        self.separatorNode.displaysAsynchronously = false
        self.separatorNode.backgroundColor = self.theme.rootController.navigationBar.separatorColor
        
        super.init()
        
        self.addSubnode(self.separatorNode)
        self.view.addSubview(self.segmentedControl)
        
        self.backgroundColor = self.theme.rootController.navigationBar.backgroundColor
        
        self.segmentedControl.addTarget(self, action: #selector(indexChanged), for: .valueChanged)
    }
    
    func updateLayout(width: CGFloat, transition: ContainedViewLayoutTransition) -> CGFloat {
        let panelHeight: CGFloat = 39.0
        
        let controlHeight: CGFloat = 29.0
        let sideInset: CGFloat = 8.0
        transition.animateView {
            self.segmentedControl.frame = CGRect(origin: CGPoint(x: sideInset, y: panelHeight - 11.0 - controlHeight), size: CGSize(width: width - sideInset * 2.0, height: controlHeight))
        }
        
        transition.updateFrame(node: self.separatorNode, frame: CGRect(origin: CGPoint(x: 0.0, y: panelHeight - UIScreenPixel), size: CGSize(width: width, height: UIScreenPixel)))
        
        return panelHeight
    }
    
    @objc func indexChanged() {
        self.indexUpdated?(self.segmentedControl.selectedSegmentIndex)
    }
}
