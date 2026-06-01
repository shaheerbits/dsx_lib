const std = @import("std");
// const Stack = @import("ds/stack.zig").Stack;
// const Queue = @import("ds/queue.zig").Queue;
const CircularQueue = @import("ds/circular_queue.zig").CircularQueue;

pub fn main() !void {
    // var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();

    // const allocator = gpa.allocator();

    var queue = CircularQueue(i32, 3).init();

    try queue.enqueue(9);
    try queue.enqueue(2);
    try queue.enqueue(8);

    _ = queue.dequeue();

    try queue.enqueue(7);

    std.debug.print("Front: {}\nRear: {}\nLen: {}\n", .{ queue.front, queue.rear, queue.len });
}
