#!/usr/bin/env python3

from pyln.client import Plugin

plugin = Plugin()

@plugin.method("checkmymanifest", http_path="/some/path", http_method="POST")
def return_this_manifest(plugin):
    """Return the manifest for the checkhttpdata command"""

    help_data = plugin.rpc.help().get("help")
    # return help_data
    manifest = None
    for cmd in help_data:
        name = cmd.get("command")
        plugin.log("Checking command: {}".format(name))
        if "checkmymanifest" in name:
            plugin.log("Found checkhttpdata command in help data: {}".format(cmd));
            manifest = cmd
    return manifest


plugin.run()
