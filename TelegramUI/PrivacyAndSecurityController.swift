import Foundation
import Display
import SwiftSignalKit
import Postbox
import TelegramCore

private final class PrivacyAndSecurityControllerArguments {
    let account: Account
    let openBlockedUsers: () -> Void
    let openLastSeenPrivacy: () -> Void
    let openGroupsPrivacy: () -> Void
    let openVoiceCallPrivacy: () -> Void
    let openPasscode: () -> Void
    let openTwoStepVerification: () -> Void
    let openActiveSessions: () -> Void
    let setupAccountAutoremove: () -> Void
    
    init(account: Account, openBlockedUsers: @escaping () -> Void, openLastSeenPrivacy: @escaping () -> Void, openGroupsPrivacy: @escaping () -> Void, openVoiceCallPrivacy: @escaping () -> Void, openPasscode: @escaping () -> Void, openTwoStepVerification: @escaping () -> Void, openActiveSessions: @escaping () -> Void, setupAccountAutoremove: @escaping () -> Void) {
        self.account = account
        self.openBlockedUsers = openBlockedUsers
        self.openLastSeenPrivacy = openLastSeenPrivacy
        self.openGroupsPrivacy = openGroupsPrivacy
        self.openVoiceCallPrivacy = openVoiceCallPrivacy
        self.openPasscode = openPasscode
        self.openTwoStepVerification = openTwoStepVerification
        self.openActiveSessions = openActiveSessions
        self.setupAccountAutoremove = setupAccountAutoremove
    }
}

private enum PrivacyAndSecuritySection: Int32 {
    case privacy
    case security
    case account
}

private enum PrivacyAndSecurityEntry: ItemListNodeEntry {
    case privacyHeader(PresentationTheme, String)
    case blockedPeers(PresentationTheme, String)
    case lastSeenPrivacy(PresentationTheme, String, String)
    case groupPrivacy(PresentationTheme, String, String)
    case voiceCallPrivacy(PresentationTheme, String, String)
    case securityHeader(PresentationTheme, String)
    case passcode(PresentationTheme, String)
    case twoStepVerification(PresentationTheme, String)
    case activeSessions(PresentationTheme, String)
    case accountHeader(PresentationTheme, String)
    case accountTimeout(PresentationTheme, String, String)
    case accountInfo(PresentationTheme, String)
    
    var section: ItemListSectionId {
        switch self {
            case .privacyHeader, .blockedPeers, .lastSeenPrivacy, .groupPrivacy, .voiceCallPrivacy:
                return PrivacyAndSecuritySection.privacy.rawValue
            case .securityHeader, .passcode, .twoStepVerification, .activeSessions:
                return PrivacyAndSecuritySection.security.rawValue
            case .accountHeader, .accountTimeout, .accountInfo:
                return PrivacyAndSecuritySection.account.rawValue
        }
    }
    
    var stableId: Int32 {
        switch self {
            case .privacyHeader:
                return 0
            case .blockedPeers:
                return 1
            case .lastSeenPrivacy:
                return 2
            case .groupPrivacy:
                return 3
            case .voiceCallPrivacy:
                return 4
            case .securityHeader:
                return 5
            case .passcode:
                return 6
            case .twoStepVerification:
                return 7
            case .activeSessions:
                return 8
            case .accountHeader:
                return 9
            case .accountTimeout:
                return 10
            case .accountInfo:
                return 11
        }
    }
    
    static func ==(lhs: PrivacyAndSecurityEntry, rhs: PrivacyAndSecurityEntry) -> Bool {
        switch lhs {
            case let .privacyHeader(lhsTheme, lhsText):
                if case let .privacyHeader(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                    return true
                } else {
                    return false
                }
            case let .blockedPeers(lhsTheme, lhsText):
                if case let .blockedPeers(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                    return true
                } else {
                    return false
                }
            case let .lastSeenPrivacy(lhsTheme, lhsText, lhsValue):
                if case let .lastSeenPrivacy(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                    return true
                } else {
                    return false
                }
            case let .groupPrivacy(lhsTheme, lhsText, lhsValue):
                if case let .groupPrivacy(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                    return true
                } else {
                    return false
                }
            case let .voiceCallPrivacy(lhsTheme, lhsText, lhsValue):
                if case let .voiceCallPrivacy(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                    return true
                } else {
                    return false
                }
            case let .securityHeader(lhsTheme, lhsText):
                if case let .securityHeader(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                    return true
                } else {
                    return false
                }
            case let .passcode(lhsTheme, lhsText):
                if case let .passcode(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                    return true
                } else {
                    return false
                }
            case let .twoStepVerification(lhsTheme, lhsText):
                if case let .twoStepVerification(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                    return true
                } else {
                    return false
                }
            case let .activeSessions(lhsTheme, lhsText):
                if case let .activeSessions(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                    return true
                } else {
                    return false
                }
            case let .accountHeader(lhsTheme, lhsText):
                if case let .accountHeader(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                    return true
                } else {
                    return false
                }
            case let .accountTimeout(lhsTheme, lhsText, lhsValue):
                if case let .accountTimeout(rhsTheme, rhsText, rhsValue) = rhs, lhsTheme === rhsTheme, lhsText == rhsText, lhsValue == rhsValue {
                    return true
                } else {
                    return false
                }
            case let .accountInfo(lhsTheme, lhsText):
                if case let .accountInfo(rhsTheme, rhsText) = rhs, lhsTheme === rhsTheme, lhsText == rhsText {
                    return true
                } else {
                    return false
                }
        }
    }
    
