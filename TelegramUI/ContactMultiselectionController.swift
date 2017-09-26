import Foundation
import Display
import AsyncDisplayKit
import Postbox
import SwiftSignalKit
import TelegramCore

public enum ContactMultiselectionControllerMode {
    case groupCreation
    case peerSelection
}

public class ContactMultiselectionController: ViewController {
    private let account: Account
    private let mode: ContactMultiselectionControllerMode
    
    private let titleView: CounterContollerTitleView
    
    private var contactsNode: ContactMultiselectionControllerNode {
        return self.displayNode as! ContactMultiselectionControllerNode
    }
    
    private let index: PeerNameIndex = .lastNameFirst
    
    private var _ready = Promise<Bool>()
    private var _limitsReady = Promise<Bool>()
    private var _listReady = Promise<Bool>()
    override public var ready: Promise<Bool> {
        return self._ready
    }
    
    private let _result = Promise<[PeerId]>()
    public var result: Signal<[PeerId], NoError> {
        return self._result.get()
    }
    
    private var rightNavigationButton: UIBarButtonItem?
    
    private var didPlayPresentationAnimation = false
    
    private var presentationData: PresentationData
    private var presentationDataDisposable: Disposable?
    
    private var limitsConfiguration: LimitsConfiguration?
    private var limitsConfigurationDisposable: Disposable?
    
    public init(account: Account, mode: ContactMultiselectionControllerMode) {
        self.account = account
        self.mode = mode
        
        self.presentationData = account.telegramApplicationContext.currentPresentationData.with { $0 }
        
        self.titleView = CounterContollerTitleView(theme: self.presentationData.theme)
        
        super.init(navigationBarTheme: NavigationBarTheme(rootControllerTheme: self.presentationData.theme))
        
        self.statusBar.statusBarStyle = self.presentationData.theme.rootController.statusBar.style.style
        
        self.navigationItem.titleView = self.titleView
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: self.presentationData.strings.Common_Back, style: .plain, target: nil, action: nil)
        
        self.scrollToTop = { [weak self] in
            if let strongSelf = self {
                strongSelf.contactsNode.contactListNode.scrollToTop()
            }
        }
        
        self.presentationDataDisposable = (account.telegramApplicationContext.presentationData
            |> deliverOnMainQueue).start(next: { [weak self] presentationData in
                if let strongSelf = self {
                    let previousTheme = strongSelf.presentationData.theme
                    let previousStrings = strongSelf.presentationData.strings
                    
                    strongSelf.presentationData = presentationData
                    
                    if previousTheme !== presentationData.theme || previousStrings !== presentationData.strings {
                        strongSelf.updateThemeAndStrings()
                    }
                }
            })
        
        self.limitsConfigurationDisposable = (account.postbox.modify { modifier -> LimitsConfiguration in
            return currentLimitsConfiguration(modifier: modifier)
        } |> deliverOnMainQueue).start(next: { [weak self] value in
            if let strongSelf = self {
                strongSelf.limitsConfiguration = value
                strongSelf.updateTitle()
                strongSelf._limitsReady.set(.single(true))
            }
        })
        
