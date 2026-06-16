const std = @import("std");
const Allocator = std.mem.Allocator;
const HashMap = @import("hashmap.zig").HashMap;
const ArrayList = @import("array_list.zig").ArrayList;

pub fn Graph(
    comptime T: type,
    comptime hashFn: fn (T) u64,
    comptime eqlFn: fn (T, T) bool,
) type {
    return struct {
        const Self = @This();

        adjacency_map: HashMap(
            T,
            ArrayList(T),
            hashFn,
            eqlFn,
        ),

        allocator: Allocator,
        is_directed: bool,

        fn capacity() usize {
            return @as(usize, 32);
        }

        pub fn init(allocator: Allocator, is_directed: bool) !Self {
            const map = try HashMap(
                T,
                ArrayList(T),
                hashFn,
                eqlFn,
            ).init(
                allocator,
                capacity(),
            );

            return .{
                .adjacency_map = map,
                .allocator = allocator,
                .is_directed = is_directed,
            };
        }

        pub fn clear(self: *Self) void {
            self.adjacency_map.clear();
        }

        pub fn deinit(self: *Self) void {
            self.adjacency_map.deinit();
        }

        pub fn addVertex(self: *Self, vertex: T) !void {
            if (self.adjacency_map.contains(vertex)) {
                return error.VertexAlreadyExists;
            }

            const neighbors = ArrayList(T).init(self.allocator);
            try self.adjacency_map.put(vertex, neighbors);
        }

        pub fn containsVertex(self: *const Self, vertex: T) bool {
            return self.adjacency_map.contains(vertex);
        }

        pub fn addEdge(self: *Self, from: T, to: T) !void {
            if (!self.containsVertex(from) or !self.containsVertex(to)) {
                return error.VertexNotFound;
            }

            if (self.adjacency_map.get(from).?.contains(to)) {
                return error.EdgeAlreadyExists;
            }

            if (self.adjacency_map.getPtr(from)) |neighbors| {
                try neighbors.push(to);
            }

            if (!self.is_directed) {
                if (self.adjacency_map.getPtr(to)) |neighbors| {
                    try neighbors.push(from);
                }
            }
        }

        pub fn containsEdge(self: *const Self, from: T, to: T) !bool {
            if (self.containsVertex(from) and self.containsVertex(to)) {
                return self.adjacency_map.get(from).?.contains(to);
            }

            return error.VertexNotFound;
        }

        pub fn getNeighbors(self: *const Self, vertex: T) !*ArrayList(T) {
            return self.adjacency_map.getPtr(vertex) orelse error.VertexNotFound;
        }

        pub fn removeEdge(self: *Self, from: T, to: T) !void {
            if (!self.containsVertex(from) or !self.containsVertex(to)) {
                return error.VertexNotFound;
            }

            if (!self.is_directed) {
                var neighbors = try self.getNeighbors(to);
                const has_removed = neighbors.removeItem(from);

                if (!has_removed) return error.EdgeNotFound;
            }

            var neighbors = try self.getNeighbors(from);
            const has_removed = neighbors.removeItem(to);

            if (!has_removed) return error.EdgeNotFound;
        }

        pub fn removeVertex(
            self: *Self,
            vertex: T,
        ) !void {
            if (!self.containsVertex(vertex)) {
                return error.VertexNotFound;
            }

            // Remove this vertex from all neighbor lists.
            for (self.adjacency_map.buckets) |*bucket| {
                var current = bucket.head;

                while (current) |node| {
                    _ = node.value.value.removeItem(vertex);
                    current = node.next;
                }
            }

            const removed =
                self.adjacency_map.remove(vertex);

            if (!removed) {
                return error.VertexNotFound;
            }
        }
    };
}
