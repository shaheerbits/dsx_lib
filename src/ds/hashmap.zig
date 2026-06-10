const std = @import("std");
const LinkedList = @import("linked_list.zig").LinkedList;
const Allocator = std.mem.Allocator;

pub fn HashMap(comptime V: type) type {
    return struct {
        const Entry = struct {
            key: []const u8,
            value: V,
        };

        const Self = @This();

        buckets: []LinkedList(Entry),
        len: usize,
        allocator: Allocator,
        capacity: usize,

        pub fn init(allocator: Allocator, capacity: usize) !Self {
            if (capacity == 0) return error.InvalidCapacity;

            const buckets = try allocator.alloc(
                LinkedList(Entry),
                capacity,
            );

            for (buckets) |*bucket| bucket.* = LinkedList(Entry).init(allocator);

            return .{
                .allocator = allocator,
                .buckets = buckets,
                .len = 0,
                .capacity = capacity,
            };
        }

        pub fn deinit(self: *Self) void {
            self.clear();
            self.allocator.free(self.buckets);
        }

        fn findByKey(
            _: *const Self,
            bucket: *LinkedList(Entry),
            key: []const u8,
        ) ?*LinkedList(Entry).Node {
            var temp = bucket.head;

            while (temp) |node| {
                if (std.mem.eql(u8, node.value.key, key)) return node;
                temp = node.next;
            }

            return null;
        }

        fn findIndexByKey(
            _: *const Self,
            bucket: *LinkedList(Entry),
            key: []const u8,
        ) ?usize {
            var index: usize = 0;
            var temp = bucket.head;

            while (temp) |node| {
                if (std.mem.eql(u8, node.value.key, key)) return index;
                temp = node.next;
                index += 1;
            }

            return null;
        }

        fn getHash(_: *const Self, key: []const u8) u64 {
            return hash: {
                var hasher = std.hash.Wyhash.init(0);
                hasher.update(key);
                break :hash hasher.final();
            };
        }

        fn getBucketIndex(self: *const Self, hash: u64) usize {
            return hash % self.capacity;
        }

        pub fn put(
            self: *Self,
            key: []const u8,
            value: V,
        ) !void {
            const bucketIndex = self.getBucketIndex(self.getHash(key));
            if (self.findByKey(&self.buckets[bucketIndex], key)) |existingNode| {
                existingNode.value.value = value;
            } else {
                try self.buckets[bucketIndex].append(Entry{ .key = key, .value = value });
                self.len += 1;
            }
        }

        pub fn get(self: *const Self, key: []const u8) ?V {
            const bucketIndex = self.getBucketIndex(self.getHash(key));
            if (self.findByKey(&self.buckets[bucketIndex], key)) |entry| {
                return entry.value.value;
            } else {
                return null;
            }
        }

        pub fn contains(self: *const Self, key: []const u8) bool {
            const bucketIndex = self.getBucketIndex(self.getHash(key));
            return if (self.findByKey(&self.buckets[bucketIndex], key)) |_| true else false;
        }

        pub fn remove(self: *Self, key: []const u8) !void {
            const bucketIndex = self.getBucketIndex(self.getHash(key));
            if (self.findIndexByKey(&self.buckets[bucketIndex], key)) |index| {
                _ = try self.buckets[bucketIndex].removeAt(index);
                self.len -= 1;
            } else {
                return error.KeyNotFound;
            }
        }

        pub fn clear(self: *Self) void {
            for (self.buckets) |*bucket| {
                bucket.clear();
            }

            self.len = 0;
        }

        pub fn size(self: *const Self) usize {
            return self.len;
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.len == 0;
        }
    };
}
