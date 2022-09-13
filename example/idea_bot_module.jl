# Module based bot idea.

using Discorder

bot = Bot()

@message_create r",echo (.*)" function echo(client, message, matched)
    @info "echo content = $matched"
    return create_message(client, message.channel_id; content="$matched")
end bot

@reaction_add r"([😄,😸])" function smile(client, emoji, matched)
    @info "got smiley = $matched"
end bot

serve(bot, 6000; config_file_path="etc/dev.toml")