    static func <(lhs: PrivacyAndSecurityEntry, rhs: PrivacyAndSecurityEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }
    
    func item(_ arguments: PrivacyAndSecurityControllerArguments) -> ListViewItem {
        switch self {
            case let .privacyHeader(theme, text):
                return ItemListSectionHeaderItem(theme: theme, text: text, sectionId: self.section)
            case let .blockedPeers(theme, text):
                return ItemListDisclosureItem(theme: theme, title: text, label: "", sectionId: self.section, style: .blocks, action: {
                    arguments.openBlockedUsers()
                })
            case let .lastSeenPrivacy(theme, text, value):
                return ItemListDisclosureItem(theme: theme, title: text, label: value, sectionId: self.section, style: .blocks, action: {
                    arguments.openLastSeenPrivacy()
                })
            case let .groupPrivacy(theme, text, value):
                return ItemListDisclosureItem(theme: theme, title: text, label: value, sectionId: self.section, style: .blocks, action: {
                    arguments.openGroupsPrivacy()
                })
            case let .voiceCallPrivacy(theme, text, value):
                return ItemListDisclosureItem(theme: theme, title: text, label: value, sectionId: self.section, style: .blocks, action: {
                    arguments.openVoiceCallPrivacy()
                })
            case let .securityHeader(theme, text):
                return ItemListSectionHeaderItem(theme: theme, text: text, sectionId: self.section)
            case let .passcode(theme, text):
                return ItemListDisclosureItem(theme: theme, title: text, label: "", sectionId: self.section, style: .blocks, action: {
                    arguments.openPasscode()
                })
            case let .twoStepVerification(theme, text):
                return ItemListDisclosureItem(theme: theme, title: text, label: "", sectionId: self.section, style: .blocks, action: {
                    arguments.openTwoStepVerification()
                })
            case let .activeSessions(theme, text):
                return ItemListDisclosureItem(theme: theme, title: text, label: "", sectionId: self.section, style: .blocks, action: {
                    arguments.openActiveSessions()
                })
            case let .accountHeader(theme, text):
                return ItemListSectionHeaderItem(theme: theme, text: text, sectionId: self.section)
            case let .accountTimeout(theme, text, value):
                return ItemListDisclosureItem(theme: theme, title: text, label: value, sectionId: self.section, style: .blocks, action: {
                    arguments.setupAccountAutoremove()
                })
            case let .accountInfo(theme, text):
                return ItemListTextItem(theme: theme, text: .plain(text), sectionId: self.section)
        }
    }
}

private struct PrivacyAndSecurityControllerState: Equatable {
    let updatingAccountTimeoutValue: Int32?
    
    init() {
        self.updatingAccountTimeoutValue = nil
    }
    
    init(updatingAccountTimeoutValue: Int32?) {
        self.updatingAccountTimeoutValue = updatingAccountTimeoutValue
    }
    
    static func ==(lhs: PrivacyAndSecurityControllerState, rhs: PrivacyAndSecurityControllerState) -> Bool {
        if lhs.updatingAccountTimeoutValue != rhs.updatingAccountTimeoutValue {
            return false
        }
        
        return true
    }
    
    func withUpdatedUpdatingAccountTimeoutValue(_ updatingAccountTimeoutValue: Int32?) -> PrivacyAndSecurityControllerState {
        return PrivacyAndSecurityControllerState(updatingAccountTimeoutValue: updatingAccountTimeoutValue)
    }
}

