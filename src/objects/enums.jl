# https://discord.com/developers/docs/resources/user#user-object-premium-types
@discord_enum UserPremiumType begin
    NONE = 0
    NITRO_CLASSIC = 1
    NITRO = 2
end

# https://discord.com/developers/docs/resources/guild#integration-object-integration-expire-behaviors
@discord_enum IntegrationExpireBehavior begin
    REMOVE_ROLE = 0
    KICK = 1
end

# https://discord.com/developers/docs/resources/user#connection-object-visibility-types
@discord_enum ConnectionVisibility begin
    NONE = 0
    EVERYONE = 1
end

# https://discord.com/developers/docs/resources/channel#channel-object-channel-types
# Type 10, 11 and 12 are only available in API v9.
@discord_enum ChannelType begin
    GUILD_TEXT = 0
    DM = 1
    GUILD_VOICE = 2
    GROUP_DM = 3
    GUILD_CATEGORY = 4
    GUILD_NEWS = 5
    GUILD_NEWS_THREAD = 10
    GUILD_PUBLIC_THREAD = 11
    GUILD_PRIVATE_THREAD = 12
    GUILD_STAGE_VOICE = 13
    GUILD_DIRECTORY = 14
    GUILD_FORUM = 15
end

# https://discord.com/developers/docs/resources/channel#message-object-message-types
# Type 19 and 20 are only in API v8. In v6, they are still type 0.
# Type 21 is only in API v9.
@discord_enum MessageType begin
    DEFAULT = 0
    RECIPIENT_ADD = 1
    RECIPIENT_REMOVE = 2
    CALL = 3
    CHANNEL_NAME_CHANGE = 4
    CHANNEL_ICON_CHANGE = 5
    CHANNEL_PINNED_MESSAGE = 6
    GUILD_MEMBER_JOIN = 7
    USER_PREMIUM_GUILD_SUBSCRIPTION = 8
    USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_1 = 9
    USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_2 = 10
    USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_3 = 11
    CHANNEL_FOLLOW_ADD = 12
    GUILD_DISCOVERY_DISQUALIFIED = 14
    GUILD_DISCOVERY_REQUALIFIED = 15
    GUILD_DISCOVERY_GRACE_PERIOD_INITIAL_WARNING = 16
    GUILD_DISCOVERY_GRACE_PERIOD_FINAL_WARNING = 17
    THREAD_CREATED = 18
    REPLY = 19
    CHAT_INPUT_COMMAND = 20
    THREAD_STARTER_MESSAGE = 21
    GUILD_INVITE_REMINDER = 22
    CONTEXT_MENU_COMMAND = 23
end

# https://discord.com/developers/docs/resources/channel#message-object-message-activity-types
@discord_enum MessageActivityType begin
    JOIN = 1
    SPECTATE = 2
    LISTEN = 3
    JOIN_REQUEST = 5
end

# https://discord.com/developers/docs/resources/guild#guild-object-verification-level
@discord_enum VerificationLevel begin
    NONE = 0
    LOW = 1
    MEDIUM = 2
    HIGH = 3
    VERY_HIGH = 4
end

# https://discord.com/developers/docs/resources/guild#guild-object-default-message-notification-level
@discord_enum MessageNotificationsLevel begin
    ALL_MESSAGES = 0
    ONLY_MENTIONS = 1
end

# https://discord.com/developers/docs/resources/guild#guild-object-explicit-content-filter-level
@discord_enum ExplicitContentFilter begin
    DISABLED = 0
    MEMBERS_WITHOUT_ROLES = 1
    ALL_MEMBERS = 2
end

# https://discord.com/developers/docs/resources/guild#guild-object-mfa-level
@discord_enum MFALevel begin
    NONE = 0
    ELEVATED = 1
end

# https://discord.com/developers/docs/resources/guild#guild-object-premium-tier
@discord_enum PremiumTier begin
    NONE = 0
    TIER_1 = 1
    TIER_2 = 2
    TIER_3 = 3
end

# https://discord.com/developers/docs/resources/guild#guild-object-guild-nsfw-level
@discord_enum GuildNSFWLevel begin
    DEFAULT = 0
    EXPLICIT = 1
    SAFE = 2
    AGE_RESTRICTED = 3
end

# https://discord.com/developers/docs/game-sdk/activities#data-models-activitytype-enum
@discord_enum ActivityType begin
    PLAYING = 0
    STREAMING = 1
    LISTENING = 2
    WATCHING = 3
    CUSTOM = 4
    COMPETING = 5
end

# https://discord.com/developers/docs/resources/webhook#webhook-object-webhook-types
@discord_enum WebhookType begin
    INCOMING = 1
    CHANNEL_FOLLOWER = 2
    APPLICATION = 3
end