        self._ready.set(combineLatest(self._listReady.get(), self._limitsReady.get()) |> map { $0 && $1 })
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.presentationDataDisposable?.dispose()
        self.limitsConfigurationDisposable?.dispose()
    }
    
    private func updateThemeAndStrings() {
        self.statusBar.statusBarStyle = self.presentationData.theme.rootController.statusBar.style.style
        self.navigationBar?.updateTheme(NavigationBarTheme(rootControllerTheme: self.presentationData.theme))
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: self.presentationData.strings.Common_Back, style: .plain, target: nil, action: nil)
        self.updateTitle()
    }
    
    private func updateTitle() {
        switch self.mode {
            case .groupCreation:
                let maxCount: Int32 = self.limitsConfiguration?.maxSupergroupMemberCount ?? 5000
                self.titleView.title = CounterContollerTitle(title: self.presentationData.strings.Compose_NewGroup, counter: "0/\(maxCount)")
                let rightNavigationButton = UIBarButtonItem(title: self.presentationData.strings.Common_Next, style: .done, target: self, action: #selector(self.rightNavigationButtonPressed))
                self.rightNavigationButton = rightNavigationButton
                self.navigationItem.rightBarButtonItem = self.rightNavigationButton
                rightNavigationButton.isEnabled = false
            case .peerSelection:
                self.titleView.title = CounterContollerTitle(title: self.presentationData.strings.PrivacyLastSeenSettings_EmpryUsersPlaceholder, counter: "")
                let rightNavigationButton = UIBarButtonItem(title: self.presentationData.strings.Common_Done, style: .done, target: self, action: #selector(self.rightNavigationButtonPressed))
                self.rightNavigationButton = rightNavigationButton
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: self.presentationData.strings.Common_Cancel, style: .plain, target: self, action: #selector(cancelPressed))
                self.navigationItem.rightBarButtonItem = self.rightNavigationButton
                rightNavigationButton.isEnabled = false
        }
    }
    
    override public func loadDisplayNode() {
        self.displayNode = ContactMultiselectionControllerNode(account: self.account)
        self._listReady.set(self.contactsNode.contactListNode.ready)
        
        self.contactsNode.dismiss = { [weak self] in
            self?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
        self.contactsNode.openPeer = { [weak self] peer in
            if let strongSelf = self {
                var updatedCount: Int?
                var addedToken: EditableTokenListToken?
                var removedTokenId: AnyHashable?
                
                let maxRegularCount: Int32 = strongSelf.limitsConfiguration?.maxGroupMemberCount ?? 200
                var displayCountAlert = false
                
                var selectionState: ContactListNodeGroupSelectionState?
                strongSelf.contactsNode.contactListNode.updateSelectionState { state in
                    if let state = state {
                        var updatedState = state.withToggledPeerId(peer.id)
                        if updatedState.selectedPeerIndices[peer.id] == nil {
                            removedTokenId = peer.id
                        } else {
                            if updatedState.selectedPeerIndices.count >= maxRegularCount {
                                displayCountAlert = true
                                updatedState = updatedState.withToggledPeerId(peer.id)
                            } else {
                                addedToken = EditableTokenListToken(id: peer.id, title: peer.displayTitle)
                            }
                        }
                        updatedCount = updatedState.selectedPeerIndices.count
                        selectionState = updatedState
                        return updatedState
                    } else {
                        return nil
                    }
                }
                if let searchResultsNode = strongSelf.contactsNode.searchResultsNode {
                    searchResultsNode.updateSelectionState { _ in
                        return selectionState
                    }
                }
                
                if let updatedCount = updatedCount {
                    strongSelf.rightNavigationButton?.isEnabled = updatedCount != 0
                    switch strongSelf.mode {
                        case .groupCreation:
                            let maxCount: Int32 = strongSelf.limitsConfiguration?.maxSupergroupMemberCount ?? 5000
                            strongSelf.titleView.title = CounterContollerTitle(title: strongSelf.presentationData.strings.Compose_NewGroup, counter: "\(updatedCount)/\(maxCount)")
                        case .peerSelection:
                            break
                    }
                }
                
                if let addedToken = addedToken {
                    strongSelf.contactsNode.editableTokens.append(addedToken)
                } else if let removedTokenId = removedTokenId {
                    strongSelf.contactsNode.editableTokens = strongSelf.contactsNode.editableTokens.filter { token in
                        return token.id != removedTokenId
                    }
                }
                strongSelf.requestLayout(transition: ContainedViewLayoutTransition.animated(duration: 0.4, curve: .spring))
                
                if displayCountAlert {
                    strongSelf.present(standardTextAlertController(title: nil, text: strongSelf.presentationData.strings.CreateGroup_SoftUserLimitAlert, actions: [TextAlertAction(type: .defaultAction, title: strongSelf.presentationData.strings.Common_OK, action: {})]), in: .window(.root))
                }
            }
        }
        
        self.contactsNode.removeSelectedPeer = { [weak self] peerId in
            if let strongSelf = self {
                var updatedCount: Int?
                var removedTokenId: AnyHashable?
                
                var selectionState: ContactListNodeGroupSelectionState?
                strongSelf.contactsNode.contactListNode.updateSelectionState { state in
                    if let state = state {
                        let updatedState = state.withToggledPeerId(peerId)
                        if updatedState.selectedPeerIndices[peerId] == nil {
                            removedTokenId = peerId
                        }
                        updatedCount = updatedState.selectedPeerIndices.count
                        selectionState = updatedState
                        return updatedState
                    } else {
                        return nil
                    }
                }
                if let searchResultsNode = strongSelf.contactsNode.searchResultsNode {
                    searchResultsNode.updateSelectionState { _ in
                        return selectionState
                    }
                }
                
                if let updatedCount = updatedCount {
                    strongSelf.rightNavigationButton?.isEnabled = updatedCount != 0
                    switch strongSelf.mode {
                        case .groupCreation:
                            let maxCount: Int32 = strongSelf.limitsConfiguration?.maxSupergroupMemberCount ?? 5000
                            strongSelf.titleView.title = CounterContollerTitle(title: strongSelf.presentationData.strings.Compose_NewGroup, counter: "\(updatedCount)/\(maxCount)")
                        case .peerSelection:
                            break
                    }
                }
                
                if let removedTokenId = removedTokenId {
                    strongSelf.contactsNode.editableTokens = strongSelf.contactsNode.editableTokens.filter { token in
                        return token.id != removedTokenId
                    }
                }
                strongSelf.requestLayout(transition: ContainedViewLayoutTransition.animated(duration: 0.4, curve: .spring))
            }
        }
        
        self.displayNodeDidLoad()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.contactsNode.contactListNode.enableUpdates = true
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let presentationArguments = self.presentationArguments as? ViewControllerPresentationArguments, !self.didPlayPresentationAnimation {
            self.didPlayPresentationAnimation = true
            if case .modalSheet = presentationArguments.presentationAnimation {
                self.contactsNode.animateIn()
            }
        }
    }
    
    override open func dismiss(completion: (() -> Void)? = nil) {
        self.contactsNode.animateOut(completion: completion)
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.contactsNode.contactListNode.enableUpdates = false
    }
    
    override public func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)
        
        self.contactsNode.containerLayoutUpdated(layout, navigationBarHeight: self.navigationHeight, transition: transition)
    }
    
    @objc func cancelPressed() {
        self._result.set(.single([]))
    }
    
    @objc func rightNavigationButtonPressed() {
        var peerIds: [PeerId] = []
        self.contactsNode.contactListNode.updateSelectionState { state in
            if let state = state {
                peerIds = Array(state.selectedPeerIndices.keys)
            }
            return state
        }
        self._result.set(.single(peerIds))
    }
}
