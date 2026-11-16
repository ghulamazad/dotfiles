#!/usr/bin/env python3
"""Bluetooth pairing agent for the Quickshell shell (org.bluez.Agent1).

BlueZ asks an "agent" to confirm a passkey, supply a PIN, or authorize a
connection. Quickshell cannot own a D-Bus service itself, so this small helper
does, and talks to the shell over stdin/stdout, one JSON object per line.

  to the shell (stdout):
    {"event":"ready"}
    {"event":"request","id":N,"kind":"confirm|pin|passkey|authorize|service",
     "name":"...","address":"AA:BB:..","code":"123456"|null,"uuid":"..."|null}
    {"event":"display","kind":"pin|passkey","name":"..","address":"..","code":".."}
    {"event":"cancel"}
    {"event":"error","message":"..."}
  from the shell (stdin):
    {"id":N,"accept":true|false,"value":"1234"}      (value only for pin/passkey)

Security: PINs travel only over this pipe, never on a command line, and are not
logged. Everything the shell sends is re-validated here. A request nobody
answers within TIMEOUT_S seconds is rejected. A device is marked trusted only
after YOU accepted its pairing request.

Exit codes: 3 = python-dbus / python-gobject missing, 4 = BlueZ not reachable.
"""
import json
import os
import re
import sys

try:
    import dbus
    import dbus.mainloop.glib
    import dbus.service
    from gi.repository import GLib
except ImportError as exc:  # pragma: no cover
    print(f"bt-agent.py: missing python module ({exc}). "
          "Install: sudo pacman -S python-dbus python-gobject", file=sys.stderr)
    sys.exit(3)

BUS_NAME = "org.bluez"
AGENT_IFACE = "org.bluez.Agent1"
MANAGER_IFACE = "org.bluez.AgentManager1"
DEVICE_IFACE = "org.bluez.Device1"
AGENT_PATH = "/dev/dotfiles/agent"
CAPABILITY = "KeyboardDisplay"
TIMEOUT_S = 50
DEVICE_PATH_RE = re.compile(r"^/org/bluez/hci[0-9]+/dev_[0-9A-Fa-f]{2}(_[0-9A-Fa-f]{2}){5}$")


class Rejected(dbus.DBusException):
    _dbus_error_name = "org.bluez.Error.Rejected"


class Canceled(dbus.DBusException):
    _dbus_error_name = "org.bluez.Error.Canceled"


def emit(obj):
    sys.stdout.write(json.dumps(obj) + "\n")
    sys.stdout.flush()


