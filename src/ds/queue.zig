const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = @import("array_list.zig").ArrayList;

pub fn Queue(comptime T: type) type {
    return struct {
        const Self = @This();

        list: ArrayList(T),

        pub fn init(allocator: Allocator) Self {
            return .{
                .list = ArrayList(T).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.list.deinit();
        }

        pub fn enqueue(self: *Self, value: T) !void {
            try self.list.push(value);
        }

        pub fn dequeue(self: *Self) ?T {
            return self.list.remove(0) catch null;
        }

        pub fn peek(self: *const Self) ?T {
            return self.list.get(0);
        }

        pub fn size(self: *const Self) usize {
            return self.list.size();
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.list.isEmpty();
        }

        pub fn clear(self: *Self) void {
            self.list.clear();
        }
    };
}
