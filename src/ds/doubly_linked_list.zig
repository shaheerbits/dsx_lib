const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn DoublyLinkedList(comptime T: type) type {
    return struct {
        const Node = struct {
            value: T,
            next: ?*Node,
            prev: ?*Node,
        };

        const Self = @This();

        head: ?*Node,
        tail: ?*Node,
        len: usize,
        allocator: Allocator,

        pub fn init(allocator: Allocator) Self {
            return .{
                .head = null,
                .tail = null,
                .len = 0,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.clear();
        }

        pub fn append(self: *Self, value: T) !void {
            const new_node = try self.allocator.create(Node);
            new_node.* = .{ .value = value, .next = null, .prev = self.tail };

            if (self.head == null) {
                self.head = new_node;
            } else {
                self.tail.?.next = new_node;
            }

            self.tail = new_node;
            self.len += 1;
        }

        pub fn prepend(self: *Self, value: T) !void {
            const new_node = try self.allocator.create(Node);
            new_node.* = .{ .value = value, .next = self.head, .prev = null };

            if (self.tail == null) self.tail = new_node;
            if (self.head) |head| head.prev = new_node;

            self.head = new_node;
            self.len += 1;
        }

        pub fn popFront(self: *Self) ?T {
            if (self.head) |temp| {
                const new_head = temp.next;
                const value = temp.value;

                self.allocator.destroy(temp);

                self.head = new_head;
                self.len -= 1;

                if (self.head) |head| {
                    head.prev = null;
                } else {
                    self.tail = null;
                }

                return value;
            } else {
                return null;
            }
        }

        pub fn popBack(self: *Self) ?T {
            if (self.tail) |temp| {
                const new_tail = temp.prev;
                const value = temp.value;

                self.allocator.destroy(temp);

                self.tail = new_tail;
                self.len -= 1;

                if (self.tail) |tail| {
                    tail.next = null;
                } else {
                    self.head = null;
                }

                return value;
            } else {
                return null;
            }
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.len == 0;
        }

        pub fn size(self: *const Self) usize {
            return self.len;
        }

        pub fn clear(self: *Self) void {
            var temp = self.head;

            while (temp) |node| {
                const next = node.next;
                self.allocator.destroy(node);
                temp = next;
            }

            self.head = null;
            self.tail = null;
            self.len = 0;
        }

        pub fn contains(self: *const Self, value: T) bool {
            if (self.head == null) return false;

            var temp = self.head;

            while (temp) |node| {
                if (std.meta.eql(node.value, value)) return true;
                temp = node.next;
            }

            return false;
        }

        pub fn find(self: *const Self, value: T) ?usize {
            if (self.head == null) return null;

            var temp = self.head;
            var index = @as(usize, 0);

            while (temp) |node| {
                if (std.meta.eql(node.value, value)) return index;
                temp = node.next;
                index += 1;
            }

            return null;
        }

        pub fn first(self: *const Self) ?T {
            return if (self.head) |head| head.value else null;
        }

        pub fn last(self: *const Self) ?T {
            return if (self.tail) |tail| tail.value else null;
        }
    };
}

test "appending elements to the list changes head and tail pointers" {
    const allocator = std.testing.allocator;

    var dll = DoublyLinkedList(i32).init(allocator);
    defer dll.deinit();

    try dll.append(45);
    if (dll.head) |head| try std.testing.expectEqual(head.value, 45);
    if (dll.tail) |tail| try std.testing.expectEqual(tail.value, 45);

    try dll.append(95);
    if (dll.head) |head| try std.testing.expectEqual(head.value, 45);
    if (dll.tail) |tail| try std.testing.expectEqual(tail.value, 95);

    try dll.append(50);
    if (dll.head) |head| try std.testing.expectEqual(head.value, 45);
    if (dll.tail) |tail| try std.testing.expectEqual(tail.value, 50);
}

test "appending elements to the list changes the len property" {
    const allocator = std.testing.allocator;

    var dll = DoublyLinkedList(i32).init(allocator);
    defer dll.deinit();

    try dll.append(5);
    try dll.append(-8);
    try dll.append(20);

    try std.testing.expectEqual(@as(usize, 3), dll.len);
}

test "popFront pops the first element and changes the head" {
    const allocator = std.testing.allocator;

    var dll = DoublyLinkedList(i32).init(allocator);
    defer dll.deinit();

    try dll.append(5);
    try dll.append(-8);
    try dll.append(20);

    if (dll.popFront()) |value| {
        try std.testing.expectEqual(value, 5);
        try std.testing.expectEqual(@as(usize, dll.len), 2);
    }

    if (dll.head) |head| {
        try std.testing.expectEqual(head.value, -8);
    }
}

test "popBack pops the last element and changes the tail" {
    const allocator = std.testing.allocator;

    var dll = DoublyLinkedList(i32).init(allocator);
    defer dll.deinit();

    try dll.append(5);
    try dll.append(-8);
    try dll.append(20);

    if (dll.popBack()) |value| {
        try std.testing.expectEqual(value, 20);
        try std.testing.expectEqual(@as(usize, dll.len), 2);
    }

    if (dll.tail) |tail| {
        try std.testing.expectEqual(tail.value, -8);
    }
}

test "append increases size" {
    const allocator = std.testing.allocator;

    var list = DoublyLinkedList(i32).init(allocator);
    defer list.deinit();

    try list.append(10);
    try list.append(20);
    try list.append(30);

    try std.testing.expectEqual(@as(usize, 3), list.size());
}

test "prepend increases size" {
    const allocator = std.testing.allocator;

    var list = DoublyLinkedList(i32).init(allocator);
    defer list.deinit();

    try list.prepend(10);
    try list.prepend(20);

    try std.testing.expectEqual(@as(usize, 2), list.size());
}

test "append preserves correct head and tail" {
    const allocator = std.testing.allocator;

    var list = DoublyLinkedList(i32).init(allocator);
    defer list.deinit();

    try list.append(10);
    try list.append(20);
    try list.append(30);

    try std.testing.expectEqual(@as(?i32, 10), list.first());
    try std.testing.expectEqual(@as(?i32, 30), list.last());
}

test "prepend preserves correct head and tail" {
    const allocator = std.testing.allocator;

    var list = DoublyLinkedList(i32).init(allocator);
    defer list.deinit();

    try list.prepend(10);
    try list.prepend(20);
    try list.prepend(30);

    try std.testing.expectEqual(@as(?i32, 30), list.first());
    try std.testing.expectEqual(@as(?i32, 10), list.last());
}

test "popFront removes first element" {
    const allocator = std.testing.allocator;

    var list = DoublyLinkedList(i32).init(allocator);
    defer list.deinit();

    try list.append(10);
    try list.append(20);
    try list.append(30);

    const popped = list.popFront();

    try std.testing.expectEqual(@as(?i32, 10), popped);
    try std.testing.expectEqual(@as(?i32, 20), list.first());
    try std.testing.expectEqual(@as(usize, 2), list.size());
}

test "popBack removes last element" {
    const allocator = std.testing.allocator;

    var list = DoublyLinkedList(i32).init(allocator);
    defer list.deinit();

    try list.append(10);
    try list.append(20);
    try list.append(30);

    const popped = list.popBack();

    try std.testing.expectEqual(@as(?i32, 30), popped);
    try std.testing.expectEqual(@as(?i32, 20), list.last());
    try std.testing.expectEqual(@as(usize, 2), list.size());
}

test "popFront returns null for empty list" {
    const allocator = std.testing.allocator;

    var list = DoublyLinkedList(i32).init(allocator);
    defer list.deinit();

    try std.testing.expectEqual(@as(?i32, null), list.popFront());
}

test "popBack returns null for empty list" {
    const allocator = std.testing.allocator;

    var list = DoublyLinkedList(i32).init(allocator);
    defer list.deinit();

    try std.testing.expectEqual(@as(?i32, null), list.popBack());
}

test "contains finds existing values" {
    const allocator = std.testing.allocator;

    var list = DoublyLinkedList(i32).init(allocator);
    defer list.deinit();

    try list.append(10);
    try list.append(20);
    try list.append(30);

    try std.testing.expect(list.contains(20));
    try std.testing.expect(!list.contains(100));
}

test "find returns correct index" {
    const allocator = std.testing.allocator;

    var list = DoublyLinkedList(i32).init(allocator);
    defer list.deinit();

    try list.append(10);
    try list.append(20);
    try list.append(30);

    try std.testing.expectEqual(@as(?usize, 0), list.find(10));
    try std.testing.expectEqual(@as(?usize, 1), list.find(20));
    try std.testing.expectEqual(@as(?usize, 2), list.find(30));
}

test "find returns null when value not found" {
    const allocator = std.testing.allocator;

    var list = DoublyLinkedList(i32).init(allocator);
    defer list.deinit();

    try list.append(10);
    try list.append(20);

    try std.testing.expectEqual(@as(?usize, null), list.find(999));
}

test "clear removes all elements" {
    const allocator = std.testing.allocator;

    var list = DoublyLinkedList(i32).init(allocator);
    defer list.deinit();

    try list.append(10);
    try list.append(20);
    try list.append(30);

    list.clear();

    try std.testing.expect(list.isEmpty());
    try std.testing.expectEqual(@as(usize, 0), list.size());
    try std.testing.expectEqual(@as(?i32, null), list.first());
    try std.testing.expectEqual(@as(?i32, null), list.last());
}

test "isEmpty works correctly" {
    const allocator = std.testing.allocator;

    var list = DoublyLinkedList(i32).init(allocator);
    defer list.deinit();

    try std.testing.expect(list.isEmpty());

    try list.append(10);

    try std.testing.expect(!list.isEmpty());
}

test "single element popFront resets head and tail" {
    const allocator = std.testing.allocator;

    var list = DoublyLinkedList(i32).init(allocator);
    defer list.deinit();

    try list.append(42);

    _ = list.popFront();

    try std.testing.expect(list.isEmpty());
    try std.testing.expectEqual(@as(?i32, null), list.first());
    try std.testing.expectEqual(@as(?i32, null), list.last());
}

test "single element popBack resets head and tail" {
    const allocator = std.testing.allocator;

    var list = DoublyLinkedList(i32).init(allocator);
    defer list.deinit();

    try list.append(42);

    _ = list.popBack();

    try std.testing.expect(list.isEmpty());
    try std.testing.expectEqual(@as(?i32, null), list.first());
    try std.testing.expectEqual(@as(?i32, null), list.last());
}
