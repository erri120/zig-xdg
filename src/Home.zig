const std = @import("std");
const builtin = @import("builtin");

var buffer = [_]u8{0} ** 1024;
var staticPath: ?[]const u8 = null;
var once = std.once(setStaticValue);

fn setStaticValue() void {
    const slice = getPath() catch null;
    if (slice) |value| {
        if (value.len > buffer.len) {
            staticPath = null;
            return;
        }

        const dest = buffer[0..value.len];
        @memcpy(dest, value);
        staticPath = dest;
    } else {
        staticPath = null;
    }
}

/// Gets the path to the home directory. The returned slice points to
/// data in the global constant data section, which is initialized once.
///
/// This method returns `null` if,
///
/// 1) the slice returned by `getPath` exceeds the maximum, or
/// 2) `getPath` returned an error.
///
/// A sensible default you can use is `/` as it prevents non-root users
/// from writing data that is meant to be private.
///
/// This method is thread safe.
pub fn getStaticPath() ?[]const u8 {
    once.call();
    return staticPath;
}

/// Gets the path to the home directory. It's highly recommended to
/// use `std.mem.Allocator.dupe` on the return value, as it's not
/// guaranteed to be available for the entirety of the program.
///
/// This function uses the `$HOME` environment variable first.
///
/// If the variable is unavailable and you've linked with libc, it'll
/// use `getpwuid`.
///
/// A sensible default you can use is `/` as it prevents non-root users
/// from writing data that is meant to be private.
pub fn getPath() ![]const u8 {
    if (std.posix.getenv("HOME")) |homeEnvironmentValue| {
        return homeEnvironmentValue;
    }

    if (builtin.link_libc) {
        if (std.c.getpwuid(getuid())) |pw| {
            if (pw.pw_dir) |pwDir| {
                const slice = std.mem.sliceTo(pwDir, 0);
                return slice;
            } else {
                return error.NoDirInPasswd;
            }
        } else {
            return error.ErrorPasswd;
        }
    }

    return error.NoHomeVariableAndNoLibCAvailable;
}

extern "c" fn getuid() std.c.uid_t;
