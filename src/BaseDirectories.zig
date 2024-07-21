const std = @import("std");
const Home = @import("Home.zig");

pub const SpecHomeDirectory = struct {
    environmentVariable: []const u8,
    defaultPath: []const u8,

    pub fn getPath(self: @This(), allocator: std.mem.Allocator) ![]const u8 {
        if (std.posix.getenv(self.environmentVariable)) |environmentValue| {
            return try allocator.dupe(u8, environmentValue);
        }

        const optionalHome = Home.getStaticPath();
        if (optionalHome) |home| {
            const arr = [2][]const u8{ home, self.defaultPath };
            return std.fs.path.join(allocator, &arr);
        } else {
            return error.HomeNotFound;
        }
    }
};

pub const DataHome = SpecHomeDirectory{ .environmentVariable = "XDG_DATA_HOME", .defaultPath = ".local/share" };
pub const ConfigHome = SpecHomeDirectory{ .environmentVariable = "XDG_CONFIG_HOME", .defaultPath = ".config" };
pub const StateHome = SpecHomeDirectory{ .environmentVariable = "XDG_STATE_HOME", .defaultPath = ".local/state" };
