const std = @import("std");
const ArrayList = @import("ds/array_list.zig").ArrayList;
// const Stack = @import("ds/stack.zig").Stack;
// const Queue = @import("ds/queue.zig").Queue;
// const CircularQueue = @import("ds/circular_queue.zig").CircularQueue;
// const LinkedList = @import("ds/linked_list.zig").LinkedList;
// const Queue = @import("ds/queuev2.zig").Queue;
const BinarySearchTree = @import("ds/binary_search_tree.zig").BinarySearchTree;

pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    try bst.insert(50);
    try bst.insert(30);
    try bst.insert(80);
    try bst.insert(20);
    try bst.insert(10);

    _ = bst.remove(20);

    var list = ArrayList(i32).init(allocator);
    defer list.deinit();

    try bst.inorder(&list);

    for (list.itemsSlice()) |item| {
        std.debug.print("{} ", .{item});
    }
}
