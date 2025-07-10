#!/bin/python3

from gi.repository import GLib,Gio

loop         = GLib.MainLoop()
bus          = Gio.bus_get_sync(Gio.BusType.SESSION,None)
unique_name  = bus.get_unique_name().replace(":","").replace(".","_")

def on__response(proxy,sender_name,signal_name,result):
    if signal_name == "Response":
        if result[0] == 0:
            print(result[1]["uri"])
        else:
            print("Failed")
    loop.quit()

def get_proxy(name,object_path,interface_name):
    proxy = Gio.DBusProxy.new_sync(bus,
                          Gio.DBusProxyFlags.NONE,
                          None,
                          name,
                          object_path,
                          interface_name,
                          None
                          )
    return proxy


proxy = get_proxy("org.freedesktop.portal.Desktop",
                  "/org/freedesktop/portal/desktop",
                  "org.freedesktop.portal.Screenshot"
                  )


options =  {
            "handle_token" : GLib.Variant("s",unique_name + "90"),
            "modal"        : GLib.Variant("b",False),
            "interactive"  : GLib.Variant("b",False),
            "uri"          : GLib.Variant("s","file:///home/yuceff28"),
            }

request_handler = proxy.call_sync("Screenshot",
                       GLib.Variant("(sa{sv})",("",options)),
                       Gio.DBusCallFlags.NONE,
                       -1,
                       None)[0]

handler_proxy = get_proxy("org.freedesktop.portal.Desktop",
                          request_handler,
                          "org.freedesktop.portal.Request"
                         )

handler_proxy.connect("g_signal",on__response)
loop.run()
