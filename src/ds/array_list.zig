const std = @import("std");
const Allocator = std.mem.Allocator;

/// A generic, dynamically-resizing array list evaluated at compile-time.
pub fn ArrayList(comptime T: type) type {
    return struct {
        const Self = @This();

        /// Slice pointing to the active allocated backing array storage.
        items: []T,
        /// The memory allocator used to manage the backing storage.
        allocator: Allocator,
        /// Total number of elements currently allocated in `items`.
        capacity: usize,
        /// Total number of elements currently occupied by user data.
        len: usize,

        /// Initializes an empty array list with zero initial capacity.
        pub fn init(allocator: Allocator) Self {
            return .{
                .allocator = allocator,
                .capacity = 0,
                // Start with an empty, zero-length slice to avoid early allocations.
                .items = &[_]T{},
                .len = 0,
            };
        }

        /// Releases all allocated backing memory.
        /// Invalidates all pointers and slices referencing elements within this list.
        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }

        // Internal helper to reallocate the backing storage to a specific size.
        fn resize(self: *Self, new_capacity: usize) !void {
            if (self.capacity == 0) {
                self.items =
                    try self.allocator.alloc(
                        T,
                        new_capacity,
                    );
            } else {
                self.items = try self.allocator.realloc(
                    self.items,
                    new_capacity,
                );
            }

            self.capacity = new_capacity;
        }

        /// Appends a new item to the end of the list.
        /// Automatically grows the backing storage if capacity is reached.
        pub fn push(self: *Self, value: T) !void {
            if (self.len == self.capacity) {
                // Grow geometrically (2x) to maintain O(1) amortized insertion.
                // Defaults to a base capacity of 4 elements if empty.
                const new_capacity = if (self.capacity == 0) 4 else self.capacity * 2;
                try self.resize(new_capacity);
            }

            self.items[self.len] = value;
            self.len += 1;
        }

        /// Removes and returns the last element of the list, or `null` if empty.
        pub fn pop(self: *Self) ?T {
            if (self.len == 0) return null;

            self.len -= 1;
            const popped = self.items[self.len];

            // Overwrite removed memory with 'undefined' to safely flag it as garbage.
            self.items[self.len] = undefined;

            return popped;
        }

        /// Returns the element at the specified index, or `null` if the index is out of bounds.
        pub fn get(self: *const Self, index: usize) ?T {
            if (index >= self.len) return null;
            return self.items[index];
        }

        /// Replaces the element at the specified index.
        /// Returns `error.IndexOutOfBounds` if the index is invalid.
        pub fn set(self: *Self, index: usize, value: T) !void {
            if (index >= self.len) return error.IndexOutOfBounds;
            self.items[index] = value;
        }

        /// Inserts an element at a given index, shifting all trailing elements to the right.
        /// Returns `error.IndexOutOfBounds` if index is strictly greater than `len`.
        pub fn insert(self: *Self, index: usize, value: T) !void {
            if (index > self.len) return error.IndexOutOfBounds;

            if (self.len == self.capacity) {
                const new_capacity = if (self.capacity == 0) 4 else self.capacity * 2;
                try self.resize(new_capacity);
            }

            // Shift trailing elements right by 1 index starting from the tail.
            var i = self.len;
            while (i > index) : (i -= 1) {
                self.items[i] = self.items[i - 1];
            }

            self.items[index] = value;
            self.len += 1;
        }

        /// Removes the element at the specified index, shifting trailing elements left.
        /// Returns the removed item, or `error.IndexOutOfBounds`.
        pub fn remove(self: *Self, index: usize) !T {
            if (index >= self.len) return error.IndexOutOfBounds;

            const removed = self.items[index];

            // Shift elements left by 1 index to fill the gap.
            for (index..self.len - 1) |i| {
                self.items[i] = self.items[i + 1];
            }

            self.len -= 1;
            self.items[self.len] = undefined;

            return removed;
        }

        /// Returns true if the target value exists in the active bounds of the list.
        /// Note: Uses deep memory equality via `std.meta.eql`.
        pub fn contains(self: *const Self, value: T) bool {
            for (self.items[0..self.len]) |item| {
                if (std.meta.eql(item, value))
                    return true;
            }
            return false;
        }

        /// Returns the index of the first occurrence of `value`, or `null` if not found.
        pub fn find(self: *const Self, value: T) ?usize {
            for (self.items[0..self.len], 0..) |item, i| {
                if (std.meta.eql(item, value))
                    return i;
            }
            return null;
        }

        /// Clears all elements from the list.
        pub fn clear(self: *Self) void {
            for (0..self.len) |i| {
                self.items[i] = undefined;
            }

            self.len = 0;
        }

        /// Returns true if the list contains zero elements.
        pub fn isEmpty(self: *const Self) bool {
            return self.len == 0;
        }

        /// Returns the last element of the list without removing it, or `null` if empty.
        pub fn peek(self: *const Self) ?T {
            if (self.len == 0) return null;
            return self.items[self.len - 1];
        }

        /// Shrinks the capacity of the array list to perfectly match its current length.
        pub fn shrinkToFit(self: *Self) !void {
            if (self.capacity == self.len) return;

            self.items = try self.allocator.realloc(self.items, self.len);
            self.capacity = self.len;
        }

        /// Returns a constant slice containing only the populated elements of the list.
        pub fn itemsSlice(self: *const Self) []const T {
            return self.items[0..self.len];
        }

        /// Returns the length of the list
        pub fn size(self: *const Self) usize {
            return self.len;
        }

        /// Utility debug function to print the list contents to stderr.
        /// Warning: Assumes type `T` can be formatted by the default "{}" specifier.
        pub fn print(self: *const Self) void {
            std.debug.print("[", .{});

            for (0..self.len) |i| {
                std.debug.print("{}", .{self.items[i]});

                if (i < self.len - 1) {
                    std.debug.print(", ", .{});
                }
            }

            std.debug.print("]\n", .{});
        }
    };
}

test "get the last element" {
    const allocator = std.testing.allocator;

    var list = ArrayList(u8).init(allocator);
    defer list.deinit();

    try list.push(3);
    try list.push(2);
    try list.push(1);

    if (list.get(list.size() - 1)) |value| {
        try std.testing.expect(value == 1);
    }
}

test "shrinkToFit shrinks the capacity" {
    const allocator = std.testing.allocator;

    var list = ArrayList(u8).init(allocator);
    defer list.deinit();

    try list.push(3);
    try list.push(2);

    try std.testing.expect(list.capacity == 4);

    try list.shrinkToFit();

    try std.testing.expect(list.capacity == list.len);
}
