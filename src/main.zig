const std = @import("std");
const ArrayList = @import("ds/array_list.zig").ArrayList;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var list = ArrayList(i32).init(allocator);
    defer list.deinit();

    try list.push(32);
    try list.push(17);
    try list.push(25);
    try list.insert(3, 90);
    try list.insert(3, 71);

    _ = try list.remove(0);
    _ = try list.remove(3);

    for (list.iter(), 1..) |x, i| {
        std.debug.print("{}. {}\n", .{ i, x });
    }

    std.debug.print("Contains 17 - {}\n", .{list.contains(17)});
}
