const std = @import("std");
const model = @import("model.zig");
const rule = @import("rule.zig");
const comptime_rules = @import("comptime_rules");

const orders_file: []const u8 = "purchase_items.json";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const arena_allocator = arena.allocator();

    const orders = parse_orders(orders_file, arena_allocator) catch |err| {
        std.debug.print("Orders parsing error {any}\n", .{err});
        return;
    };

    const accruals = rule.rule.process(orders, arena_allocator) catch |err| {
        std.debug.print("Calculation error {any}\n", .{err});
        return;
    };

    for (accruals) |accrual| {
        std.debug.print("Accrual: userId: {s}, amount {d}\n", .{ accrual.UserId, accrual.Amount });
    }
}

fn parse_orders(fileName: []const u8, allocator: std.mem.Allocator) ![]model.Order {
    const json_orders = try std.fs.cwd().readFileAlloc(allocator, fileName, 1 << 20);
    defer allocator.free(json_orders);
    const orders = try std.json.parseFromSlice([]model.Order, allocator, json_orders, .{ .allocate = .alloc_always });
    return orders.value;
}
