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

fn stringHash(key: []const u8) u64 {
    var hasher = std.hash.Wyhash.init(0);
    hasher.update(key);
    return hasher.final();
}

fn stringEql(key1: []const u8, key2: []const u8) bool {
    return std.mem.eql(u8, key1, key2);
}

pub fn main() !void {
    var debugAllocator = std.heap.DebugAllocator(.{}).init;
    defer _ = debugAllocator.deinit();

    const allocator = debugAllocator.allocator();

    var map = try HashMap(
        []const u8,
        usize,
        stringHash,
        stringEql,
    ).init(allocator, 16);

    defer map.deinit();

    try map.put("Shaheer", 94);
    try map.put("Mariya", 87);
    try map.put("Jannat", 84);
    try map.put("Faizan", 85);
}
