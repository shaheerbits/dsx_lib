const std = @import("std");
// const ArrayList = @import("ds/array_list.zig").ArrayList;
// const Stack = @import("ds/stack.zig").Stack;
// const Queue = @import("ds/queue.zig").Queue;
// const CircularQueue = @import("ds/circular_queue.zig").CircularQueue;
// const LinkedList = @import("ds/linked_list.zig").LinkedList;
// const Queue = @import("ds/queuev2.zig").Queue;
// const BinarySearchTree = @import("ds/binary_search_tree.zig").BinarySearchTree;
const DoublyLinkedList = @import("ds/doubly_linked_list.zig").DoublyLinkedList;

pub fn main() !void {
    var debugAllocator = std.heap.DebugAllocator(.{}).init;
    defer _ = debugAllocator.deinit();

    const allocator = debugAllocator.allocator();

    var doubly = DoublyLinkedList(i32).init(allocator);
    defer doubly.deinit();

    try doubly.append(32);
    try doubly.append(18);
    try doubly.insertAt(0, 3);
    try doubly.insertAt(0, 9);

    if (doubly.removeAt(3)) |value| {
        std.debug.print("Removed: {}\n", .{value});
    }

    var temp = doubly.head;

    while (temp) |node| {
        std.debug.print("{}->", .{node.value});
        temp = node.next;
    }

    std.debug.print("null\n", .{});
}
