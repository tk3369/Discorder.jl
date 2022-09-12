# NOTE: Make sure that DISCORD_BOT_TOKEN is already set in the environment.

using Discorder

# Start a new gateway
tracker_ref = Ref{Discorder.GatewayTracker}()
@async Discorder.run(; tracker_ref, config_file_path = "etc/dev.toml")

# Make sure that events are published
Discorder.add_event_publisher(tracker_ref[], Discorder.ZMQPublisher(6000))

# Create bot
bot = SimpleBot()

# Register ,echo command
register!(bot, CommandTrigger(',', r"echo ")) do client, message
    msg = strip(message.content[6:end])
    @info "message content = $msg"
    create_message(client, message.channel_id; content = "$msg")
end

# Register reaction add handler
register!(bot, ReactionAddTrigger()) do client, reaction_add_event
    @info "reaction event " reaction_add_event.emoji
end

# Run bot event loop
play(bot; port = 6000)