private func stringForSelectiveSettings(strings: PresentationStrings, settings: SelectivePrivacySettings) -> String {
    switch settings {
        case let .disableEveryone(enableFor):
            if enableFor.isEmpty {
                return strings.PrivacySettings_LastSeenNobody
            } else {
                return strings.PrivacySettings_LastSeenNobodyPlus("\(enableFor.count)").0
            }
        case let .enableEveryone(disableFor):
            if disableFor.isEmpty {
                return strings.PrivacySettings_LastSeenEverybody
            } else {
                return strings.PrivacySettings_LastSeenEverybodyMinus("\(disableFor.count)").0
            }
        case let .enableContacts(enableFor, disableFor):
            if !enableFor.isEmpty && !disableFor.isEmpty {
                return strings.PrivacySettings_LastSeenContactsMinusPlus("\(enableFor.count)", "\(disableFor.count)").0
            } else if !enableFor.isEmpty {
                return strings.PrivacySettings_LastSeenContactsPlus("\(enableFor.count)").0
            } else if !disableFor.isEmpty {
                return strings.PrivacySettings_LastSeenContactsMinus("\(enableFor.count)").0
            } else {
                return strings.PrivacySettings_LastSeenContacts
            }
    }
}

private func privacyAndSecurityControllerEntries(presentationData: PresentationData, state: PrivacyAndSecurityControllerState, privacySettings: AccountPrivacySettings?) -> [PrivacyAndSecurityEntry] {
    var entries: [PrivacyAndSecurityEntry] = []
    
    entries.append(.privacyHeader(presentationData.theme, presentationData.strings.PrivacySettings_PrivacyTitle))
    entries.append(.blockedPeers(presentationData.theme, presentationData.strings.Settings_BlockedUsers))
    if let privacySettings = privacySettings {
        entries.append(.lastSeenPrivacy(presentationData.theme, presentationData.strings.PrivacySettings_LastSeen, stringForSelectiveSettings(strings: presentationData.strings, settings: privacySettings.presence)))
        entries.append(.groupPrivacy(presentationData.theme, presentationData.strings.Privacy_GroupsAndChannels, stringForSelectiveSettings(strings: presentationData.strings, settings: privacySettings.groupInvitations)))
        entries.append(.voiceCallPrivacy(presentationData.theme, presentationData.strings.Privacy_Calls, stringForSelectiveSettings(strings: presentationData.strings, settings: privacySettings.voiceCalls)))
    } else {
        entries.append(.lastSeenPrivacy(presentationData.theme, presentationData.strings.PrivacySettings_LastSeen, presentationData.strings.Channel_NotificationLoading))
        entries.append(.groupPrivacy(presentationData.theme, presentationData.strings.Privacy_GroupsAndChannels, presentationData.strings.Channel_NotificationLoading))
        entries.append(.voiceCallPrivacy(presentationData.theme, presentationData.strings.Privacy_Calls, presentationData.strings.Channel_NotificationLoading))
    }
    
    entries.append(.securityHeader(presentationData.theme, presentationData.strings.PrivacySettings_SecurityTitle))
    entries.append(.passcode(presentationData.theme, presentationData.strings.PrivacySettings_Passcode))
    entries.append(.twoStepVerification(presentationData.theme, presentationData.strings.PrivacySettings_TwoStepAuth))
    entries.append(.activeSessions(presentationData.theme, presentationData.strings.PrivacySettings_AuthSessions))
    entries.append(.accountHeader(presentationData.theme, presentationData.strings.PrivacySettings_DeleteAccountTitle))
    if let privacySettings = privacySettings {
        let value: Int32
        if let updatingAccountTimeoutValue = state.updatingAccountTimeoutValue {
            value = updatingAccountTimeoutValue
        } else {
            value = privacySettings.accountRemovalTimeout
        }
        entries.append(.accountTimeout(presentationData.theme, presentationData.strings.PrivacySettings_DeleteAccountIfAwayFor, timeIntervalString(strings: presentationData.strings, value: value)))
    } else {
        entries.append(.accountTimeout(presentationData.theme, presentationData.strings.PrivacySettings_DeleteAccountIfAwayFor, presentationData.strings.Channel_NotificationLoading))
    }
    entries.append(.accountInfo(presentationData.theme, presentationData.strings.PrivacySettings_DeleteAccountHelp))
    
    return entries
}

