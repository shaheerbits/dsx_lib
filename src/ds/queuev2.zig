const std = @import("std");
const Allocator = std.mem.Allocator;
const LinkedList = @import("linked_list.zig").LinkedList;

pub fn Queue(comptime T: type) type {
    return struct {
        const Self = @This();

        list: LinkedList(T),

        pub fn init(allocator: Allocator) Self {
            return .{ .list = LinkedList(T).init(allocator) };
        }

        pub fn deinit(self: *Self) void {
            self.list.deinit();
        }

        pub fn enqueue(self: *Self, value: T) !void {
            try self.list.append(value);
        }

        pub fn dequeue(self: *Self) ?T {
            return self.list.popFront();
        }

        pub fn peek(self: *const Self) ?T {
            return self.list.headValue();
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.list.isEmpty();
        }

        pub fn size(self: *const Self) usize {
            return self.list.size();
        }

        pub fn clear(self: *Self) void {
            self.list.clear();
        }
    };
}

test "enqueue increments the size" {
    const allocator = std.testing.allocator;

    var queue = Queue(i32).init(allocator);
    defer queue.deinit();

    try queue.enqueue(101);
    try queue.enqueue(102);
    try queue.enqueue(104);
    try queue.enqueue(108);

    try std.testing.expect(queue.size() == 4);
}

test "isEmpty works as expected" {
    const allocator = std.testing.allocator;

    var queue = Queue(i32).init(allocator);
    defer queue.deinit();

    try std.testing.expect(queue.isEmpty());

    try queue.enqueue(95);

    try std.testing.expect(!queue.isEmpty());
}

test "clear clears the whole queue" {
    const allocator = std.testing.allocator;

    var queue = Queue(i32).init(allocator);
    defer queue.deinit();

    try queue.enqueue(101);
    try queue.enqueue(102);
    try queue.enqueue(104);
    try queue.enqueue(108);

    try std.testing.expect(!queue.isEmpty());

    queue.clear();

    try std.testing.expect(queue.isEmpty());
}

test "dequeue decrements the size" {
    const allocator = std.testing.allocator;

    var queue = Queue(i32).init(allocator);
    defer queue.deinit();

    try queue.enqueue(101);
    try queue.enqueue(102);
    try queue.enqueue(104);

    _ = queue.dequeue();

    try std.testing.expect(queue.size() == 2);
}

test "peek returns the first element" {
    const allocator = std.testing.allocator;

    var languages = Queue([]const u8).init(allocator);
    defer languages.deinit();

    try languages.enqueue("C++");
    try languages.enqueue("Python");
    try languages.enqueue("Perl");
    try languages.enqueue("Zig");

    try std.testing.expectEqual("C++", languages.peek());
}

test "peek returns null if queue is empty" {
    const allocator = std.testing.allocator;

    var queue = Queue(i8).init(allocator);
    defer queue.deinit();

    try std.testing.expectEqual(null, queue.peek());
}

test "queue follows FIFO order" {
    const allocator = std.testing.allocator;

    var queue = Queue(i32).init(allocator);
    defer queue.deinit();

    try queue.enqueue(10);
    try queue.enqueue(20);
    try queue.enqueue(30);

    try std.testing.expectEqual(10, queue.dequeue());
    try std.testing.expectEqual(20, queue.dequeue());
    try std.testing.expectEqual(30, queue.dequeue());
}
