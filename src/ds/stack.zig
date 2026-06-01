const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = @import("array_list.zig").ArrayList;

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        stack: ArrayList(T),

        pub fn init(allocator: Allocator) Self {
            return .{
                .stack = ArrayList(T).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.stack.deinit();
        }

        pub fn push(self: *Self, value: T) !void {
            try self.stack.push(value);
        }

        pub fn pop(self: *Self) ?T {
            return self.stack.pop();
        }

        pub fn peek(self: *const Self) ?T {
            return self.stack.peek();
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.stack.isEmpty();
        }

        pub fn size(self: *const Self) usize {
            return self.stack.size();
        }

        pub fn clear(self: *Self) void {
            self.stack.clear();
        }
    };
}
