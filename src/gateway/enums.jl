# https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes
@discord_enum GatewayOpcode begin
    Dispatch = 0
    Heartbeat = 1
    Identify = 2
    PresenceUpdate = 3
    VoiceStateUpdate = 4
    Resume = 6
    Reconnect = 7
    RequestGuildMembers = 8
    InvalidSession = 9
    Hello = 10
    HeartbeatACK = 11
end

# https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-close-event-codes
@discord_enum GatewayCloseEventCode begin
    UnknownError = 4000
    UnknownOpcode = 4001
    DecodeError = 4002
    NotAuthenticated = 4003
    AuthenticationFailed = 4004
    AlreadyAuthenticated = 4005
    InvalidSeq = 4007
    RateLimited = 4008
    SessionTimedOut = 4009
    InvalidShard = 4010
    ShardingRequired = 4011
    InvalidAPIVersion = 4012
    InvalidIntent = 4013
    DisallowedIntent = 4014
end

# https://discord.com/developers/docs/topics/opcodes-and-status-codes#voice-voice-opcodes
@discord_enum VoiceOpcode begin
    Identify = 0
    SelectProtocol = 1
    Ready = 2
    Heartbeat = 3
    SessionDescription = 4
    Speaking = 5
    HeartbeatACK = 6
    Resume = 7
    Hello = 8
    Resumed = 9
    ClientDisconnect = 10
end

# https://discord.com/developers/docs/topics/opcodes-and-status-codes#voice-voice-close-event-codes
@discord_enum VoiceCloseEventCode begin
    UnknownOpcode = 4001
    FailedToDecodePayload = 4002
    NotAuthenticated = 4003
    AuthenticationFailed = 4004
    AlreadyAuthenticated = 4005
    SessionNoLongerValid = 4006
    SessionTimedOut = 4009
    ServerNotFound = 4011
    UnknownProtocol = 4012
    Disconnected = 4014
    VoiceServerCrashed = 4015
    UnknownEncryptionMode = 4016
end
