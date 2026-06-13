const std = @import("std");
const Allocator = std.mem.Allocator;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;
const LinkedList = @import("linked_list.zig").LinkedList;

pub fn HashMap(
    comptime K: type,
    comptime V: type,
    comptime hashFn: fn (K) u64,
    comptime eqlFn: fn (K, K) bool,
) type {
    return struct {
        const Self = @This();
        const Entry = struct { key: K, value: V };

        buckets: []LinkedList(Entry),
        len: usize,
        capacity: usize,
        allocator: Allocator,

        pub fn init(allocator: Allocator, capacity: usize) !Self {
            if (capacity == 0) return error.InvalidCapacity;

            const buckets = try allocator.alloc(LinkedList(Entry), capacity);

            for (buckets) |*bucket| {
                bucket.* = LinkedList(Entry).init(allocator);
            }

            return .{
                .buckets = buckets,
                .capacity = capacity,
                .len = 0,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.clear();
            self.allocator.free(self.buckets);
        }

        pub fn clear(self: *Self) void {
            for (self.buckets) |*bucket| {
                bucket.clear();
            }

            self.len = 0;
        }

        pub fn put(self: *Self, key: K, value: V) !void {
            const bucketIndex = self.getBucketIndex(key);
            try self.putEntry(&self.buckets[bucketIndex], key, value);
        }

        pub fn get(self: *const Self, key: K) ?V {
            const bucketIndex = self.getBucketIndex(key);
            return self.getEntry(&self.buckets[bucketIndex], key);
        }

        pub fn contains(self: *const Self, key: K) bool {
            const bucketIndex = self.getBucketIndex(key);
            return self.containsEntry(&self.buckets[bucketIndex], key);
        }

        pub fn remove(self: *Self, key: K) bool {
            const bucketIndex = self.getBucketIndex(key);
            return self.removeEntry(&self.buckets[bucketIndex], key);
        }

        pub fn size(self: *const Self) usize {
            return self.len;
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.len == 0;
        }

        fn getBucketIndex(self: *const Self, key: K) usize {
            return @intCast(hashFn(key) % self.capacity);
        }

        fn putEntry(self: *Self, bucket: *LinkedList(Entry), key: K, value: V) !void {
            var temp = bucket.head;

            while (temp) |node| {
                if (eqlFn(node.value.key, key)) {
                    node.value.value = value;
                    return;
                }

                temp = node.next;
            }

            try bucket.append(Entry{ .key = key, .value = value });
            self.len += 1;
        }

        fn getEntry(_: *const Self, bucket: *LinkedList(Entry), key: K) ?V {
            var temp = bucket.head;

            while (temp) |node| {
                if (eqlFn(node.value.key, key)) return node.value.value;
                temp = node.next;
            }

            return null;
        }

        fn containsEntry(_: *const Self, bucket: *LinkedList(Entry), key: K) bool {
            var temp = bucket.head;

            while (temp) |node| {
                if (eqlFn(node.value.key, key)) return true;
                temp = node.next;
            }

            return false;
        }

        fn removeEntry(self: *Self, bucket: *LinkedList(Entry), key: K) bool {
            if (bucket.head == null) return false;

            var current = bucket.head;
            var previous: ?*LinkedList(Entry).Node = null;

            while (current) |node| {
                if (eqlFn(node.value.key, key)) {
                    const next = node.next;

                    if (previous) |prev_node| {
                        prev_node.next = next;
                        if (next == null) bucket.tail = prev_node;
                    } else {
                        bucket.head = next;
                        if (bucket.head == null) bucket.tail = null;
                    }

                    self.allocator.destroy(node);
                    bucket.len -= 1;
                    self.len -= 1;
                    return true;
                }

                previous = node;
                current = node.next;
            }

            return false;
        }
    };
}

fn stringHashFn(key: []const u8) u64 {
    var hasher = std.hash.Wyhash.init(0);
    hasher.update(key);
    return hasher.final();
}

fn stringEqlFn(self_key: []const u8, other_key: []const u8) bool {
    return std.mem.eql(u8, self_key, other_key);
}

test "putting elements into hashmap increases size" {
    const allocator = std.testing.allocator;

    var marks = try HashMap([]const u8, u8, stringHashFn, stringEqlFn).init(
        allocator,
        16,
    );
    defer marks.deinit();

    try marks.put("Alex", 92);
    try marks.put("Emily", 89);
    try marks.put("Meghan", 86);
    try marks.put("Ed", 84);

    try expectEqual(marks.size(), 4);
}

test "get returns the correct value" {
    const allocator = std.testing.allocator;

    var marks = try HashMap([]const u8, u8, stringHashFn, stringEqlFn).init(
        allocator,
        16,
    );
    defer marks.deinit();

    try marks.put("Alex", 92);
    try marks.put("Emily", 89);
    try marks.put("Meghan", 86);
    try marks.put("Ed", 84);

    if (marks.get("Alex")) |m| {
        try expectEqual(m, 92);
    }

    if (marks.get("Emily")) |m| {
        try expectEqual(m, 89);
    }

    if (marks.get("Meghan")) |m| {
        try expectEqual(m, 86);
    }

    if (marks.get("Ed")) |m| {
        try expectEqual(m, 84);
    }
}

test "get returns null on key not found" {
    const allocator = std.testing.allocator;

    var marks = try HashMap([]const u8, u8, stringHashFn, stringEqlFn).init(
        allocator,
        16,
    );
    defer marks.deinit();

    try marks.put("Alex", 92);
    try marks.put("Emily", 89);
    try marks.put("Meghan", 86);
    try marks.put("Ed", 84);

    const m1 = marks.get("Meghan");
    const m2 = marks.get("Kyle");

    try expectEqual(m1, 86);
    try expectEqual(m2, null);
}

test "put and get works with slices as values" {
    const allocator = std.testing.allocator;

    var programming_languages = try HashMap([]const u8, []const []const u8, stringHashFn, stringEqlFn).init(
        allocator,
        16,
    );
    defer programming_languages.deinit();

    try programming_languages.put(
        "Alex",
        &[_][]const u8{ "Zig", "Python", "JavaScript" },
    );
    try programming_languages.put(
        "Emily",
        &[_][]const u8{ "C++", "Python" },
    );
    try programming_languages.put(
        "Meghan",
        &[_][]const u8{ "Lua", "Python", "JavaScript" },
    );
    try programming_languages.put(
        "Ed",
        &[_][]const u8{ "Go", "Java" },
    );

    if (programming_languages.get("Alex")) |langs| {
        try expectEqualStrings(langs[0], "Zig");
    }

    if (programming_languages.get("Meghan")) |langs| {
        try expectEqualStrings(langs[1], "Python");
    }

    if (programming_languages.get("Ed")) |langs| {
        try expectEqualStrings(langs[0], "Go");
    }
}

test "put and get works with structs as values" {
    const allocator = std.testing.allocator;

    const Point = struct {
        x: f32,
        y: f32,
    };

    var points = try HashMap([]const u8, Point, stringHashFn, stringEqlFn).init(
        allocator,
        16,
    );
    defer points.deinit();

    try points.put("alpha", .{ .x = 6.5, .y = -4.2 });
    try points.put("beta", .{ .x = -2.5, .y = 1.3 });
    try points.put("delta", .{ .x = 4.3, .y = 5.9 });

    if (points.get("alpha")) |coords| {
        try expectEqual(coords.x, 6.5);
        try expectEqual(coords.y, -4.2);
    }

    if (points.get("delta")) |coords| {
        try expectEqual(coords.x, 4.3);
        try expectEqual(coords.y, 5.9);
    }
}

test "put updates the existing key if present" {
    const allocator = std.testing.allocator;

    var marks = try HashMap([]const u8, u8, stringHashFn, stringEqlFn).init(
        allocator,
        16,
    );
    defer marks.deinit();

    try expectEqual(marks.size(), 0);
    try expect(marks.isEmpty());

    try marks.put("Alex", 92);
    try marks.put("Emily", 89);
    try marks.put("Meghan", 86);
    try marks.put("Ed", 84);

    try expectEqual(marks.size(), 4);
    if (marks.get("Emily")) |m| try expectEqual(m, 89);

    try marks.put("Emily", 95);

    try expectEqual(marks.size(), 4);
    if (marks.get("Emily")) |m| try expectEqual(m, 95);
}

test "remove removes the existing key if present and returns true" {
    const allocator = std.testing.allocator;

    var marks = try HashMap([]const u8, u8, stringHashFn, stringEqlFn).init(
        allocator,
        16,
    );
    defer marks.deinit();

    try marks.put("Alex", 92);
    try marks.put("Emily", 89);
    try marks.put("Meghan", 86);
    try marks.put("Ed", 84);

    try expectEqual(marks.size(), 4);

    const has_removed = marks.remove("Alex");
    try expect(has_removed);

    try expectEqual(marks.size(), 3);
    try expect(!marks.contains("Alex"));
}
