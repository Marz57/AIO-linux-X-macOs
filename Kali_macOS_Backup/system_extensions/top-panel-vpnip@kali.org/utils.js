import GLib from 'gi://GLib';
import Gio from 'gi://Gio';

Gio._promisify(Gio.Subprocess.prototype, 'communicate_utf8_async');

export const getVpnIp = async () => {
    const ipCommand = ['sh', '-c', 'ip a show "$(ip tuntap show | cut -d : -f1 | head -n 1)"'];
    const ipProc = new Gio.Subprocess({
        argv: ipCommand,
        flags: Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE,
    });
    ipProc.init(null);

    let [ipOutput] = await ipProc.communicate_utf8_async(null, null);
    return (ipOutput.match(/(?<=inet )\d{1,3}(\.\d{1,3}){3}/) || [])[0];
};
