const std = @import("std");
const xdg = @import("xdg");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    std.debug.print("home: {s}\n", .{xdg.Home.getStaticPath() orelse "/"});
    try print(allocator, xdg.BaseDirectory.DataHome);
    try print(allocator, xdg.BaseDirectory.ConfigHome);
    try print(allocator, xdg.BaseDirectory.StateHome);
}

fn print(allocator: std.mem.Allocator, dir: xdg.BaseDirectory.SpecHomeDirectory) !void {
    const path = try dir.getPath(allocator);
    defer allocator.free(path);

    std.debug.print("{s} = {s}\n", .{ dir.environmentVariable, path });
}
