const std = @import("std");
// const Stack = @import("ds/stack.zig").Stack;
// const Queue = @import("ds/queue.zig").Queue;
// const CircularQueue = @import("ds/circular_queue.zig").CircularQueue;
const LinkedList = @import("ds/linked_list.zig").LinkedList;

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var list = LinkedList(i32).init(allocator);
    defer list.deinit();

    try list.prepend(4);
    try list.prepend(8);
    try list.prepend(3);

    // try list.append(31);
    // try list.append(12);
    // try list.append(365);

    // try list.prepend(-87);

    // if (list.popFront()) |popped| {
    //     std.debug.print("Popped: {}\n", .{popped});
    // }

    // _ = list.popBack();

    list.reverse();

    var temp_node = list.head;

    while (temp_node) |ptr| {
        std.debug.print("{}->", .{ptr.value});
        temp_node = ptr.next;
    }

    std.debug.print("null", .{});
}
