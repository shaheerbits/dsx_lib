const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = @import("array_list.zig").ArrayList;

/// A simple binary search tree that stores unique values in sorted order.
/// The left subtree contains smaller values and the right subtree contains larger values.
pub fn BinarySearchTree(comptime T: type) type {
    return struct {
        /// Each node stores one value and points to its left and right children.
        const Node = struct {
            value: T,
            left: ?*Node,
            right: ?*Node,
        };

        const Self = @This();

        root: ?*Node,
        len: usize,
        allocator: Allocator,

        /// Creates an empty tree and stores the allocator that will be used for new nodes.
        pub fn init(allocator: Allocator) Self {
            return .{ .allocator = allocator, .len = 0, .root = null };
        }

        /// Recursively frees every node in a subtree before the tree is destroyed.
        fn destroySubtree(self: *Self, node: *Node) void {
            if (node.left) |left| self.destroySubtree(left);
            if (node.right) |right| self.destroySubtree(right);

            self.allocator.destroy(node);
        }

        /// Starts the recursive cleanup at the root node.
        fn destroyTree(self: *Self) void {
            if (self.root) |root| {
                self.destroySubtree(root);
                self.root = null;
            }
        }

        /// Releases all allocated nodes and resets the tree back to an empty state.
        pub fn clear(self: *Self) void {
            self.destroyTree();
            self.root = null;
            self.len = 0;
        }

        /// Releases all allocated nodes and resets the tree back to an empty state.
        pub fn deinit(self: *Self) void {
            self.clear();
        }

        /// Allocates and initializes a single node for a new value.
        fn createNode(self: *const Self, value: T) !*Node {
            const new_node = try self.allocator.create(Node);
            new_node.* = .{ .value = value, .left = null, .right = null };
            return new_node;
        }

        /// Inserts a value into the BST.
        /// Duplicate values are rejected with `error.DuplicateValue` to keep the tree unique.
        pub fn insert(self: *Self, value: T) !void {
            if (self.root) |root| {
                var current: ?*Node = root;

                while (current) |temp| {
                    if (temp.value > value) {
                        // Go left when the new value is smaller than the current node.
                        if (temp.left) |left| {
                            current = left;
                        } else {
                            temp.left = try self.createNode(value);
                            self.len += 1;
                            return;
                        }
                    } else if (temp.value < value) {
                        // Go right when the new value is larger than the current node.
                        if (temp.right) |right| {
                            current = right;
                        } else {
                            temp.right = try self.createNode(value);
                            self.len += 1;
                            return;
                        }
                    } else {
                        return error.DuplicateValue;
                    }
                }
            } else {
                self.root = try self.createNode(value);
                self.len += 1;
                return;
            }
        }

        /// Searches for a value using the standard BST comparison rules.
        pub fn contains(self: *const Self, value: T) bool {
            var current = self.root;

            while (current) |temp| {
                if (temp.value > value) {
                    current = temp.left;
                } else if (temp.value < value) {
                    current = temp.right;
                } else {
                    return true;
                }
            }

            return false;
        }

        /// Returns the current number of stored elements.
        pub fn size(self: *const Self) usize {
            return self.len;
        }

        /// Returns true when the tree contains no values.
        pub fn isEmpty(self: *const Self) bool {
            return self.len == 0;
        }

        /// Recursively traverses the tree in left-root-right order.
        /// This produces values in sorted order for comparable types.
        fn visitInorder(self: *const Self, node: *Node, output: *ArrayList(T)) !void {
            if (node.left) |left| try self.visitInorder(left, output);
            try output.push(node.value);
            if (node.right) |right| try self.visitInorder(right, output);
        }

        /// Appends the tree values to an ArrayList in sorted order.
        pub fn inorder(self: *const Self, output: *ArrayList(T)) !void {
            if (self.root) |root| try self.visitInorder(root, output);
        }

        /// Recursively traverses the tree in root-left-right order.
        fn visitPreorder(self: *const Self, node: *Node, output: *ArrayList(T)) !void {
            try output.push(node.value);
            if (node.left) |left| try self.visitPreorder(left, output);
            if (node.right) |right| try self.visitPreorder(right, output);
        }

        /// Appends the tree values in preorder traversal order.
        pub fn preorder(self: *const Self, output: *ArrayList(T)) !void {
            if (self.root) |root| try self.visitPreorder(root, output);
        }

        /// Recursively traverses the tree in left-right-root order.
        fn visitPostorder(self: *const Self, node: *Node, output: *ArrayList(T)) !void {
            if (node.left) |left| try self.visitPostorder(left, output);
            if (node.right) |right| try self.visitPostorder(right, output);
            try output.push(node.value);
        }

        /// Appends the tree values in postorder traversal order.
        pub fn postorder(self: *const Self, output: *ArrayList(T)) !void {
            if (self.root) |root| try self.visitPostorder(root, output);
        }

        /// Returns the smallest stored value, or null when the tree is empty.
        /// The leftmost node is always the minimum in a BST.
        pub fn min(self: *const Self) ?T {
            if (self.root == null) return null;

            var current = self.root.?;

            while (current.left) |left| {
                current = left;
            }

            return current.value;
        }

        /// Returns the largest stored value, or null when the tree is empty.
        /// The rightmost node is always the maximum in a BST.
        pub fn max(self: *const Self) ?T {
            if (self.root == null) return null;

            var current = self.root.?;

            while (current.right) |right| {
                current = right;
            }

            return current.value;
        }

        fn removeNode(self: *Self, node: ?*Node, value: T) ?*Node {
            if (node == null) return null;

            var current = node.?;

            if (current.value > value) {
                current.left = self.removeNode(current.left, value);
            } else if (current.value < value) {
                current.right = self.removeNode(current.right, value);
            } else {
                if (current.left == null and current.right == null) {
                    self.allocator.destroy(current);
                    self.len -= 1;
                    return null;
                }

                if (current.left == null) {
                    const temp = current.right;
                    self.allocator.destroy(current);
                    self.len -= 1;
                    return temp;
                }

                if (current.right == null) {
                    const temp = current.left;
                    self.allocator.destroy(current);
                    self.len -= 1;
                    return temp;
                }

                var successor = current.right.?;
                while (successor.left != null) successor = successor.left.?;
                current.value = successor.value;
                current.right = self.removeNode(current.right, successor.value);
            }

            return current;
        }

        pub fn remove(self: *Self, value: T) void {
            self.root = self.removeNode(self.root, value);
        }
    };
}

