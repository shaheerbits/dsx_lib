const std = @import("std");
const Stack = @import("ds/stack.zig").Stack;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var stack: Stack(i32) = .init(allocator);
    defer stack.deinit();

    try stack.push(9);
    try stack.push(2);
    try stack.push(5);

    while (stack.pop()) |item| {
        std.debug.print("Popping: {}\n", .{item});
    }

    std.debug.print("Is Empty: {}\n", .{stack.isEmpty()});
}
