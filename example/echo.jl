# NOTE: Make sure that DISCORD_BOT_TOKEN is already set in the environment.

using Discorder

port = 6000

bot = Bot()

# Register ,echo command
register_command_handler!(bot, CommandTrigger(r",echo (.*)")) do client, message, str
    @info "Echo handler" str
    create_message(
        client,
        message.channel_id;
        content="ok, you said: $str",
        message_reference=MessageReference(; message_id=message.id),
    )
end

start(bot, port)
