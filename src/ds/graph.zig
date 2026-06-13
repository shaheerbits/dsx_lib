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

        pub fn init(allocator: Allocator, is_directed: bool) Self {
            const map = HashMap(
                T,
                ArrayList(T),
                hashFn,
                eqlFn,
            ).init(
                allocator,
                32,
            );

            return .{
                .adjacency_map = map,
                .allocator = allocator,
                .is_directed = is_directed,
            };
        }

        pub fn addVertex(self: *Self, vertex: T) !void {
            if (self.adjacency_map.contains(vertex)) {
                return error.VertexAlreadyExist;
            }

            const neighbors = ArrayList(T).init(self.allocator);
            try self.adjacency_map.put(vertex, neighbors);
        }

        pub fn containsVertex(self: *const Self, vertex: T) bool {
            return self.adjacency_map.contains(vertex);
        }

        pub fn addEdge(self: *Self, from: T, to: T) !void {
            if (self.containsVertex(from) and self.containsVertex(to)) {
                if (self.adjacency_map.get(from).?.contains(to)) {
                    return error.EdgeAlreadyExist;
                }

                var from_neighbors = self.adjacency_map.get(from).?;
                try from_neighbors.push(to);

                if (!self.is_directed) {
                    var to_neighbors = self.adjacency_map.get(to).?;
                    try to_neighbors.push(from);
                }
            }

            return error.VertexNotFound;
        }

        pub fn containsEdge(self: *const Self, from: T, to: T) !bool {
            if (self.containsVertex(from) and self.containsVertex(to)) {
                return self.adjacency_map.get(from).?.contains(to);
            }

            return error.VertexNotFound;
        }

        pub fn getNeighbors(self: *const Self, vertex: T) !ArrayList(T) {
            if (!self.containsVertex(vertex)) return error.VertexNotFound;
            return self.adjacency_map.get(vertex).?;
        }

        // pub fn removeEdge(self: *Self, vertex: T) !bool {
        //     if ()
        // }
    };
}