class Agent(dbus.service.Object):
    def __init__(self, bus):
        super().__init__(bus, AGENT_PATH)
        self.bus = bus
        self.next_id = 1
        self.pending = {}   # id -> dict(kind, device, reply, error, timer)

    # ---- helpers ---------------------------------------------------------
    def device_info(self, path):
        path = str(path)
        if not DEVICE_PATH_RE.match(path):
            raise Rejected("unexpected device path")
        try:
            props = dbus.Interface(self.bus.get_object(BUS_NAME, path),
                                   "org.freedesktop.DBus.Properties")
            name = str(props.Get(DEVICE_IFACE, "Alias"))
            address = str(props.Get(DEVICE_IFACE, "Address"))
        except dbus.DBusException:
            name, address = "Unknown device", ""
        return name, address

    def trust(self, path):
        try:
            props = dbus.Interface(self.bus.get_object(BUS_NAME, str(path)),
                                   "org.freedesktop.DBus.Properties")
            props.Set(DEVICE_IFACE, "Trusted", dbus.Boolean(True))
        except dbus.DBusException:
            pass

    def ask(self, kind, path, reply, error, code=None, uuid=None):
        name, address = self.device_info(path)
        rid = self.next_id
        self.next_id += 1
        timer = GLib.timeout_add_seconds(TIMEOUT_S, self.expire, rid)
        self.pending[rid] = dict(kind=kind, path=path, reply=reply, error=error, timer=timer)
        emit({"event": "request", "id": rid, "kind": kind, "name": name,
              "address": address, "code": code, "uuid": uuid})

    def expire(self, rid):
        item = self.pending.pop(rid, None)
        if item:
            item["error"](Rejected("timed out"))
            emit({"event": "cancel"})
        return False

    def answer(self, rid, accept, value):
        item = self.pending.pop(rid, None)
        if item is None:
            return
        GLib.source_remove(item["timer"])
        kind = item["kind"]
        if not accept:
            item["error"](Rejected("rejected by user"))
            return
        try:
            if kind == "pin":
                pin = str(value)
                if not (1 <= len(pin) <= 16) or not pin.isprintable() or " " in pin:
                    raise ValueError("bad PIN")
                self.trust(item["path"])
                item["reply"](pin)
            elif kind == "passkey":
                if not re.fullmatch(r"[0-9]{1,6}", str(value)):
                    raise ValueError("bad passkey")
                self.trust(item["path"])
                item["reply"](dbus.UInt32(int(value)))
            elif kind in ("confirm", "authorize"):
                self.trust(item["path"])
                item["reply"]()
            else:   # service
                item["reply"]()
        except ValueError:
            item["error"](Rejected("invalid input"))

    # ---- org.bluez.Agent1 ------------------------------------------------
    @dbus.service.method(AGENT_IFACE, in_signature="", out_signature="")
    def Release(self):
        pass

    @dbus.service.method(AGENT_IFACE, in_signature="os", out_signature="",
                         async_callbacks=("reply", "error"))
    def AuthorizeService(self, device, uuid, reply, error):
        self.ask("service", device, reply, error, uuid=str(uuid))

    @dbus.service.method(AGENT_IFACE, in_signature="o", out_signature="s",
                         async_callbacks=("reply", "error"))
    def RequestPinCode(self, device, reply, error):
        self.ask("pin", device, reply, error)

    @dbus.service.method(AGENT_IFACE, in_signature="o", out_signature="u",
                         async_callbacks=("reply", "error"))
    def RequestPasskey(self, device, reply, error):
        self.ask("passkey", device, reply, error)

    @dbus.service.method(AGENT_IFACE, in_signature="ouq", out_signature="")
    def DisplayPasskey(self, device, passkey, entered):
        name, address = self.device_info(device)
        emit({"event": "display", "kind": "passkey", "name": name,
              "address": address, "code": "%06u" % int(passkey)})

    @dbus.service.method(AGENT_IFACE, in_signature="os", out_signature="")
    def DisplayPinCode(self, device, pincode):
        name, address = self.device_info(device)
        emit({"event": "display", "kind": "pin", "name": name,
              "address": address, "code": str(pincode)})

    @dbus.service.method(AGENT_IFACE, in_signature="ou", out_signature="",
                         async_callbacks=("reply", "error"))
    def RequestConfirmation(self, device, passkey, reply, error):
        self.ask("confirm", device, reply, error, code="%06u" % int(passkey))

    @dbus.service.method(AGENT_IFACE, in_signature="o", out_signature="",
                         async_callbacks=("reply", "error"))
    def RequestAuthorization(self, device, reply, error):
        self.ask("authorize", device, reply, error)

    @dbus.service.method(AGENT_IFACE, in_signature="", out_signature="")
    def Cancel(self):
        for rid, item in list(self.pending.items()):
            GLib.source_remove(item["timer"])
            item["error"](Canceled("canceled"))
            del self.pending[rid]
        emit({"event": "cancel"})


def main():
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    loop = GLib.MainLoop()
    try:
        bus = dbus.SystemBus()
        agent = Agent(bus)
        manager = dbus.Interface(bus.get_object(BUS_NAME, "/org/bluez"), MANAGER_IFACE)
        manager.RegisterAgent(AGENT_PATH, CAPABILITY)
        manager.RequestDefaultAgent(AGENT_PATH)
    except dbus.DBusException as exc:
        emit({"event": "error", "message": f"BlueZ not reachable: {exc.get_dbus_message()}"})
        print("bt-agent.py: BlueZ not reachable (is bluetooth.service running?)", file=sys.stderr)
        sys.exit(4)

    inbuf = bytearray()

    def on_stdin(fd, condition):
        # Read the raw fd (not sys.stdin): Python's own buffering could hold a
        # second line that GLib never reports as readable.
        if condition & GLib.IO_IN:
            chunk = os.read(fd, 4096)
            if not chunk:
                loop.quit()
                return False
            inbuf.extend(chunk)
            while b"\n" in inbuf:
                raw, _, rest = bytes(inbuf).partition(b"\n")
                inbuf[:] = rest
                try:
                    msg = json.loads(raw.decode("utf-8", "replace"))
                    agent.answer(int(msg["id"]), bool(msg.get("accept")), msg.get("value", ""))
                except (ValueError, KeyError, TypeError):
                    pass            # ignore malformed lines
            return True
        loop.quit()                 # HUP / ERR: the shell is gone
        return False

    GLib.io_add_watch(sys.stdin.fileno(), GLib.IO_IN | GLib.IO_HUP | GLib.IO_ERR, on_stdin)
    emit({"event": "ready"})
    try:
        loop.run()
    finally:
        try:
            manager.UnregisterAgent(AGENT_PATH)
        except dbus.DBusException:
            pass


if __name__ == "__main__":
    main()