// Test that duplicate insertion is rejected.
test "insert returns an error on inserting duplicate element" {
    const allocator = std.testing.allocator;

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    try bst.insert(50);
    try bst.insert(30);
    try bst.insert(80);

    try std.testing.expectEqual(bst.insert(50), error.DuplicateValue);
}

// Test that the current number of stored nodes is reported correctly.
test "size returns the correct size of the tree" {
    const allocator = std.testing.allocator;

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    try bst.insert(-5);
    try bst.insert(5);
    try bst.insert(-10);

    try std.testing.expectEqual(bst.size(), 3);
}

// Test the main lookup path for existing and missing values.
test "contains finds the element" {
    const allocator = std.testing.allocator;

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    try bst.insert(50);
    try bst.insert(30);
    try bst.insert(80);

    try std.testing.expect(bst.contains(50));
    try std.testing.expect(bst.contains(30));
    try std.testing.expect(bst.contains(80));
    try std.testing.expect(!bst.contains(40));
}

// Test that an empty tree does not report any value as present.
test "contains returns false for empty tree" {
    const allocator = std.testing.allocator;

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    try std.testing.expect(!bst.contains(100));
}

// Test lookup on a long right-leaning chain of nodes.
test "contains works for long one-directional chain of node" {
    const allocator = std.testing.allocator;

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    try bst.insert(10);
    try bst.insert(20);
    try bst.insert(30);
    try bst.insert(40);
    try bst.insert(50);
    try bst.insert(60);
    try bst.insert(70);
    try bst.insert(80);
    try bst.insert(90);

    try std.testing.expect(bst.contains(90));
}

