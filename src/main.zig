const std = @import("std");
// const ArrayList = @import("ds/array_list.zig").ArrayList;
// const Stack = @import("ds/stack.zig").Stack;
// const Queue = @import("ds/queue.zig").Queue;
// const CircularQueue = @import("ds/circular_queue.zig").CircularQueue;
// const LinkedList = @import("ds/linked_list.zig").LinkedList;
// const QueueV2 = @import("ds/queuev2.zig").Queue;
// const BinarySearchTree = @import("ds/binary_search_tree.zig").BinarySearchTree;
// const DoublyLinkedList = @import("ds/doubly_linked_list.zig").DoublyLinkedList;
const HashMap = @import("ds/hashmap.zig").HashMap;

pub fn main() !void {
    var debugAllocator = std.heap.DebugAllocator(.{}).init;
    defer _ = debugAllocator.deinit();

    const allocator = debugAllocator.allocator();

    var map = try HashMap([]const u8).init(allocator, 16);
    defer map.deinit();

    try map.put("name", "Shaheer");
    try map.put("age", "Shaheer");
    try map.put("code", "Shaheer");
    try map.remove("age");
    // try map.put("name", "Mariya");

    if (map.get("code")) |val| {
        std.debug.print("{s}\n", .{val});
    } else {
        std.debug.print("Key Not Found!", .{});
    }
}
