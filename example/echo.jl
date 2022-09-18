# NOTE: Make sure that DISCORD_BOT_TOKEN is already set in the environment.

using Discorder

port = 6000

bot = Bot()

# Register ,echo command
register!(bot, CommandTrigger(r",echo (.*)")) do client, message, str
    @info "Echo handler" str
    create_message(client, message.channel_id;
        content="ok, you said: $str",
        message_reference=MessageReference(message_id=message.id)
    )
end

register!(bot, CommandTrigger(r",bye-echo")) do client, message
    create_message(client, message.channel_id; content="ok, bot is exiting...")
    return BotExit()
end

start(bot, port)
