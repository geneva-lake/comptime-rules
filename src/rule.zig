const std = @import("std");
const math = std.math;
const model = @import("model.zig");

const rule_file = "rule.json";

pub const Rule = struct {
    @"if": model.Condition,
    then: model.Action,

    // Processing orders: if condition passed then the action is applied
    pub fn process(self: Rule, orders: []model.Order, allocator: std.mem.Allocator) ![]model.PointsAccrual {
        var accruals = std.ArrayList(model.PointsAccrual).empty;
        errdefer accruals.deinit(allocator);
        for (orders) |order| {
            if (self.@"if".check(order.price)) {
                const points = self.then.compute(order.price);
                try accruals.append(allocator, .{
                    .Amount = @intFromFloat(math.ceil(points)),
                    .UserId = order.user_id,
                });
            }
        }
        return accruals.toOwnedSlice(allocator);
    }
};

// Parsing rule in comptime using intermediate tagged union
pub const rule: Rule = blk: {
    const json = @embedFile(rule_file);
    var buffer: [json.len * 10]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();
    const ruleConfig = std.json.parseFromSliceLeaky(model.RuleConfig, allocator, json, .{ .ignore_unknown_fields = true }) catch |err| {
        @compileError("JSON parsing failed: " ++ @errorName(err));
    };

    var r: Rule = undefined;

    for (std.meta.fields(Rule)) |field| {
        const value = @field(ruleConfig, field.name);
        @field(r, field.name) = switch (value) {
            inline else => |*payload| .{
                .ptr = @constCast(payload),
                .vtable = &@TypeOf(payload.*).vtable,
            },
        };
    }

    break :blk r;
};