public func privacyAndSecurityController(account: Account, initialSettings: Signal<AccountPrivacySettings?, NoError>) -> ViewController {
    let statePromise = ValuePromise(PrivacyAndSecurityControllerState(), ignoreRepeated: true)
    let stateValue = Atomic(value: PrivacyAndSecurityControllerState())
    let updateState: ((PrivacyAndSecurityControllerState) -> PrivacyAndSecurityControllerState) -> Void = { f in
        statePromise.set(stateValue.modify { f($0) })
    }
    
    var pushControllerImpl: ((ViewController) -> Void)?
    var pushControllerInstantImpl: ((ViewController) -> Void)?
    var presentControllerImpl: ((ViewController) -> Void)?
    
    let actionsDisposable = DisposableSet()
    
    let currentInfoDisposable = MetaDisposable()
    actionsDisposable.add(currentInfoDisposable)
    
    let updateAccountTimeoutDisposable = MetaDisposable()
    actionsDisposable.add(updateAccountTimeoutDisposable)
    
    let privacySettingsPromise = Promise<AccountPrivacySettings?>()
    privacySettingsPromise.set(initialSettings)
    
    let arguments = PrivacyAndSecurityControllerArguments(account: account, openBlockedUsers: {
        pushControllerImpl?(blockedPeersController(account: account))
    }, openLastSeenPrivacy: {
        let signal = privacySettingsPromise.get()
            |> take(1)
            |> deliverOnMainQueue
        currentInfoDisposable.set(signal.start(next: { [weak currentInfoDisposable] info in
            if let info = info {
                pushControllerImpl?(selectivePrivacySettingsController(account: account, kind: .presence, current: info.presence, updated: { updated in
                    if let currentInfoDisposable = currentInfoDisposable {
                        let applySetting: Signal<Void, NoError> = privacySettingsPromise.get()
                            |> filter { $0 != nil }
                            |> take(1)
                            |> deliverOnMainQueue
                            |> mapToSignal { value -> Signal<Void, NoError> in
                                if let value = value {
                                    privacySettingsPromise.set(.single(AccountPrivacySettings(presence: updated, groupInvitations: value.groupInvitations, voiceCalls: value.voiceCalls, accountRemovalTimeout: value.accountRemovalTimeout)))
                                }
                                return .complete()
                            }
                        currentInfoDisposable.set(applySetting.start())
                    }
                }))
            }
        }))
    }, openGroupsPrivacy: {
        let signal = privacySettingsPromise.get()
            |> take(1)
            |> deliverOnMainQueue
        currentInfoDisposable.set(signal.start(next: { [weak currentInfoDisposable] info in
            if let info = info {
                pushControllerImpl?(selectivePrivacySettingsController(account: account, kind: .groupInvitations, current: info.groupInvitations, updated: { updated in
                    if let currentInfoDisposable = currentInfoDisposable {
                        let applySetting: Signal<Void, NoError> = privacySettingsPromise.get()
                            |> filter { $0 != nil }
                            |> take(1)
                            |> deliverOnMainQueue
                            |> mapToSignal { value -> Signal<Void, NoError> in
                                if let value = value {
                                    privacySettingsPromise.set(.single(AccountPrivacySettings(presence: value.presence, groupInvitations: updated, voiceCalls: value.voiceCalls, accountRemovalTimeout: value.accountRemovalTimeout)))
                                }
                                return .complete()
                        }
                        currentInfoDisposable.set(applySetting.start())
                    }
                }))
            }
        }))
    }, openVoiceCallPrivacy: {
        let signal = privacySettingsPromise.get()
            |> take(1)
            |> deliverOnMainQueue
        currentInfoDisposable.set(signal.start(next: { [weak currentInfoDisposable] info in
            if let info = info {
                pushControllerImpl?(selectivePrivacySettingsController(account: account, kind: .voiceCalls, current: info.voiceCalls, updated: { updated in
                    if let currentInfoDisposable = currentInfoDisposable {
                        let applySetting: Signal<Void, NoError> = privacySettingsPromise.get()
                            |> filter { $0 != nil }
                            |> take(1)
                            |> deliverOnMainQueue
                            |> mapToSignal { value -> Signal<Void, NoError> in
                                if let value = value {
                                    privacySettingsPromise.set(.single(AccountPrivacySettings(presence: value.presence, groupInvitations: value.groupInvitations, voiceCalls: updated, accountRemovalTimeout: value.accountRemovalTimeout)))
                                }
                                return .complete()
                        }
                        currentInfoDisposable.set(applySetting.start())
                    }
                }))
            }
        }))
    }, openPasscode: {
        let _ = passcodeOptionsAccessController(account: account, completion: { animated in
            if animated {
                pushControllerImpl?(passcodeOptionsController(account: account))
            } else {
                pushControllerInstantImpl?(passcodeOptionsController(account: account))
            }
        }).start(next: { controller in
            if let controller = controller {
                presentControllerImpl?(controller)
            }
        })
    }, openTwoStepVerification: {
        pushControllerImpl?(twoStepVerificationUnlockSettingsController(account: account, mode: .access))
    }, openActiveSessions: {
        pushControllerImpl?(recentSessionsController(account: account))
    }, setupAccountAutoremove: {
        let signal = privacySettingsPromise.get()
            |> take(1)
            |> deliverOnMainQueue
        updateAccountTimeoutDisposable.set(signal.start(next: { [weak updateAccountTimeoutDisposable] privacySettingsValue in
            if let _ = privacySettingsValue {
                let presentationData = account.telegramApplicationContext.currentPresentationData.with { $0 }
                let controller = ActionSheetController()
                let dismissAction: () -> Void = { [weak controller] in
                    controller?.dismissAnimated()
                }
                let timeoutAction: (Int32) -> Void = { timeout in
                    if let updateAccountTimeoutDisposable = updateAccountTimeoutDisposable {
                        updateState {
                            return $0.withUpdatedUpdatingAccountTimeoutValue(timeout)
                        }
                        let applyTimeout: Signal<Void, NoError> = privacySettingsPromise.get()
                            |> filter { $0 != nil }
                            |> take(1)
                            |> deliverOnMainQueue
                            |> mapToSignal { value -> Signal<Void, NoError> in
                                if let value = value {
                                    privacySettingsPromise.set(.single(AccountPrivacySettings(presence: value.presence, groupInvitations: value.groupInvitations, voiceCalls: value.voiceCalls, accountRemovalTimeout: timeout)))
                                }
                                return .complete()
                            }
                        updateAccountTimeoutDisposable.set((updateAccountRemovalTimeout(account: account, timeout: timeout)
                            |> then(applyTimeout)
                            |> deliverOnMainQueue).start(completed: {
                                updateState {
                                    return $0.withUpdatedUpdatingAccountTimeoutValue(nil)
                                }
                            }))
                    }
                }
                let timeoutValues: [Int32] = [
                    1 * 30 * 24 * 60 * 60,
                    3 * 30 * 24 * 60 * 60,
                    6 * 30 * 24 * 60 * 60,
                    12 * 30 * 24 * 60 * 60
                ]
                let timeoutItems: [ActionSheetItem] = timeoutValues.map { value in
                    return ActionSheetButtonItem(title: timeIntervalString(strings: presentationData.strings, value: value), action: {
                        dismissAction()
                        timeoutAction(value)
                    })
                }
                controller.setItemGroups([
                    ActionSheetItemGroup(items: timeoutItems),
                    ActionSheetItemGroup(items: [ActionSheetButtonItem(title: presentationData.strings.Common_Cancel, action: { dismissAction() })])
                ])
                presentControllerImpl?(controller)
            }
        }))
    })
    
    let signal = combineLatest((account.applicationContext as! TelegramApplicationContext).presentationData, statePromise.get() |> deliverOnMainQueue, privacySettingsPromise.get())
        |> map { presentationData, state, privacySettings -> (ItemListControllerState, (ItemListNodeState<PrivacyAndSecurityEntry>, PrivacyAndSecurityEntry.ItemGenerationArguments)) in
            
            var rightNavigationButton: ItemListNavigationButton?
            if privacySettings == nil || state.updatingAccountTimeoutValue != nil {
                rightNavigationButton = ItemListNavigationButton(title: "", style: .activity, enabled: true, action: {})
            }
            
            let controllerState = ItemListControllerState(theme: presentationData.theme, title: .text(presentationData.strings.PrivacySettings_Title), leftNavigationButton: nil, rightNavigationButton: rightNavigationButton, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back), animateChanges: false)
            let listState = ItemListNodeState(entries: privacyAndSecurityControllerEntries(presentationData: presentationData, state: state, privacySettings: privacySettings), style: .blocks, animateChanges: false)
            
            return (controllerState, (listState, arguments))
        } |> afterDisposed {
            actionsDisposable.dispose()
        }
    
    let controller = ItemListController(account: account, state: signal)
    pushControllerImpl = { [weak controller] c in
        (controller?.navigationController as? NavigationController)?.pushViewController(c)
    }
    pushControllerInstantImpl = { [weak controller] c in
        (controller?.navigationController as? NavigationController)?.pushViewController(c, animated: false)
    }
    presentControllerImpl = { [weak controller] c in
        controller?.present(c, in: .window(.root), with: ViewControllerPresentationArguments(presentationAnimation: .modalSheet))
    }
    
    return controller
}
