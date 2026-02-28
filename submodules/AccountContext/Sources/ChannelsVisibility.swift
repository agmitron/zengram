import TelegramCore

public enum ChannelsVisibility {
    public static let isEnabled = false
}

public func isBroadcastChannelPeer(_ peer: EnginePeer) -> Bool {
    if case let .channel(channel) = peer, case .broadcast = channel.info {
        return true
    }
    return false
}
