const std = @import("std");

pub fn CircularQueue(comptime T: type, comptime capacity: usize) type {
    if (capacity == 0)
        @compileError(
            "Capacity must be greater than (>) 0.",
        );

    return struct {
        const Self = @This();

        items: [capacity]T,
        front: usize,
        rear: usize,
        len: usize,

        pub fn init() Self {
            return .{
                .items = [_]T{undefined} ** capacity,
                .front = 0,
                .rear = 0,
                .len = 0,
            };
        }

        pub fn enqueue(self: *Self, value: T) !void {
            if (self.len == capacity) return error.QueueFull;

            self.items[self.rear] = value;
            self.rear = (self.rear + 1) % capacity;
            self.len += 1;
        }

        pub fn dequeue(self: *Self) ?T {
            if (self.len == 0) return null;

            const value = self.items[self.front];
            self.items[self.front] = undefined;

            self.front = (self.front + 1) % capacity;
            self.len -= 1;

            return value;
        }

        pub fn peek(self: *const Self) ?T {
            if (self.len == 0) return null;
            return self.items[self.front];
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.size() == 0;
        }

        pub fn size(self: *const Self) usize {
            return self.len;
        }
    };
}
