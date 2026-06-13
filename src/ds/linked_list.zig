const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn LinkedList(comptime T: type) type {
    return struct {
        pub const Node = struct {
            value: T,
            next: ?*Node,
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
            var head = self.head;

            while (head) |temp| {
                const next = temp.next;
                self.allocator.destroy(temp);
                head = next;
            }

            self.head = null;
            self.tail = null;
            self.len = 0;
        }

        pub fn append(self: *Self, value: T) !void {
            const new_node = try self.allocator.create(Node);

            new_node.* = Node{
                .value = value,
                .next = null,
            };

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

            new_node.* = Node{
                .value = value,
                .next = self.head,
            };

            if (self.head == null) {
                self.tail = new_node;
            }

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

                if (self.len == 0) {
                    self.tail = null;
                }

                return value;
            } else {
                return null;
            }
        }

        pub fn popBack(self: *Self) ?T {
            if (self.head == null) return null;

            var curr = self.head.?;
            var prev: ?*Node = null;

            while (curr.next) |next| {
                prev = curr;
                curr = next;
            }

            self.len -= 1;
            self.tail = prev;

            if (prev) |temp| {
                const popped = temp.next.?.value;
                self.allocator.destroy(temp.next.?);
                prev.?.next = null;
                return popped;
            }

            const popped = curr.value;
            self.allocator.destroy(curr);
            self.head = null;
            return popped;
        }

        pub fn contains(self: *const Self, value: T) bool {
            if (self.head == null) return false;

            var temp = self.head;

            while (temp) |node| {
                if (std.meta.eql(node.value, value)) {
                    return true;
                }

                temp = node.next;
            }

            return false;
        }

        pub fn find(self: *const Self, value: T) ?usize {
            if (self.head == null) return null;

            var index: usize = 0;
            var temp = self.head;

            while (temp) |node| {
                if (std.meta.eql(node.value, value)) {
                    return index;
                }

                temp = node.next;
                index += 1;
            }

            return null;
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.len == 0;
        }

        pub fn clear(self: *Self) void {
            var head = self.head;

            while (head) |temp| {
                const next = temp.next;
                self.allocator.destroy(temp);
                head = next;
            }

            self.head = null;
            self.tail = null;
            self.len = 0;
        }

        pub fn size(self: *const Self) usize {
            return self.len;
        }

        pub fn reverse(self: *Self) void {
            if (self.len < 2) return;

            var prev: ?*Node = null;
            var curr = self.head;
            var next: ?*Node = null;

            self.tail = curr;

            while (curr) |curr_node| {
                next = curr_node.next;
                curr_node.next = prev;
                prev = curr_node;
                curr = next;
            }

            self.head = prev;
        }

        pub fn headValue(self: *const Self) ?T {
            if (self.head) |head| return head.value;
            return null;
        }

        pub fn tailValue(self: *const Self) ?T {
            if (self.tail) |tail| return tail.value;
            return null;
        }
    };
}