# https://discord.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-events
@discord_enum AuditLogEvent begin
    GUILD_UPDATE = 1
    CHANNEL_CREATE = 10
    CHANNEL_UPDATE = 11
    CHANNEL_DELETE = 12
    CHANNEL_OVERWRITE_CREATE = 13
    CHANNEL_OVERWRITE_UPDATE = 14
    CHANNEL_OVERWRITE_DELETE = 15
    MEMBER_KICK = 20
    MEMBER_PRUNE = 21
    MEMBER_BAN_ADD = 22
    MEMBER_BAN_REMOVE = 23
    MEMBER_UPDATE = 24
    MEMBER_ROLE_UPDATE = 25
    MEMBER_MOVE = 26
    MEMBER_DISCONNECT = 27
    BOT_ADD = 28
    ROLE_CREATE = 30
    ROLE_UPDATE = 31
    ROLE_DELETE = 32
    INVITE_CREATE = 40
    INVITE_UPDATE = 41
    INVITE_DELETE = 42
    WEBHOOK_CREATE = 50
    WEBHOOK_UPDATE = 51
    WEBHOOK_DELETE = 52
    EMOJI_CREATE = 60
    EMOJI_UPDATE = 61
    EMOJI_DELETE = 62
    MESSAGE_DELETE = 72
    MESSAGE_BULK_DELETE = 73
    MESSAGE_PIN = 74
    MESSAGE_UNPIN = 75
    INTEGRATION_CREATE = 80
    INTEGRATION_UPDATE = 81
    INTEGRATION_DELETE = 82
    STAGE_INSTANCE_CREATE = 83
    STAGE_INSTANCE_UPDATE = 84
    STAGE_INSTANCE_DELETE = 85
    STICKER_CREATE = 90
    STICKER_UPDATE = 91
    STICKER_DELETE = 92
    GUILD_SCHEDULED_EVENT_CREATE = 100
    GUILD_SCHEDULED_EVENT_UPDATE = 101
    GUILD_SCHEDULED_EVENT_DELETE = 102
    THREAD_CREATE = 110
    THREAD_UPDATE = 111
    THREAD_DELETE = 112
end

# https://discord.com/developers/docs/resources/invite#invite-object-invite-target-types
@discord_enum InviteTargetType begin
    STREAM = 1
    EMBEDDED_APPLICATION = 2
end

# This is used for both GuildScheduledEvent and StageInstance objects
# The documentation are separate and distinct, but the values seem to match.
# So, this is defined once rather as separate enums. If the situation changes
# in the future, then we can just split the enum.
# https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object-guild-scheduled-event-privacy-level
# https://discord.com/developers/docs/resources/stage-instance#stage-instance-object-privacy-level
@discord_enum PrivacyLevel begin
    PUBLIC = 1
    GUILD_ONLY = 2
end

# https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object-guild-scheduled-event-status
@discord_enum GuildScheduledEventStatus begin
    SCHEDULED = 1
    ACTIVE = 2
    COMPLETED = 3
    CANCELED = 4
end

# https://discord.com/developers/docs/resources/guild-scheduled-event#guild-scheduled-event-object-guild-scheduled-event-entity-types
@discord_enum GuildScheduledEventEntityType begin
    STAGE_INSTANCE = 1
    VOICE = 2
    EXTERNAL = 3
end

# https://discord.com/developers/docs/resources/sticker#sticker-object-sticker-types
@discord_enum StickerType begin
    STANDARD = 1
    GUILD = 2
end

# https://discord.com/developers/docs/resources/sticker#sticker-object-sticker-format-types
@discord_enum StickerFormatType begin
    PNG = 1
    APNG = 2
    LOTTIE = 3
end

# https://discord.com/developers/docs/topics/teams#data-models-membership-state-enum
@discord_enum MembershipState begin
    INVITED = 1
    ACCEPTED = 2
end

# https://discord.com/developers/docs/resources/application#application-object-application-flags
@discord_enum ApplicationFlags begin
    GATEWAY_PRESENCE = 1 << 12
    GATEWAY_PRESENCE_LIMITED = 1 << 13
    GATEWAY_GUILD_MEMBERS = 1 << 14
    GATEWAY_GUILD_MEMBERS_LIMITED = 1 << 15
    VERIFICATION_PENDING_GUILD_LIMIT = 1 << 16
    EMBEDDED = 1 << 17
    GATEWAY_MESSAGE_CONTENT = 1 << 18
    GATEWAY_MESSAGE_CONTENT_LIMITED = 1 << 19
end or=true

