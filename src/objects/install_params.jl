# https://discord.com/developers/docs/resources/application#install-params-object-install-params-structure
@discord_object struct InstallParams
    scopes::Vector{String}
    permissions::Permissions
end