// Test that the minimum value is found by walking the left edge.
test "min returns the smallest element" {
    const allocator = std.testing.allocator;

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    try bst.insert(50);
    try bst.insert(30);
    try bst.insert(10);
    try bst.insert(80);

    if (bst.min()) |smallest| {
        try std.testing.expectEqual(smallest, 10);
    }
}

// Test that the maximum value is found by walking the right edge.
test "max returns the largest element" {
    const allocator = std.testing.allocator;

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    try bst.insert(50);
    try bst.insert(30);
    try bst.insert(10);
    try bst.insert(80);

    if (bst.max()) |largest| {
        try std.testing.expectEqual(largest, 80);
    }
}

// Test the empty-tree case for minimum lookups.
test "min returns null for empty tree" {
    const allocator = std.testing.allocator;

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    const smallestOrNull = bst.min();

    try std.testing.expectEqual(smallestOrNull, null);
}

// Test the empty-tree case for maximum lookups.
test "max returns null for empty tree" {
    const allocator = std.testing.allocator;

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    const largestOrNull = bst.max();

    try std.testing.expectEqual(largestOrNull, null);
}

// Test that inorder traversal returns the values in sorted order.
test "inorder pushes a sorted series to the arraylist" {
    const allocator = std.testing.allocator;

    var values = ArrayList(i32).init(allocator);
    defer values.deinit();

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    try bst.insert(40);
    try bst.insert(20);
    try bst.insert(50);
    try bst.insert(10);
    try bst.insert(30);

    try bst.inorder(&values);

    try std.testing.expectEqualSlices(i32, values.itemsSlice(), &[_]i32{ 10, 20, 30, 40, 50 });
}

test "remove removes leaf node" {
    const allocator = std.testing.allocator;

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    try bst.insert(50);
    try bst.insert(30);
    try bst.insert(80);

    bst.remove(30);

    try std.testing.expect(!bst.contains(30));
    try std.testing.expect(bst.contains(50));
    try std.testing.expect(bst.contains(80));
    try std.testing.expectEqual(@as(usize, 2), bst.size());
}

test "remove node with one child" {
    const allocator = std.testing.allocator;

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    try bst.insert(50);
    try bst.insert(30);
    try bst.insert(10);

    bst.remove(30);

    try std.testing.expect(!bst.contains(30));
    try std.testing.expect(bst.contains(10));
    try std.testing.expect(bst.contains(50));
    try std.testing.expectEqual(@as(usize, 2), bst.size());
}

test "remove node with two children" {
    const allocator = std.testing.allocator;

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    try bst.insert(50);
    try bst.insert(30);
    try bst.insert(80);
    try bst.insert(10);
    try bst.insert(40);

    bst.remove(30);

    try std.testing.expect(!bst.contains(30));
    try std.testing.expect(bst.contains(10));
    try std.testing.expect(bst.contains(40));
    try std.testing.expect(bst.contains(50));
    try std.testing.expect(bst.contains(80));

    try std.testing.expectEqual(@as(usize, 4), bst.size());
}

test "remove root node" {
    const allocator = std.testing.allocator;

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    try bst.insert(50);
    try bst.insert(30);
    try bst.insert(80);

    bst.remove(50);

    try std.testing.expect(!bst.contains(50));
    try std.testing.expect(bst.contains(30));
    try std.testing.expect(bst.contains(80));
}

test "remove non-existing value does nothing" {
    const allocator = std.testing.allocator;

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    try bst.insert(50);
    try bst.insert(30);
    try bst.insert(80);

    bst.remove(999);

    try std.testing.expect(bst.contains(50));
    try std.testing.expect(bst.contains(30));
    try std.testing.expect(bst.contains(80));

    try std.testing.expectEqual(@as(usize, 3), bst.size());
}

test "remove all elements" {
    const allocator = std.testing.allocator;

    var bst = BinarySearchTree(i32).init(allocator);
    defer bst.deinit();

    try bst.insert(50);
    try bst.insert(30);
    try bst.insert(80);

    bst.remove(50);
    bst.remove(30);
    bst.remove(80);

    try std.testing.expect(bst.isEmpty());
    try std.testing.expectEqual(@as(usize, 0), bst.size());
}