# https://discord.com/developers/docs/resources/user#user-object-user-flags
@discord_enum UserFlags begin
    STAFF = 1 << 0
    PARTNER = 1 << 1
    HYPESQUAD = 1 << 2
    BUG_HUNTER_LEVEL_1 = 1 << 3
    HYPESQUAD_ONLINE_HOUSE_1 = 1 << 6
    HYPESQUAD_ONLINE_HOUSE_2 = 1 << 7
    HYPESQUAD_ONLINE_HOUSE_3 = 1 << 8
    PREMIUM_EARLY_SUPPORTER = 1 << 9
    TEAM_PSEUDO_USER = 1 << 10
    BUG_HUNTER_LEVEL_2 = 1 << 14
    VERIFIED_BOT = 1 << 16
    VERIFIED_DEVELOPER = 1 << 17
    CERTIFIED_MODERATOR = 1 << 18
    BOT_HTTP_INTERACTIONS = 1 << 19
end or=true

# https://discord.com/developers/docs/resources/channel#message-object-message-flags
@discord_enum MessageFlags begin
    CROSSPOSTED = 1 << 0
    IS_CROSSPOST = 1 << 1
    SUPPRESS_EMBEDS = 1 << 2
    SOURCE_MESSAGE_DELETED = 1 << 3
    URGENT = 1 << 4
    HAS_THREAD = 1 << 5
    EPHEMERAL = 1 << 6
    LOADING = 1 << 7
    FAILED_TO_MENTION_SOME_ROLES_IN_THREAD = 1 << 8
end or=true

# https://discord.com/developers/docs/resources/guild#guild-object-system-channel-flags
@discord_enum SystemChannelFlags begin
    SUPPRESS_JOIN_NOTIFICATIONS = 1 << 0
    SUPPRESS_PREMIUM_SUBSCRIPTIONS = 1 << 1
    SUPPRESS_GUILD_REMINDER_NOTIFICATIONS = 1 << 2
    SUPPRESS_JOIN_NOTIFICATION_REPLIES = 1 << 3
end or=true

# https://discord.com/developers/docs/topics/permissions#permissions-bitwise-permission-flags
@discord_enum PermissionBitmasks::Int64 begin
    CREATE_INSTANT_INVITE = 0x00000001
    KICK_MEMBERS = 0x00000002
    BAN_MEMBERS = 0x00000004
    ADMINISTRATOR = 0x00000008
    MANAGE_CHANNELS = 0x00000010
    MANAGE_GUILD = 0x00000020
    ADD_REACTIONS = 0x00000040
    VIEW_AUDIT_LOG = 0x00000080
    PRIORITY_SPEAKER = 0x00000100
    STREAM = 0x00000200
    VIEW_CHANNEL = 0x00000400
    SEND_MESSAGES = 0x00000800
    SEND_TTS_MESSAGES = 0x00001000
    MANAGE_MESSAGES = 0x00002000
    EMBED_LINKS = 0x00004000
    ATTACH_FILES = 0x00008000
    READ_MESSAGE_HISTORY = 0x00010000
    MENTION_EVERYONE = 0x00020000
    USE_EXTERNAL_EMOJIS = 0x00040000
    VIEW_GUILD_INSIGHTS = 0x00080000
    CONNECT = 0x00100000
    SPEAK = 0x00200000
    MUTE_MEMBERS = 0x00400000
    DEAFEN_MEMBERS = 0x00800000
    MOVE_MEMBERS = 0x01000000
    USE_VAD = 0x02000000
    CHANGE_NICKNAME = 0x04000000
    MANAGE_NICKNAMES = 0x08000000
    MANAGE_ROLES = 0x10000000
    MANAGE_WEBHOOKS = 0x20000000
    MANAGE_EMOJIS_AND_STICKERS = 0x40000000
    USE_APPLICATION_COMMANDS = 0x0000000080000000
    REQUEST_TO_SPEAK = 0x0000000100000000
    MANAGE_EVENTS = 0x0000000200000000
    MANAGE_THREADS = 0x0000000400000000
    CREATE_PUBLIC_THREADS = 0x0000000800000000
    CREATE_PRIVATE_THREADS = 0x0000001000000000
    USE_EXTERNAL_STICKERS = 0x0000002000000000
    SEND_MESSAGES_IN_THREADS = 0x0000004000000000
    USE_EMBEDDED_ACTIVITIES = 0x0000008000000000
    MODERATE_MEMBERS = 0x0000010000000000
end

# Gateway enums

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

# https://discord.com/developers/docs/topics/gateway#activity-object-activity-flags
@discord_enum GatewayActivityFlag begin
    INSTANCE = 1 << 0
    JOIN = 1 << 1
    SPECTATE = 1 << 2
    JOIN_REQUEST = 1 << 3
    SYNC = 1 << 4
    PLAY = 1 << 5
    PARTY_PRIVACY_FRIENDS = 1 << 6
    PARTY_PRIVACY_VOICE_CHANNEL = 1 << 7
    EMBEDDED = 1 << 8
end
